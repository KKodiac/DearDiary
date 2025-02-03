import AuthenticationServices
import ExternalDependencies
import InternalDependencies
import SwiftUI

import OSLog

@Reducer
public struct Authentication {
    public init() { }
    
    @ObservableState
    public struct State: Sendable, Equatable {
        var signIn: SignIn.State
        
        @Presents var alert: AlertState<Action.Alert>?
        
        @Shared var user: String
        @Shared var email: String
        @Shared var password: String
        @Shared var clientUID: String
        
        init(
            user: String = "",
            email: String = "",
            password  : String = "",
            clientUID: Shared<String>
        ) {
            self._user = Shared(user)
            self._email = Shared(email)
            self._password = Shared(password)
            self._clientUID = clientUID
            self.signIn = SignIn.State(
                clientUID: clientUID
            )
        }
    }
    
    public enum Action: ViewAction, Sendable, Equatable {
        case alert(PresentationAction<Alert>)
        
        case view(ViewActions)
        case delegate(DelegateActions)
        case `internal`(InternalActions)
        
        public enum ViewActions: BindableAction, Sendable, Equatable {
            case didTapSignInWithApple
            case didTapSignInWithGoogle
            case didTapSignInWithEmail
            
            case didTapNavigateToBack
            case didTapNavigateToSignUp
            
            case binding(BindingAction<State>)
        }
        
        @CasePathable
        public enum DelegateActions: Sendable, Equatable {
            case navigateToSetUp
            case navigateToDiary
            case navigateToSignUp
        }
        
        public enum InternalActions: Sendable, Equatable {
            case signIn(SignIn.Action)
        }
        
        @CasePathable
        public enum Alert: Sendable {
            case signInError
        }
    }
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.authClient) private var authClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didTapSignInWithApple:
                    return SignIn()
                        .signInWithApple(state: &state.signIn)
                        .map { Action.internal(.signIn($0)) }
                    
                case .didTapSignInWithGoogle:
                    return SignIn()
                        .signInWithGoogle(state: &state.signIn)
                        .map { Action.internal(.signIn($0)) }
                    
                case .didTapSignInWithEmail:
                    return SignIn()
                        .signInWithEmail(
                            state: &state.signIn,
                            email: state.email,
                            password: state.password
                        )
                        .map { Action.internal(.signIn($0)) }
                    
                case .didTapNavigateToBack:
                    return .run { send in
                        await dismiss()
                    }
                    
                case .didTapNavigateToSignUp:
                    return .send(.delegate(.navigateToSignUp))
                    
                case .binding:
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .signIn(.delegate(.navigateToSetup)):
                    return .send(.delegate(.navigateToSetUp))
                case .signIn(.delegate(.navigateToDiary)):
                    return .send(.delegate(.navigateToDiary))
                case .signIn(.delegate(.didThrowError(let error))):
                    state.alert = AlertState {
                        TextState("Sign In Error")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("Ok")
                        }
                    } message: {
                        TextState("Sign In Attempt Failed: \(error.localizedDescription)")
                    }
                    return .none
                }
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension Authentication {
    public enum FeatureError: LocalizedError {
        case unknown
        
        // MARK: Child Feature Errors
        case signInThrewError(SignIn.FeatureError)
        
        public init(error: Error) {
            switch error {
            case let error as SignIn.FeatureError:
                self = .signInThrewError(error)
            default:
                self = .unknown
            }
        }
    }
}
