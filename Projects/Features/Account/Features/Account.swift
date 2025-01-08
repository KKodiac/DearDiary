import AuthenticationServices
import ExternalDependencies
import Auth
import Foundation
import SwiftUI

@Reducer
public struct Account {
    public init() { }
    @ObservableState
    public struct State: Sendable, Equatable {
        var signIn: SignIn.State
        
        @Presents var destination: Destination.State?
        @Shared var isInitialUser: Bool
        @Shared var clientUID: String
        
        var error: FeatureError? = nil
        
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
            self.signIn = SignIn.State(clientUID: self._clientUID)
        }
    }
    
    public enum Action: ViewAction, Sendable, Equatable {
        case destination(PresentationAction<Destination.Action>)
        
        case view(ViewActions)
        case delegate(DelegateActions)
        case `internal`(InternalActions)
        
        
        public enum ViewActions: BindableAction, Sendable, Equatable {
            case didAppear
            case didReceiveOpenURL(URL)
            case didTapSignInWithGoogle
            case didTapSignInWithApple
            case didTapSignInWithEmail
            case didTapSignUpWithEmail
            
            case binding(BindingAction<State>)
        }
        
        @CasePathable
        public enum DelegateActions: Sendable, Equatable {
            case navigateToDiary
        }
        
        public enum InternalActions: Sendable, Equatable {
            case signIn(SignIn.Action)
            
            case didThrowError(FeatureError)
        }
    }
    
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case signIn(Authentication)
        case signUp(Registration)
        case setUp(Setup)
    }
    
    @Dependency(\.defaultAppStorage) private var appStorage
    @Dependency(\.authClient) private var authClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didAppear:
                    return .run(priority: .userInitiated) { @MainActor send in
                        authClient.configure()
                    } catch: { error, send in
                        let error = FeatureError(error: error)
                        await send(.internal(.didThrowError(error)))
                    }
                case .didReceiveOpenURL(_):
                    return .none
                    
                case .didTapSignInWithGoogle:
                    return SignIn()
                        .signInWithGoogle(state: &state.signIn)
                        .map { Action.internal(.signIn($0)) }
                    
                case .didTapSignInWithApple:
                    return SignIn()
                        .signInWithApple(state: &state.signIn)
                        .map { Action.internal(.signIn($0)) }
                    
                case .didTapSignInWithEmail:
                    state.destination = .signIn(Authentication.State(clientUID: state.$clientUID))
                    return .none
                    
                case .didTapSignUpWithEmail:
                    state.destination = .signUp(Registration.State())
                    return .none
                    
                case .binding:
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .signIn(.delegate(.navigateToSetup)):
                    state.destination = .setUp(Setup.State())
                    return .none
                    
                case .signIn(.delegate(.navigateToDiary)):
                    return .send(.delegate(.navigateToDiary))
                    
                case .signIn(.delegate(.didThrowError(let error))):
                    state.error = FeatureError(error: error)
                    return .none
                    
                case .didThrowError(let error):
                    state.error = error
                    return .none
                }
            }
            
            NestedAction(\.destination) { state, action in
                switch action {
                case  \.signUp.delegate.navigateToSignIn:
                    state.destination = .signIn(Authentication.State(clientUID: state.$clientUID))
                    return .none
                case .dismiss:
                    return .none
                case \.signIn.delegate.navigateToSignUp:
                    state.destination = .signUp(Registration.State())
                    return .none
                case .presented(_):
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .onChange(of: \.clientUID) { oldValue, newValue in
            Reduce { state, action in
                guard state.isInitialUser else {
                    return .send(.delegate(.navigateToDiary))
                }
                state.destination = .setUp(Setup.State())
                return .none
            }
        }
        ._printChanges()
    }
}

extension Account {
    public enum FeatureError: LocalizedError {
        case authenticationAttemptDidNotSucceed
        case authClientFailedToConfigure
        case unknown
        
        // MARK: Child Feature Errors
        case signInThrewError(SignIn.FeatureError)
        
        public init(error: Error) {
            switch error {
                case let error as SignIn.FeatureError:
                    self = .signInThrewError(error)
                case _ as FirebaseAuthError:
                    self = .authClientFailedToConfigure
            default:
                self = .unknown
            }
        }
    }
}

extension Account.FeatureError: Equatable { }
