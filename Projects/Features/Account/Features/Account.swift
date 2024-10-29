import AuthenticationServices
import ExternalDependencies
import Foundation
import SwiftUI

@Reducer
public struct Account {
    public init() { }
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?
        @Shared(.appStorage("uid")) var uid = ""
        public init() { }
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case test
        case view(ViewActions)
        case delegate(DelegateActions)
        case `internal`(InternalActions)
        
        
        case binding(BindingAction<State>)
        
        public enum ViewActions: Sendable {
            case didReceiveOpenURL(URL)
            case didTapSignInWithGoogle(UIViewController?)
            case didTapSignInWithApple(AuthorizationController)
            case didTapSignInWithEmail
            case didTapSignUpWithEmail
        }
        
        public enum DelegateActions: Sendable {
            case navigateToDiary
        }
        
        public enum InternalActions: Sendable {
            case didAppInitialize
            case didSucceedSignIn(User)
        }
    }
    
    
    @Reducer
    public enum Destination: Sendable {
        case signIn(Authentication)
        case signUp(Registration)
        case setUp(Setup)
//        @ObservableState
//        public enum State: Sendable {
//            case signIn(Authentication.State)
//            case signUp(Registration.State)
//            case setUp(Setup.State)
//        }
//        
//        @CasePathable
//        public enum Action: Sendable {
//            case signIn(Authentication.Action)
//            case signUp(Registration.Action)
//            case setUp(Setup.Action)
//        }
    }
    
    @Dependency(\.defaultAppStorage) private var appStorage
    @Dependency(\.google) private var google
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didReceiveOpenURL(let url):
                    google.handle(url)
                    return .none
                case .didTapSignInWithGoogle(let viewController):
                    return .send(
                        .destination(
                            .presented(
                                .signIn(.delegate(.didRequestGoogleSignIn(viewController)))
                            )
                        )
                    )
                case .didTapSignInWithApple(let controller):
                    return .send(
                        .destination(
                            .presented(
                                .signIn(.delegate(.didRequestAppleSignIn(controller)))
                            )
                        )
                    )
                case .didTapSignInWithEmail:
                    state.destination = .signIn(Authentication.State())
                    return .none
                case .didTapSignUpWithEmail:
                    state.destination = .signUp(Registration.State())
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                default: return .none
                }
            }
            
            NestedAction(\.delegate) { state, action in
                switch action {
                default: return .none
                }
            }
            
            NestedAction(\.destination) { state, action in
                switch action {
                case .dismiss:
                    return .none
                case .presented(.signIn(.delegate(.navigateToSignUp))):
                    state.destination = .signUp(Registration.State())
                    return .none
                case .presented(.signIn(.delegate(.navigateToSetUp))):
                    state.destination = .setUp(Setup.State())
                    return .none
                case .presented(.signUp):
                    return .none
                case .presented(.setUp):
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}

extension Account {
    enum FeatureError: Error {
        
    }
}
