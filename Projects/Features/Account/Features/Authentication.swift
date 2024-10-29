import AuthenticationServices
import FirebaseAuth
import ExternalDependencies
import SwiftUI

@Reducer
public struct Authentication: Sendable {
    public init() { }
    @ObservableState
    public struct State: Sendable {
        @Shared(.appStorage("uid")) var uid: String = ""
        @Shared var user: String
        var email: String
        var password: String
        
        var error: Authentication.FeatureError?
        var isPresented: Bool
        
        init(
            user: String = "",
            email: String = "",
            password: String = "",
            error: Authentication.FeatureError? = nil,
            isPresented: Bool = false
        ) {
            self._user = Shared(user)
            self.email = email
            self.password = password
            self.error = error
            self.isPresented = isPresented
        }
    }
    
    public enum Action: Sendable, ViewAction {
        case view(_ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
        
        public enum _ViewAction: BindableAction, Sendable {
            case didTapSignInWithApple(AuthorizationController)
            case didTapSignInWithGoogle(UIViewController?)
            case didTapSignInWithEmail
            
            
            case didTapNavigateToBack
            case didTapNavigateToSignUp
            
            case binding(BindingAction<State>)
        }
        
        public enum DelegateAction: Sendable {
            case didRequestGoogleSignIn(UIViewController?)
            case didRequestAppleSignIn(AuthorizationController)
            
            case navigateToSetUp
            case navigateToDiary
            case navigateToSignUp
        }
        
        public enum InternalAction: Sendable {
            case didRequestGoogleSignIn(UIViewController?)
            case didRequestAppleSignIn(AuthorizationController)
            
            case didSucceedSignIn(String)
            case didFailFeatureAction(Authentication.FeatureError)
        }
    }
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.google) private var google
    @Dependency(\.firebase) private var firebase
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.delegate) { state, action in
                switch action {
                case .didRequestGoogleSignIn(let viewController):
                    return .send(.internal(.didRequestGoogleSignIn(viewController)))
                    
                case .didRequestAppleSignIn(let controller):
                    return .send(.internal(.didRequestAppleSignIn(controller)))

                case .navigateToSetUp:
                    return .none
                    
                case .navigateToDiary:
                    return .none
                    
                case .navigateToSignUp:
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .didRequestGoogleSignIn(let viewController):
                    guard let viewController else { return .none }
                    return .run { send in
                        let result = try await google.signIn(withPresenting: viewController)
                        if let token = result.user.idToken {
                            let tokenString = result.user.accessToken.tokenString
                            let credential = GoogleAuthProvider.credential(
                                withIDToken: token.tokenString,
                                accessToken: tokenString
                            )
                            let result = try await firebase
                                .authenticateWithFirebaseAuthSocialProvider(
                                    credential
                                )
                            await send(.internal(.didSucceedSignIn(result.user.uid)))
                        }
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
                    
                case .didSucceedSignIn(let userId):
                    state.uid = userId
                    return .none
                    
                case .didFailFeatureAction(let error):
                    state.error = error
                    return .none
                }
            }
            
            NestedAction(\.view) { state, action in
                switch action {
                case .didTapSignInWithApple(let controller):
                    return .send(.internal(.didRequestAppleSignIn(controller)))
                    
                case .didTapSignInWithGoogle(let viewController):
                    return .send(
                        .internal(.didRequestGoogleSignIn(viewController))
                    )
                    
                case .didTapSignInWithEmail:
                    let credential = EmailCredential(
                        email: state.email,
                        password: state.password
                    )
                    return .run { send in
                        let result = try await firebase
                            .authenticateWithFirebaseAuthEmail(
                                credential
                            )
                        await send(.internal(.didSucceedSignIn(result.user.uid)))
                    } catch: { _, send in
                        await send(.internal(.didFailFeatureAction(.authenticationAttemptDidNotSucceed)))
                    }
                    
                    
                case .didTapNavigateToBack:
                    return .run { send in
                        await dismiss()
                    }
                    
                case .didTapNavigateToSignUp:
                    return .none
                    
                case .binding(_):
                    return .none
                }
            }
        }
    }
}

public extension Authentication {
    enum FeatureError: LocalizedError {
        case authenticationAttemptDidNotSucceed
    }
}
