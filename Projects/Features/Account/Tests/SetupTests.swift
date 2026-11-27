import ComposableArchitecture
import Testing
@testable import Account

@MainActor
struct SetupTests {
    @Test
    func blankNameDoesNotCompleteOnboarding() async {
        var state = Setup.State()
        state.$name = Shared(value: "   ")
        let store = TestStore(initialState: state) { Setup() }
        await store.send(.view(.didTapGetStarted)) {
            $0.errorMessage = "Give your diary a name to get started."
        }
        await store.finish()
    }

    @Test
    func validNameIsTrimmedBeforeNavigation() async {
        var state = Setup.State()
        state.$name = Shared(value: "  Kitty  ")
        let store = TestStore(initialState: state) { Setup() }
        await store.send(.view(.didTapGetStarted)) {
            $0.$name.withLock { $0 = "Kitty" }
        }
        await store.receive(.delegate(.navigateToDiary))
        #expect(store.state.personalities == Personality.allCases)
    }
}
