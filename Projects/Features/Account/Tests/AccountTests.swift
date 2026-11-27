import Testing
import SnapshotTesting
import ComposableArchitecture
@testable import Account

struct AccountTests {
    @MainActor
    @Test func account() async throws {
        let sut = TestStoreOf<Account>(initialState: Account.State()) {
            Account()
        } withDependencies: { dependencyValues in
            dependencyValues.authClient = .testValue
        }
        
        await sut.send(.view(.didAppear))
    }

    @MainActor
    @Test func signInFailureClearsProgressAndAllowsEmailNavigation() async {
        let store = TestStore(initialState: Account.State()) {
            Account()
        } withDependencies: {
            $0.authClient = .testValue
        }
        let error = SignIn.FeatureError.authClientError(.firebaseAuthError(.clientIDIsNil))

        await store.send(.view(.didTapSignInWithGoogle)) {
            $0.isSubmitting = true
        }
        await store.receive(.internal(.signIn(.delegate(.didThrowError(error))))) {
            $0.isSubmitting = false
            $0.error = Account.FeatureError(error: error)
        }
        await store.send(.view(.didTapSignInWithEmail)) {
            $0.destination = .authentication(Authentication.State(clientUID: $0.$clientUID))
        }
    }
}
