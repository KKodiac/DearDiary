import Account
import ComposableArchitecture
@testable import Diary
import Testing
@testable import DearDiary

@MainActor
struct DearDiaryTests {
    @Test
    func signedOutSessionOpensAuthentication() async {
        let store = makeStore(uid: "", diaryName: "")

        await store.send(.navigateToFeature) {
            $0.destination = .auth(Account.State())
        }
    }

    @Test
    func signedInSessionWithoutDiaryNameOpensSetup() async {
        let store = makeStore(uid: "test-user", diaryName: "")

        await store.send(.navigateToFeature) {
            $0.destination = .auth(Account.State(destination: .setUp(Setup.State())))
        }
    }

    @Test
    func configuredSessionOpensDiary() async {
        let store = makeStore(uid: "test-user", diaryName: "My diary")

        await store.send(.navigateToFeature) {
            $0.destination = .diary(Diary.State())
        }
    }

    @Test
    func settingsSignOutReturnsToAuthentication() async {
        let store = TestStore(initialState: {
            var state = DearDiary.State()
            state.$uid = Shared(value: "")
            state.$diaryName = Shared(value: "")
            state.destination = .diary(Diary.State())
            return state
        }()) { DearDiary() }

        await store.send(.destination(.presented(.diary(.view(.didTapNavigateToSetting))))) {
            var diary = Diary.State()
            diary.destination = .setting(Setting.State())
            $0.destination = .diary(diary)
        }
        await store.send(.destination(.presented(.diary(.delegate(.signedOut))))) {
            $0.destination = .auth(Account.State())
        }
    }

    private func makeStore(uid: String, diaryName: String) -> TestStoreOf<DearDiary> {
        TestStore(initialState: {
            var state = DearDiary.State()
            state.$uid = Shared(value: uid)
            state.$diaryName = Shared(value: diaryName)
            return state
        }()) {
            DearDiary()
        }
    }
}
