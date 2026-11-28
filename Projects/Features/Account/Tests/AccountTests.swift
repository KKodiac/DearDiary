import Foundation
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
        #expect(store.state.error?.userMessage == "Account services are unavailable right now. Please try again later.")
        await store.send(.view(.didTapSignInWithEmail)) {
            $0.destination = .authentication(Authentication.State(clientUID: $0.$clientUID))
        }
    }

    @MainActor
    @Test func googleCancellationClearsProgressWithoutShowingAnError() async {
        var state = Account.State()
        state.isSubmitting = true
        let store = TestStore(initialState: state) { Account() }
        let cancellation = SignIn.FeatureError.authClientError(
            .googleAuthError(.otherError(NSError(domain: "com.google.GIDSignIn", code: -5)))
        )

        await store.send(.view(.didTapSignInWithGoogle))
        await store.send(.view(.didTapSignInWithApple))
        await store.send(.view(.didTapSignInWithEmail))
        await store.send(.internal(.signIn(.delegate(.didThrowError(cancellation))))) {
            $0.isSubmitting = false
        }
        await store.send(.view(.didTapSignInWithEmail)) {
            $0.destination = .authentication(Authentication.State(clientUID: $0.$clientUID))
        }
    }

    @MainActor
    @Test func appleCancellationClearsProgressWithoutShowingAnError() async {
        var state = Account.State()
        state.isSubmitting = true
        let store = TestStore(initialState: state) { Account() }
        let cancellation = SignIn.FeatureError.authClientError(.appleAuthError(.canceled))

        await store.send(.internal(.signIn(.delegate(.didThrowError(cancellation))))) {
            $0.isSubmitting = false
        }
    }

    @MainActor
    @Test func emailSignInShowsProviderRecoveryMessage() async {
        var state = Authentication.State(clientUID: Shared(value: ""))
        state.isSubmitting = true
        let store = TestStore(initialState: state) { Authentication() }
        let error = SignIn.FeatureError.authClientError(
            .firebaseAuthError(.otherError(NSError(domain: "FIRAuthErrorDomain", code: 17020)))
        )

        await store.send(.internal(.signIn(.delegate(.didThrowError(error))))) {
            $0.isSubmitting = false
            $0.alert = AlertState {
                TextState("Couldn’t sign in")
            } actions: {
                ButtonState(role: .cancel) { TextState("OK") }
            } message: {
                TextState("Check your internet connection and try again.")
            }
        }
    }

    @MainActor
    @Test func registrationShowsWeakPasswordMessage() async {
        var state = Registration.State()
        state.isSubmitting = true
        let store = TestStore(initialState: state) { Registration() }

        await store.send(.internal(.signUp(.delegate(.didThrowError(
            .authClientError(.firebaseAuthError(.otherError(
                NSError(domain: "FIRAuthErrorDomain", code: 17026)
            )))
        ))))) {
            $0.isSubmitting = false
            $0.alert = AlertState {
                TextState("Couldn’t create your account")
            } actions: {
                ButtonState(role: .cancel) { TextState("OK") }
            } message: {
                TextState("Choose a stronger password and try again.")
            }
        }
    }
}
