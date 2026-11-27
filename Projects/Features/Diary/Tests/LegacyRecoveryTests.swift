import Auth
import ComposableArchitecture
import Foundation
import Persistence
import Testing
@testable import Diary

@MainActor
struct LegacyRecoveryTests {
    private let account = SessionClient.Account(id: "alice", email: "alice@example.com")
    private let entry = StoredEntry(
        id: UUID(), title: "Old entry", content: "Diary text",
        createdAt: Date(timeIntervalSince1970: 1_700_000_000)
    )

    @Test
    func recoveryRequiresReviewAndExplicitConfirmation() async {
        let account = account
        let entry = entry
        let writes = LockIsolated<[UUID]>([])
        let store = TestStore(initialState: LegacyRecovery.State(ownerID: account.id)) {
            LegacyRecovery()
        } withDependencies: {
            $0.sessionClient.currentAccount = { account }
            $0.entryStore.legacyEntries = { [entry] }
            $0.entryStore.recoverLegacyEntry = { id, ownerID in
                #expect(ownerID == account.id)
                writes.withValue { $0.append(id) }
            }
        }

        await store.send(.load) { $0.isLoading = true }
        await store.receive(.loaded(account, [entry])) {
            $0.isLoading = false
            $0.hasLoaded = true
            $0.account = account
            $0.entries = [entry]
        }
        await store.send(.confirmOwnership)
        await store.send(.review(entry)) { $0.reviewedEntry = entry }
        await store.send(.cancelReview) { $0.reviewedEntry = nil }
        await store.send(.confirmOwnership)
        #expect(writes.value.isEmpty)

        await store.send(.review(entry)) { $0.reviewedEntry = entry }
        await store.send(.confirmOwnership) { $0.isRecovering = true }
        await store.receive(.recovered(entry.id)) {
            $0.isRecovering = false
            $0.didRecoverEntry = true
            $0.entries = []
            $0.reviewedEntry = nil
        }
        await store.receive(.entriesChanged)
        #expect(writes.value == [entry.id])
    }

    @Test
    func accountSwitchDuringReviewPreventsRecovery() async {
        var state = LegacyRecovery.State(ownerID: account.id)
        state.account = account
        state.entries = [entry]
        state.hasLoaded = true
        state.reviewedEntry = entry

        let store = TestStore(initialState: state) {
            LegacyRecovery()
        } withDependencies: {
            $0.sessionClient.currentAccount = { .init(id: "bob", email: nil) }
            $0.entryStore.recoverLegacyEntry = { _, _ in Issue.record("Unexpected recovery") }
        }
        await store.send(.confirmOwnership) { $0.isRecovering = true }
        await store.receive(.sessionChanged) {
            $0.isRecovering = false
            $0.hasLoaded = false
            $0.account = nil
            $0.entries = []
            $0.reviewedEntry = nil
            $0.error = "Your signed-in account changed. Close recovery and sign in again."
        }
    }
}
