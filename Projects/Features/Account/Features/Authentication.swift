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
        var signIn: SignIn.State
        
        @Shared var user: String
        
        @Shared var email: String
        @Shared var password: String
        
        var isPresented: Bool
        
        init(
            user: String = "",
            email: String = "",
            password  : String = "",
            isPresented: Bool = false,
            clientUID: Shared<String>
        ) {
            self._user = Shared(user)
            self._email = Shared(email)
            self._password = Shared(password)
            self.isPresented = isPresented
            self.signIn = SignIn.State(
                clientUID: clientUID
            )
        }
    }
    
    public enum Action: ViewAction, Sendable {
        
        
        case view(_ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
        
        public enum _ViewAction: BindableAction, Sendable {
            case didTapSignInWithApple
            case didTapSignInWithGoogle
            case didTapSignInWithEmail
            
            case didTapNavigateToBack
            case didTapNavigateToSignUp
            
            case binding(BindingAction<State>)
        }
        
        public enum DelegateAction: Sendable {
            case navigateToSetUp
            case navigateToDiary
            case navigateToSignUp
        }
        
        public enum InternalAction: Sendable {
            case signIn(SignIn.Action)
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
                    return .none
                    
                case .binding(_):
                    return .none
                }
            }
        }
    }
}

@Reducer
public struct SignIn: Sendable {
    private let logger = Logger(
        subsystem: "com.bibumtiger.deardiary",
        category: "SignIn"
    )
    
    @Dependency(\.authClient) private var authClient
    
    public struct State {
        @Shared var isInitialUser: Bool
        @Shared var clientUID: String
        
        public init(
            isInitialUser: @autoclosure () -> Bool = true,
            clientUID: Shared<String>
        ) {
            self._isInitialUser = Shared(
                wrappedValue: isInitialUser(),
                .appStorage("is_initial_user")
            )
            self._clientUID = clientUID
        }
    }
    
    public enum Action : Sendable {
        case delegate(DelegateAction)
        
        public enum DelegateAction: Sendable {
            case navigateToDiary
            case navigateToSetup
            case didThrowError(FeatureError)
        }
    }
}

extension SignIn {
    func signInWithApple(state: inout State) -> Effect<Action> {
        return .run { [state] send in
            let clientUID = try await authClient.signInWithApple()
            logger.log("Client UID: \(clientUID)")
            await state.$clientUID.withLock { $0 = clientUID }
        } catch: { error, send in
            logger.error("Error: \(error)")
        }
    }
    
    func signInWithGoogle(state: inout State) -> Effect<Action> {
        return .run { [state] send in
            let clientUID = try await authClient.signInWithGoogle()
            logger.log("Client UID: \(clientUID)")
            await state.$clientUID.withLock { $0 = clientUID }
        } catch: { error, send in
            logger.error("Error: \(error)")
        }
    }
    
    func signInWithEmail(state: inout State, email: String, password: String) -> Effect<Action> {
        return .run { [state] send in
            let clientUID = try await authClient.signInWithEmail(
                email: email,
                password: password
            )
            logger.log("Client UID: \(clientUID)")
            await state.$clientUID.withLock { $0 = clientUID }
        } catch: { error, send in
            logger.error("Error: \(error)")
        }
    }
}

extension SignIn {
    public enum FeatureError: LocalizedError {
        case authClientError(AuthError)
    }
}
