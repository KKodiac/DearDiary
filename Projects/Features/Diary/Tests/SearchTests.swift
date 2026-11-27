import ComposableArchitecture
import Foundation
import Persistence
import Testing
@testable import Diary

@MainActor
struct SearchTests {
    @Test func typingDebouncesAndUsesCurrentOwner() async {
        let clock = TestClock()
        let record = StoredEntry(id: UUID(), title: "A walk", content: "By the river", createdAt: .now)
        let entry = Entry(id: record.id, title: record.title, content: record.content, createdAt: record.createdAt)
        let store = TestStore(initialState: Search.State(ownerID: "alice")) { Search() } withDependencies: {
            $0.continuousClock = clock
            $0.entryStore.search = { query, ownerID in
                #expect(query == "walk")
                #expect(ownerID == "alice")
                return [record]
            }
        }
        await store.send(.queryChanged("wa")) {
            $0.query = "wa"
            $0.generation = 1
            $0.isLoading = true
        }
        await clock.advance(by: .milliseconds(200))
        await store.send(.queryChanged(" walk ")) {
            $0.query = " walk "
            $0.generation = 2
        }
        await clock.advance(by: .milliseconds(300))
        await store.receive(.resultsReceived(generation: 2, entries: [entry])) {
            $0.entries = [entry]
            $0.isLoading = false
            $0.hasSearched = true
        }
        await store.finish()
    }

    @Test func clearingQueryCancelsPendingSearchAndResetsResults() async {
        let clock = TestClock()
        let store = TestStore(initialState: Search.State(ownerID: "alice")) { Search() } withDependencies: {
            $0.continuousClock = clock
            $0.entryStore.search = { _, _ in
                Issue.record("A cleared query must not hit storage")
                return []
            }
        }
        await store.send(.queryChanged("walk")) {
            $0.query = "walk"
            $0.generation = 1
            $0.isLoading = true
        }
        await store.send(.queryChanged(" \n ")) {
            $0.query = " \n "
            $0.generation = 2
            $0.isLoading = false
        }
        await clock.advance(by: .seconds(1))
        await store.finish()
    }

    @Test func submitSearchesImmediatelyAndShowsEmptyResults() async {
        var state = Search.State(ownerID: "alice")
        state.query = "quiet"
        let store = TestStore(initialState: state) { Search() } withDependencies: {
            $0.entryStore.search = { query, ownerID in
                #expect(query == "quiet")
                #expect(ownerID == "alice")
                return []
            }
        }
        await store.send(.submit) {
            $0.generation = 1
            $0.isLoading = true
        }
        await store.receive(.resultsReceived(generation: 1, entries: [])) {
            $0.isLoading = false
            $0.hasSearched = true
        }
    }

    @Test func failureCanRetryWithoutChangingQuery() async {
        let attempts = SearchAttempts()
        var state = Search.State(ownerID: "alice")
        state.query = "walk"
        let store = TestStore(initialState: state) { Search() } withDependencies: {
            $0.entryStore.search = { _, _ in try await attempts.search() }
        }
        await store.send(.submit) {
            $0.generation = 1
            $0.isLoading = true
        }
        await store.receive(.searchFailed(generation: 1)) {
            $0.isLoading = false
            $0.errorMessage = "Your diary couldn’t be searched. Please try again."
        }
        await store.send(.retry) {
            $0.generation = 2
            $0.isLoading = true
            $0.errorMessage = nil
        }
        await store.receive(.resultsReceived(generation: 2, entries: [])) {
            $0.isLoading = false
            $0.hasSearched = true
        }
    }

    @Test func staleResponsesAreIgnored() async {
        var state = Search.State(ownerID: "alice")
        state.query = "current"
        state.generation = 2
        state.isLoading = true
        let store = TestStore(initialState: state) { Search() }

        await store.send(.resultsReceived(generation: 1, entries: Entry.mock))
        await store.send(.searchFailed(generation: 1))
    }

    @Test func disappearanceCancelsPendingSearchAndRejectsLateResults() async {
        let clock = TestClock()
        let store = TestStore(initialState: Search.State(ownerID: "alice")) { Search() } withDependencies: {
            $0.continuousClock = clock
            $0.entryStore.search = { _, _ in
                Issue.record("A dismissed search must not hit storage")
                return []
            }
        }
        await store.send(.queryChanged("walk")) {
            $0.query = "walk"
            $0.generation = 1
            $0.isLoading = true
        }
        await store.send(.disappeared) {
            $0.generation = 2
            $0.isLoading = false
        }
        await clock.advance(by: .seconds(1))
        await store.send(.resultsReceived(generation: 1, entries: Entry.mock))
        await store.finish()
    }

    @Test func missingOwnerDoesNotSearchStorage() async {
        var state = Search.State(ownerID: "")
        state.query = "walk"
        let store = TestStore(initialState: state) { Search() } withDependencies: {
            $0.entryStore.search = { _, _ in
                Issue.record("Searching without an account must not hit storage")
                return []
            }
        }
        await store.send(.submit) {
            $0.generation = 1
            $0.errorMessage = "Sign in again to search your diary."
        }
    }

    @Test func selectingResultDelegatesToDiary() async {
        let entry = Entry(title: "A walk", content: "By the river")
        var state = Search.State(ownerID: "alice")
        state.entries = [entry]
        state.hasSearched = true
        let store = TestStore(initialState: state) { Search() }
        await store.send(.didTapEntry(entry))
        await store.receive(.delegate(.didSelectEntry(entry)))
        await store.send(.didTapEntry(Entry(title: "Not a result", content: "")))
    }
}

private actor SearchAttempts {
    enum Failure: Error { case unavailable }
    var count = 0
    func search() throws -> [StoredEntry] {
        count += 1
        if count == 1 { throw Failure.unavailable }
        return []
    }
}
