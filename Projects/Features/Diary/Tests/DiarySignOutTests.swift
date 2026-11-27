import Auth
import ComposableArchitecture
import Testing
@testable import Diary

@MainActor
struct DiarySignOutTests {
    @Test
    func leavingSettingsDoesNotInterruptSignOutCleanup() async {
        let clock = TestClock()
        var state = Diary.State()
        state.$uid = Shared(value: "alice")
        state.$diaryName = Shared(value: "My diary")
        state.focusedEntries = Entry.mock
        let store = TestStore(initialState: state) { Diary() } withDependencies: {
            $0.sessionClient.signOut = { try await clock.sleep(for: .seconds(1)) }
        }
        await store.send(.view(.didTapNavigateToSetting)) {
            $0.destination = .setting(Setting.State(diaryName: "My diary"))
        }
        await store.send(.destination(.presented(.setting(.confirmSignOut)))) {
            guard case var .setting(settings) = $0.destination else { return }
            settings.isSigningOut = true
            $0.destination = .setting(settings)
        }
        await store.receive(.destination(.presented(.setting(.delegate(.signOutRequested))))) {
            $0.isSigningOut = true
        }
        await store.send(.destination(.dismiss)) { $0.destination = nil }
        await clock.advance(by: .seconds(1))
        await store.receive(.internal(.didSignOut)) {
            $0.isSigningOut = false
            $0.$uid.withLock { $0 = "" }
            $0.$diaryName.withLock { $0 = "" }
            $0.focusedEntries = []
            $0.loadGeneration = 1
        }
        await store.receive(.delegate(.signedOut))
        await store.finish()
    }

    @Test
    func failedSignOutPreservesSessionAndReportsFailureToSettings() async {
        var state = Diary.State()
        state.$uid = Shared(value: "alice")
        state.$diaryName = Shared(value: "My diary")
        state.destination = .setting(Setting.State(diaryName: "My diary", isSigningOut: true))
        let store = TestStore(initialState: state) { Diary() } withDependencies: {
            $0.sessionClient.signOut = { throw FirebaseAuthError.failedToConfigureFirebaseApp }
        }
        await store.send(.destination(.presented(.setting(.delegate(.signOutRequested))))) {
            $0.isSigningOut = true
        }
        await store.receive(.internal(.didFailSignOut)) {
            $0.isSigningOut = false
            $0.sessionError = "You couldn’t be signed out. Open Settings to try again."
        }
        await store.receive(.destination(.presented(.setting(.signOutFailed)))) {
            guard case var .setting(settings) = $0.destination else { return }
            settings.isSigningOut = false
            settings.errorMessage = "You couldn’t be signed out. Please try again."
            $0.destination = .setting(settings)
        }
        #expect(store.state.uid == "alice")
        #expect(store.state.diaryName == "My diary")
    }

    @Test
    func signOutErrorSurvivesSuccessfulDiaryReload() async {
        var state = Diary.State()
        state.$uid = Shared(value: "alice")
        let store = TestStore(initialState: state) { Diary() } withDependencies: {
            $0.entryStore.load = { _, _, _ in [] }
        }

        await store.send(.internal(.didFailSignOut)) {
            $0.sessionError = "You couldn’t be signed out. Open Settings to try again."
        }
        await store.send(.view(.didTapRetry)) {
            $0.isLoading = true
            $0.loadGeneration = 1
        }
        await store.receive(.internal(.didLoadEntries(generation: 1, entries: []))) {
            $0.isLoading = false
            $0.hasLoaded = true
        }
        #expect(store.state.sessionError == "You couldn’t be signed out. Open Settings to try again.")
    }
}
