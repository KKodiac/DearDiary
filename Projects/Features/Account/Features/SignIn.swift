import ExternalDependencies
import InternalDependencies
import Foundation
import OSLog

@Reducer
public struct SignIn {
    private let logger = Logger(
        subsystem: "com.bibumtiger.deardiary",
        category: "SignIn"
    )
    
    @Dependency(\.authClient) private var authClient
    
    public struct State: Sendable, Equatable {
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
