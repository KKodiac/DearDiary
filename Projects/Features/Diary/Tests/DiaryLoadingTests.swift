import ComposableArchitecture
import Foundation
import Persistence
import SwiftUICalendar
import Testing
@testable import Diary

@MainActor
struct DiaryLoadingTests {
    @Test
    func loadsSelectedDayForCurrentAccount() async {
        var state = Diary.State()
        state.$uid = Shared(value: "alice")
        let date = state.focusDate.date ?? .now
        let record = StoredEntry(id: UUID(), title: "A day", content: "Content", createdAt: date)
        let expected = Entry(id: record.id, title: record.title, content: record.content, createdAt: date)
        let store = TestStore(initialState: state) { Diary() } withDependencies: {
            $0.entryStore.load = { start, end, ownerID in
                #expect(ownerID == "alice")
                #expect(start <= date && date < end)
                return [record]
            }
        }
        await store.send(.view(.didAppear)) {
            $0.isLoading = true
            $0.loadGeneration = 1
        }
        await store.receive(.internal(.didLoadEntries(generation: 1, entries: [expected]))) {
            $0.isLoading = false
            $0.hasLoaded = true
            $0.focusedEntries = [expected]
        }
    }

    @Test
    func loadingFailureCanRetryIntoEmptyState() async {
        let attempts = LoadAttempts()
        var state = Diary.State()
        state.$uid = Shared(value: "alice")
        let store = TestStore(initialState: state) { Diary() } withDependencies: {
            $0.entryStore.load = { _, _, _ in try await attempts.load() }
        }
        await store.send(.view(.didAppear)) {
            $0.isLoading = true
            $0.loadGeneration = 1
        }
        await store.receive(.internal(.didFailLoading(generation: 1))) {
            $0.isLoading = false
            $0.loadError = "Your diary entries couldn’t be loaded. Please try again."
        }
        await store.send(.view(.didTapRetry)) {
            $0.loadGeneration = 2
            $0.loadError = nil
            $0.isLoading = true
        }
        await store.receive(.internal(.didLoadEntries(generation: 2, entries: []))) {
            $0.isLoading = false
            $0.hasLoaded = true
        }
    }

    @Test
    func staleDateResponseDoesNotReplaceCurrentEntries() async {
        var state = Diary.State()
        state.loadGeneration = 2
        state.isLoading = true
        let store = TestStore(initialState: state) { Diary() }
        await store.send(.internal(.didLoadEntries(generation: 1, entries: Entry.mock)))
        await store.send(.internal(.didFailLoading(generation: 1)))
    }
}

private actor LoadAttempts {
    var count = 0
    func load() throws -> [StoredEntry] {
        count += 1
        if count == 1 { throw EntryStorageError.missingOwner }
        return []
    }
}
