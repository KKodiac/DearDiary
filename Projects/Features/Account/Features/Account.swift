import AuthenticationServices
import ExternalDependencies
import Auth
import Foundation
import SwiftUI

@Reducer
public struct Account {
    public init() { }
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?
        @Shared(.appStorage("uid")) var uid = ""
        @Shared(.appStorage("diary_name")) var diaryName = ""
        
        var error: FeatureError? = nil
        public init() { }
    }
    
    public enum Action: ViewAction {
        case destination(PresentationAction<Destination.Action>)
        
        case view(ViewActions)
        case delegate(DelegateActions)
        case `internal`(InternalActions)
        
        
        public enum ViewActions: BindableAction {
            case didReceiveOpenURL(URL)
            case didTapSignInWithGoogle(UIViewController?)
            case didTapSignInWithApple(AuthorizationController)
            case didTapSignInWithEmail
            case didTapSignUpWithEmail
            
            case binding(BindingAction<State>)
        }
        
        public enum DelegateActions {
            case navigateToDiary
        }
        
        public enum InternalActions {
            case didSucceedSignIn(String)
            
            case didRequestSignInScreen
            case didRequestSignUpScreen
            case didRequestSetUpScreen
            
            case didRequestGoogleSignIn(UIViewController?)
            case didRequestAppleSignIn(AuthorizationController)
            
            case didFailFeatureAction(FeatureError)
        }
    }
    
    
    @Reducer
    public enum Destination {
        case signIn(Authentication)
        case signUp(Registration)
        case setUp(Setup)
    }
    
    @Dependency(\.defaultAppStorage) private var appStorage
    @Dependency(\.authClient.firebase) private var firebase
    @Dependency(\.authClient.apple) private var apple
    @Dependency(\.authClient.google) private var google
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didReceiveOpenURL(let url):
                    return .none
                    
                case .didTapSignInWithGoogle(let viewController):
                    return .run { send in
                        guard let clientID = firebase.clientID else {
                            return
                        }
                        let auth = try await google.login(clientID)
                        let result = try await firebase.signIn(auth)
                    }
                    
                case .didTapSignInWithApple(let controller):
                    return .run { send in
                        let auth = try await apple.login()
                        let result = try await firebase.signIn(auth)
                    }
                    
                case .didTapSignInWithEmail:
                    return .send(
                        .internal(.didRequestSignInScreen)
                    )
                    
                case .didTapSignUpWithEmail:
                    return .send(
                        .internal(.didRequestSignUpScreen)
                    )
                    
                case .binding:
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case .didRequestSignInScreen:
                    state.destination = .signIn(Authentication.State())
                    return .none
                    
                case .didRequestSignUpScreen:
                    state.destination = .signUp(Registration.State())
                    return .none
                    
                case .didRequestSetUpScreen:
                    state.destination = .setUp(Setup.State())
                    return .none
                    
                case .didSucceedSignIn(let userId):
                    state.uid = userId
                    if state.diaryName.isEmpty {
                        state.destination = .setUp(Setup.State())
                        return .none
                    }
                    return .send(.delegate(.navigateToDiary))
                    
                case .didFailFeatureAction(let error):
                    state.error = error
                    return .none
                    
                case .didRequestGoogleSignIn(let viewController):
                    return .run { _ in
                    } catch: { _, send in
                        await send(.internal(.didFailFeatureAction(.authenticationAttemptDidNotSucceed)))
                    }
                case .didRequestAppleSignIn(let controller):
                    return .run { send in
                        
                    } catch: { _, send in
                        await send(.internal(.didFailFeatureAction(.authenticationAttemptDidNotSucceed)))
                    }
                }
            }
            
            NestedAction(\.destination) { state, action in
                switch action {
                case .presented(.signIn(.delegate(
                    .didRequestAppleSignIn(let controller)))):
                    return .send(
                        .internal(.didRequestAppleSignIn(controller))
                    )
                    
                case .presented(.signIn(.delegate(
                    .didRequestGoogleSignIn(let controller)))):
                    return .send(
                        .internal(.didRequestGoogleSignIn(controller))
                    )
                    
                case .presented(.signUp(.delegate(
                    .navigateToSignIn))):
                    return .send(
                        .internal(.didRequestSignInScreen)
                    )
                    
                case .presented(.signUp(.delegate(
                    .navigateToSetUp))):
                    return .send(
                        .internal(.didRequestSetUpScreen)
                    )
                case .dismiss:
                    return .none
                case .presented(.signIn(.view(_))):
                    return .none
                case .presented(.signIn(.delegate(.navigateToSetUp))):
                    return .none
                case .presented(.signIn(.delegate(.navigateToDiary))):
                    return .none
                case .presented(.signIn(.delegate(.navigateToSignUp))):
                    return .none
                case .presented(.signIn(.internal(_))):
                    return .none
                case .presented(.signUp(.view(_))):
                    return .none
                case .presented(.signUp(.delegate(.navigateToDiary))):
                    return .none
                case .presented(.signUp(.internal(_))):
                    return .none
                case .presented(.setUp(_)):
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Account {
    public enum FeatureError: LocalizedError {
        case authenticationAttemptDidNotSucceed
    }
}
