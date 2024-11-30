import AuthenticationServices
import ExternalDependencies
import InternalDependencies
import SwiftUI

import OSLog

@Reducer
public struct Authentication {
    public init() { }
    @ObservableState
    public struct State {
        @Shared(.appStorage("uid")) var uid: String = ""
        @Shared var user: String
        var email: String
        var password: String
        
        var error: FeatureError?
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
            case didSucceedSignIn(String)
            case didFailFeatureAction(Authentication.FeatureError)
        }
    }
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.authClient.apple) private var appleAuthClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.internal) { state, action in
                switch action {
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
                    return .run { send in
                        let credential = try await appleAuthClient.login()
                        
                    } catch: { error, send in
                        
                    }
                    
                case .didTapSignInWithGoogle(let viewController):
                    return .send(
                        .delegate(.didRequestGoogleSignIn(viewController))
                    )
                    
                case .didTapSignInWithEmail:
                    return .run { send in
                   
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
