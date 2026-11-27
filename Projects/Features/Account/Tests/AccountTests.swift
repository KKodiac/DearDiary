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
    @Test func socialSignInShowsFriendlyConfigurationError() async {
        let store = TestStore(initialState: Account.State()) {
            Account()
        } withDependencies: {
            $0.authClient = .testValue
        }
        let error = SignIn.FeatureError.authClientError(.firebaseAuthError(.clientIDIsNil))

        await store.send(.view(.didTapSignInWithGoogle))
        await store.receive(.internal(.signIn(.delegate(.didThrowError(error))))) {
            $0.error = .signInThrewError(error)
        }
        #expect(store.state.error?.userMessage == "Account services are unavailable right now. Please try again later.")
    }

    @MainActor
    @Test func socialSignInCancellationDoesNotShowAnError() async {
        let store = TestStore(initialState: Account.State()) { Account() }
        let googleCancellation = SignIn.FeatureError.authClientError(
            .googleAuthError(.otherError(NSError(domain: "com.google.GIDSignIn", code: -5)))
        )
        let appleCancellation = SignIn.FeatureError.authClientError(.appleAuthError(.canceled))

        await store.send(.internal(.signIn(.delegate(.didThrowError(googleCancellation)))))
        await store.send(.internal(.signIn(.delegate(.didThrowError(appleCancellation)))))
    }

    @MainActor
    @Test func emailSignInShowsProviderRecoveryMessage() async {
        let state = Authentication.State(clientUID: Shared(value: ""))
        let store = TestStore(initialState: state) { Authentication() }
        let error = SignIn.FeatureError.authClientError(
            .firebaseAuthError(.otherError(NSError(domain: "FIRAuthErrorDomain", code: 17020)))
        )

        await store.send(.internal(.signIn(.delegate(.didThrowError(error))))) {
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
        let state = Registration.State()
        let store = TestStore(initialState: state) { Registration() }

        await store.send(.internal(.signUp(.delegate(.didThrowError(
            .authClientError(.firebaseAuthError(.otherError(
                NSError(domain: "FIRAuthErrorDomain", code: 17026)
            )))
        ))))) {
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
