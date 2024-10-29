import ComposableArchitecture
import ExternalDependencies
import Foundation

@Reducer
public struct Registration: Sendable {
    public init() { }
    @ObservableState
    public struct State: Sendable {
        @Shared(.appStorage("uid")) var uid = ""
        var email: String
        var name: String
        var password: String
        var confirmPassword: String
        var isPresented: Bool
        var error: Registration.FeatureError?
        
        init(
            email: String = "",
            name: String = "",
            password: String = "",
            confirmPassword: String = "",
            isPresented: Bool = false,
            error: Registration.FeatureError? = nil
        ) {
            self.email = email
            self.name = name
            self.password = password
            self.confirmPassword = confirmPassword
            self.isPresented = isPresented
            self.error = error
        }
    }
    
    public enum Action: Sendable, ViewAction {
        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
        
        public enum ViewAction: Sendable, BindableAction {
            case didTapSignUpWithEmail
            
            case didTapNavigateToBack
            case didTapNavigateToSignIn
            
            case binding(BindingAction<State>)
        }
        
        public enum InternalAction: Sendable {
            case didRequestEmailSignUp
            
            case didSucceedSignUp(String)
            case didFailFeatureError(Registration.FeatureError)
        }
        
        public enum DelegateAction: Sendable {
            case navigateToSetUp
            case navigateToDiary
            case navigateToSignIn
        }
    }
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.firebase) private var firebase
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
            
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didTapSignUpWithEmail:
                    guard state.password == state.confirmPassword else {
                        return .send(.internal(.didFailFeatureError(.passwordConfirmationDoesNotMatch)))
                    }
                    return .send(.internal(.didRequestEmailSignUp))
                case .didTapNavigateToBack:
                    return .run { send in
                        await dismiss()
                    }
                case .didTapNavigateToSignIn:
                    return .send(.delegate(.navigateToSignIn))
                case .binding(_):
                    return .none
                }
            }
            
            NestedAction(\.delegate) { state, action in
                switch action {
                default: return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .didRequestEmailSignUp:
                    let credential = EmailCredential(
                        email: state.email,
                        password: state.password
                    )
                    return .run { send in
                        let result = try await firebase
                            .registerWithFirebaseAuthEmail(
                                credential
                            )
                    }
                case .didSucceedSignUp(let userId):
                    state.uid = userId
                    return .none
                case .didFailFeatureError(_):
                    return .none
                }
            }
        }
    }
}

public extension Registration {
    enum FeatureError: LocalizedError {
        case passwordConfirmationDoesNotMatch
    }
}
