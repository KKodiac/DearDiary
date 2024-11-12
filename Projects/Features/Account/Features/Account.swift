import AuthenticationServices
import ExternalDependencies
import Foundation
import SwiftUI

@Reducer
public struct Account {
    public init() { }
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?
        @Shared(.appStorage("uid")) var uid = ""
        @Shared(.appStorage("diary_name")) var diaryName = ""
        
        var error: FeatureError? = nil
        public init() { }
    }
    
    public enum Action: ViewAction, BindableAction {
        case destination(PresentationAction<Destination.Action>)
        
        case view(ViewActions)
        case delegate(DelegateActions)
        case `internal`(InternalActions)
        
        
        case binding(BindingAction<State>)
        
        public enum ViewActions: Sendable {
            case didReceiveOpenURL(URL)
            case didTapSignInWithGoogle(UIViewController?)
            case didTapSignInWithApple(AuthorizationController)
            case didTapSignInWithEmail
            case didTapSignUpWithEmail
        }
        
        public enum DelegateActions: Sendable {
            case navigateToDiary
        }
        
        public enum InternalActions: Sendable {
            case didSucceedSignIn(String)
            
            case didRequestSignInScreen
            case didRequestSignUpScreen
            case didRequestSetUpScreen
            
            case didRequestGoogleSignIn(UIViewController?)
            case didRequestAppleSignIn(AuthorizationController)
            
            case didFailFeatureAction(FeatureError)
        }
    }
    
    
    @Reducer
    public enum Destination {
        case signIn(Authentication)
        case signUp(Registration)
        case setUp(Setup)
    }
    
    @Dependency(\.defaultAppStorage) private var appStorage
    @Dependency(\.google) private var google
    @Dependency(\.firebase) private var firebase
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didReceiveOpenURL(let url):
                    google.handle(url)
                    return .none
                    
                case .didTapSignInWithGoogle(let viewController):
                    return .send(
                        .internal(.didRequestGoogleSignIn(viewController))
                    )
                    
                case .didTapSignInWithApple(let controller):
                    return .send(
                        .internal(.didRequestAppleSignIn(controller))
                    )
                    
                case .didTapSignInWithEmail:
                    return .send(
                        .internal(.didRequestSignInScreen)
                    )
                    
                case .didTapSignUpWithEmail:
                    return .send(
                        .internal(.didRequestSignUpScreen)
                    )
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .didRequestSignInScreen:
                    state.destination = .signIn(Authentication.State())
                    return .none
                    
                case .didRequestSignUpScreen:
                    state.destination = .signUp(Registration.State())
                    return .none
                    
                case .didRequestSetUpScreen:
                    state.destination = .setUp(Setup.State())
                    return .none
                    
                case .didSucceedSignIn(let userId):
                    state.uid = userId
                    if state.diaryName.isEmpty {
                        state.destination = .setUp(Setup.State())
                        return .none
                    }
                    return .send(.delegate(.navigateToDiary))
                    
                case .didFailFeatureAction(let error):
                    state.error = error
                    return .none
                    
                case .didRequestGoogleSignIn(let viewController):
                    guard let viewController else { return
                        .send(.internal(
                            .didFailFeatureAction(.authenticationAttemptDidNotSucceed)
                        ))
                    }
                    firebase.configureFirebaseWithOptionsIfNotConfigured()
                    return .run { send in
                        google.configuration = GIDConfiguration(
                            clientID: try firebase.clientID()
                        )
                        let result = try await google.signIn(withPresenting: viewController)
                        let token = try ResultToken(user: result.user)
                        let credential = GoogleAuthProvider.credential(
                            withIDToken: token.idToken,
                            accessToken: token.accessToken
                        )
                        let success = try await firebase
                            .authenticateWithFirebaseAuthSocialProvider(
                                credential
                            )
                        await send(.internal(.didSucceedSignIn(success.user.uid)))
                    } catch: { _, send in
                        await send(.internal(.didFailFeatureAction(.authenticationAttemptDidNotSucceed)))
                    }
                case .didRequestAppleSignIn(let controller):
                    return .run { send in
                        let provider = ASAuthorizationAppleIDProvider()
                        async let request = provider.createRequest()
                        await request.requestedScopes = [.email, .fullName]
                        let result = try await controller.performRequest(request)
                        if case let .appleID(credential) = result {
                            if let token = credential.identityToken,
                               let tokenString = String(data: token,encoding: .utf8) {
                                let credential = OAuthProvider.appleCredential(
                                    withIDToken: tokenString,
                                    rawNonce: firebase.makeRandomNonceString(),
                                    fullName: credential.fullName
                                )
                                let result = try await firebase
                                    .authenticateWithFirebaseAuthSocialProvider(
                                        credential
                                    )
                                await send(.internal(.didSucceedSignIn(result.user.uid)))
                            }
                        }
                    } catch: { _, send in
                        await send(.internal(.didFailFeatureAction(.authenticationAttemptDidNotSucceed)))
                    }
                }
            }
            
            NestedAction(\.destination) { state, action in
                switch action {
                case .presented(.signIn(.delegate(
                    .didRequestAppleSignIn(let controller)))):
                    return .send(
                        .internal(.didRequestAppleSignIn(controller))
                    )
                    
                case .presented(.signIn(.delegate(
                    .didRequestGoogleSignIn(let controller)))):
                    return .send(
                        .internal(.didRequestGoogleSignIn(controller))
                    )
                    
                case .presented(.signUp(.delegate(
                    .navigateToSignIn))):
                    return .send(
                        .internal(.didRequestSignInScreen)
                    )
                    
                case .presented(.signUp(.delegate(
                    .navigateToSetUp))):
                    return .send(
                        .internal(.didRequestSetUpScreen)
                    )
                case .dismiss:
                    return .none
                case .presented(.signIn(.view(_))):
                    return .none
                case .presented(.signIn(.delegate(.navigateToSetUp))):
                    return .none
                case .presented(.signIn(.delegate(.navigateToDiary))):
                    return .none
                case .presented(.signIn(.delegate(.navigateToSignUp))):
                    return .none
                case .presented(.signIn(.internal(_))):
                    return .none
                case .presented(.signUp(.view(_))):
                    return .none
                case .presented(.signUp(.delegate(.navigateToDiary))):
                    return .none
                case .presented(.signUp(.internal(_))):
                    return .none
                case .presented(.setUp(_)):
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Account {
    public enum FeatureError: LocalizedError {
        case authenticationAttemptDidNotSucceed
    }
}
