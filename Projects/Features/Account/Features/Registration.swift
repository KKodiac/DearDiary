import ComposableArchitecture
import Auth
import Foundation
import OSLog

@Reducer
public struct Registration: Sendable {
    private let logger = Logger(
        subsystem: "com.bibumtiger.deardiary",
        category: "Registration"
    )
    @ObservableState
    public struct State: Sendable, Equatable {
        var isSubmitting = false
        var signUp: SignUp.State
        @Presents var alert: AlertState<Action.Alert>?
        
        var email: String
        var name: String
        var password: String
        var confirmPassword: String
        var isPresented: Bool
        
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
            self.signUp = SignUp.State()
        }
    }
    
    public enum Action: ViewAction, Sendable, Equatable {
        case alert(PresentationAction<Alert>)
        
        case view(ViewActions)
        case delegate(DelegateActions)
        case `internal`(InternalActions)
        
        public enum ViewActions: BindableAction, Sendable, Equatable {
            case didTapSignUpWithEmail
            
            case didTapNavigateToBack
            case didTapNavigateToSignIn
            
            case binding(BindingAction<State>)
        }
        
        public enum InternalActions: Sendable, Equatable {
            case signUp(SignUp.Action)
        }
        
        @CasePathable
        public enum DelegateActions: Sendable, Equatable {
            case navigateToSetUp
            case navigateToSignIn
        }
        
        @CasePathable
        public enum Alert: Sendable {
            case signUpError
        }
    }
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.authClient) private var authClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didTapSignUpWithEmail:
                    guard !state.isSubmitting else { return .none }
                    state.isSubmitting = true
                    return SignUp()
                        .signUpWithEmail(
                            state: &state.signUp,
                            email: state.email,
                            password: state.password,
                            confirmPassword: state.confirmPassword
                        )
                        .map { Action.internal(.signUp($0)) }
                case .didTapNavigateToBack:
                    guard !state.isSubmitting else { return .none }
                    return .run { _ in await dismiss() }
                case .didTapNavigateToSignIn:
                    guard !state.isSubmitting else { return .none }
                    return .send(.delegate(.navigateToSignIn))
                case .binding:
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .signUp(.delegate(.navigateToSetup)):
                    state.isSubmitting = false
                    return .send(.delegate(.navigateToSetUp))
                case .signUp(.delegate(.didThrowError(let error))):
                    state.isSubmitting = false
                    guard let message = error.userMessage else { return .none }
                    state.alert = AlertState {
                        TextState("Couldn’t create your account")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState(message)
                    }
                    return .none
                }
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

public extension Registration {
    enum FeatureError: LocalizedError {
        case passwordConfirmationDoesNotMatch
    }
}
