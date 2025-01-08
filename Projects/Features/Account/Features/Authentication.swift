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
        
        @Shared var user: String
        
        @Shared var email: String
        @Shared var password: String
        @Shared var clientUID: String
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
            self._clientUID = clientUID
            self.signIn = SignIn.State(
                clientUID: clientUID
            )
        }
    }
    
    public enum Action: ViewAction, Sendable, Equatable {
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
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .signIn(.delegate(.navigateToSetup)):
                    return .send(.delegate(.navigateToSetUp))
                case .signIn(.delegate(.navigateToDiary)):
                    return .send(.delegate(.navigateToDiary))
                case .signIn(.delegate(.didThrowError(_))):
                    return .none
                }
            }
        }
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

@Reducer
public struct SignIn: Sendable {
    private let logger = Logger(
        subsystem: "com.bibumtiger.deardiary",
        category: "SignIn"
    )
    
    @Dependency(\.authClient) private var authClient
    
    public struct State: Equatable {
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
    
    public enum Action : Sendable, Equatable {
        case delegate(DelegateActions)
        
        @CasePathable
        public enum DelegateActions: Sendable, Equatable {
            case navigateToDiary
            case navigateToSetup
            case didThrowError(FeatureError)
        }
    }
}

extension SignIn {
    func signInWithApple(state: inout State) -> Effect<Action> {
        return .run { [state] send in
            let authData = try await authClient.signInWithApple()
            
            let clientUID = authData.user.uid
            logger.log("Client UID: \(clientUID)")
            await state.$clientUID.withLock { $0 = clientUID }
            
            if let isNewUser = authData.additionalUserInfo?.isNewUser {
                logger.log("New User: \(isNewUser)")
                await state.$isInitialUser.withLock { $0 = isNewUser }
                if isNewUser { await send(.delegate(.navigateToSetup)) }
            }
            await send(.delegate(.navigateToDiary))
        } catch: { error, send in
            logger.error("Error: \(error)")
            await send(.delegate(.didThrowError(FeatureError(error: error))))
        }
    }
    
    func signInWithGoogle(state: inout State) -> Effect<Action> {
        return .run { [state] send in
            let authData = try await authClient.signInWithGoogle()
            
            let clientUID = authData.user.uid
            logger.log("Client UID: \(clientUID)")
            await state.$clientUID.withLock { $0 = clientUID }
            
            if let isNewUser = authData.additionalUserInfo?.isNewUser {
                logger.log("New User: \(isNewUser)")
                await state.$isInitialUser.withLock { $0 = isNewUser }
                if isNewUser { await send(.delegate(.navigateToSetup)) }
            }
            await send(.delegate(.navigateToDiary))
        } catch: { error, send in
            logger.error("Error: \(error)")
            await send(.delegate(.didThrowError(FeatureError(error: error))))
        }
    }
    
    func signInWithEmail(state: inout State, email: String, password: String) -> Effect<Action> {
        return .run { [state] send in
            let authData = try await authClient.signInWithEmail(
                email: email,
                password: password
            )
            
            let clientUID = authData.user.uid
            logger.log("Client UID: \(clientUID)")
            await state.$clientUID.withLock { $0 = clientUID }
            
            if let isNewUser = authData.additionalUserInfo?.isNewUser {
                logger.log("New User: \(isNewUser)")
                await state.$isInitialUser.withLock { $0 = isNewUser }
                if isNewUser { await send(.delegate(.navigateToSetup)) }
            }
            await send(.delegate(.navigateToDiary))
        } catch: { error, send in
            logger.error("Error: \(error)")
            await send(.delegate(.didThrowError(FeatureError(error: error))))
        }
    }
}

extension SignIn {
    public enum FeatureError: LocalizedError {
        case authClientError(AuthError)
        
        case unknown
        
        public init(error: Error) {
            switch error {
            case let error as AuthError:
                self = .authClientError(error)
            default:
                self = .unknown
            }
        }
    }
}

extension SignIn.FeatureError: Equatable { }
