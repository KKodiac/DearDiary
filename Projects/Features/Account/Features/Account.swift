import AuthenticationServices
import ComposableArchitecture
import Auth
import Foundation
import SwiftUI

@Reducer
public struct Account {
    @ObservableState
    public struct State: Sendable, Equatable {
        var isSubmitting = false
        var signIn: SignIn.State
        
        @Presents var destination: Destination.State?
        @Shared var isInitialUser: Bool
        @Shared var clientUID: String
        @Shared var diaryName: String
        
        var error: FeatureError? = nil
        
        public init(
            destination: Destination.State? = nil,
            isInitialUser: @autoclosure () -> Bool = true,
            clientUID: @autoclosure () -> String = "",
            diaryName: @autoclosure () -> String = ""
        ) {
            self._isInitialUser = Shared(
                wrappedValue: isInitialUser(),
                .appStorage("is_initial_user")
            )
            self._diaryName = Shared(
                wrappedValue: diaryName(),
                .appStorage("diary_name")
            )
            self._clientUID = Shared(
                wrappedValue: clientUID(),
                .appStorage("client_uid")
            )
            self.destination = destination
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
        case authentication(Authentication)
        case registration(Registration)
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
                        try authClient.configure()
                    } catch: { _, send in
                        await send(.internal(.didThrowError(.authClientFailedToConfigure)))
                    }
                    
                case .didReceiveOpenURL(_):
                    return .none
                    
                case .didTapSignInWithGoogle:
                    guard !state.isSubmitting else { return .none }
                    state.isSubmitting = true
                    state.error = nil
                    return SignIn()
                        .signInWithGoogle(state: &state.signIn)
                        .map { Action.internal(.signIn($0)) }
                    
                case .didTapSignInWithApple:
                    guard !state.isSubmitting else { return .none }
                    state.isSubmitting = true
                    state.error = nil
                    return SignIn()
                        .signInWithApple(state: &state.signIn)
                        .map { Action.internal(.signIn($0)) }
                    
                case .didTapSignInWithEmail:
                    guard !state.isSubmitting else { return .none }
                    state.destination = .authentication(Authentication.State(clientUID: state.$clientUID))
                    return .none
                    
                case .didTapSignUpWithEmail:
                    guard !state.isSubmitting else { return .none }
                    state.destination = .registration(Registration.State())
                    return .none
                    
                case .binding:
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .signIn(.delegate(.navigateToSetup)):
                    state.isSubmitting = false
                    state.destination = .setUp(Setup.State())
                    return .none
                    
                case .signIn(.delegate(.navigateToDiary)):
                    state.isSubmitting = false
                    return .send(.delegate(.navigateToDiary))
                    
                case .signIn(.delegate(.didThrowError(let error))):
                    state.isSubmitting = false
                    if error.userMessage != nil {
                        state.error = .signInThrewError(error)
                    }
                    return .none
                    
                case .didThrowError(let error):
                    state.error = error
                    return .none
                }
            }
            
            NestedAction(\.destination) { state, action in
                switch action {
                case \.authentication.delegate.navigateToSignUp:
                    state.destination = .registration(Registration.State())
                    return .none
                case \.authentication.delegate.navigateToSetUp:
                    state.destination = .setUp(Setup.State())
                    return .none
                case \.authentication.delegate.navigateToDiary:
                    return .send(.delegate(.navigateToDiary))
                case  \.registration.delegate.navigateToSignIn:
                    state.destination = .authentication(Authentication.State(clientUID: state.$clientUID))
                    return .none
                case \.registration.delegate.navigateToSetUp:
                    state.destination = .setUp(Setup.State())
                    return .none
                case \.setUp.delegate.navigateToDiary:
                    return .send(.delegate(.navigateToDiary))
                case .dismiss:
                    return .none
                case .presented:
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    public init() { }
}

extension Account {
    public enum FeatureError: LocalizedError {
        case authenticationAttemptDidNotSucceed
        case authClientFailedToConfigure
        case unknown
        
        // MARK: Child Feature Errors
        case signInThrewError(SignIn.FeatureError)
        
        var userMessage: String? {
            switch self {
            case .signInThrewError(let error):
                return error.userMessage
            case .authClientFailedToConfigure:
                return "Sign-in is unavailable. Please try again later."
            case .authenticationAttemptDidNotSucceed, .unknown:
                return "Something went wrong. Please try again."
            }
        }

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
