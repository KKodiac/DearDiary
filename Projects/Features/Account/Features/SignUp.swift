import ComposableArchitecture
import Auth
import Foundation
import OSLog

@Reducer
public struct SignUp {
    private let logger = Logger(
        subsystem: "com.bibumtiger.deardiary",
        category: "SignUp"
    )
    
    public struct State: Sendable, Equatable {
        @Shared var isInitialUser: Bool
        @Shared var clientUID: String
        
        public init(
            isInitialUser: @autoclosure () -> Bool = true,
            clientUID: @autoclosure () -> String = ""
        ) {
            self._isInitialUser = Shared(
                wrappedValue: isInitialUser(),
                .appStorage("is_initial_user")
            )
            self._clientUID = Shared(
                wrappedValue: clientUID(),
                .appStorage("client_uid")
            )
        }
    }
    
    public enum Action : Sendable, Equatable {
        case delegate(DelegateActions)
        
        @CasePathable
        public enum DelegateActions: Sendable, Equatable {
            case navigateToSetup
            case didThrowError(FeatureError)
        }
    }
    
    @Dependency(\.authClient) private var authClient
}

extension SignUp {
    func signUpWithEmail(state: inout State, email: String, password: String, confirmPassword: String) -> Effect<Action> {
        return .run { [state] send in
            let authData = try await authClient.signUpWithEmail(
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
            
            let clientUID = authData.user.uid
            await state.$clientUID.withLock { $0 = clientUID }
            
            guard let isNewUser = authData.additionalUserInfo?.isNewUser, isNewUser else {
                logger.error("Additional user information is unavailable after registration.")
                throw AuthError.unExpectedError(FeatureError.unknown)
            }
            
            logger.log("New User: \(isNewUser)")
            await state.$isInitialUser.withLock { $0 = isNewUser }
            if isNewUser { await send(.delegate(.navigateToSetup)) }
        } catch: { error, send in
            logger.error("Email registration failed.")
            await send(.delegate(.didThrowError(FeatureError(error: error))))
        }
    }
}

extension SignUp {
    public enum FeatureError: LocalizedError {
        case authClientError(AuthError)
        case unknown
        
        var userMessage: String? {
            switch self {
            case let .authClientError(error): return error.userMessage
            case .unknown: return "Something went wrong. Please try again."
            }
        }

        public init(error: Error) {
            self = .authClientError(AuthError(error: error))
        }
    }
}

extension SignUp.FeatureError: Equatable { }
