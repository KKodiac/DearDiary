import Auth
import ComposableArchitecture
import Testing
@testable import Diary

@MainActor
struct SettingTests {
    @Test
    func confirmationDelegatesSignOutAndFailurePreservesSession() async {
        var state = Setting.State(diaryName: "My diary")
        state.$uid = Shared(value: "alice")
        state.$diaryName = Shared(value: "My diary")
        let store = TestStore(initialState: state) { Setting() }
        await store.send(.requestSignOut) { $0.isSignOutConfirmationPresented = true }
        await store.send(.confirmSignOut) {
            $0.isSignOutConfirmationPresented = false
            $0.isSigningOut = true
        }
        await store.receive(.delegate(.signOutRequested))
        await store.send(.signOutFailed) {
            $0.isSigningOut = false
            $0.errorMessage = "You couldn’t be signed out. Please try again."
        }
        #expect(store.state.uid == "alice")
        #expect(store.state.diaryName == "My diary")
    }

    @Test
    func nameIsTrimmedAndBlankNameIsRejected() async {
        var state = Setting.State(diaryName: "  My diary  ")
        state.$diaryName = Shared(value: "Old name")
        let store = TestStore(initialState: state) { Setting() }
        await store.send(.saveName) {
            $0.$diaryName.withLock { $0 = "My diary" }
            $0.draftName = "My diary"
        }
        await store.send(.binding(.set(\.draftName, "   "))) { $0.draftName = "   " }
        await store.send(.saveName) {
            $0.errorMessage = "Give your diary a name before saving."
        }
        #expect(store.state.diaryName == "My diary")
    }

    @Test
    func duplicateSignOutIsIgnored() async {
        var state = Setting.State()
        state.isSigningOut = true
        let store = TestStore(initialState: state) { Setting() }
        await store.send(.confirmSignOut)
        await store.send(.requestSignOut)
    }
}
