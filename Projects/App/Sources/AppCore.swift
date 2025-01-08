import Account
import Diary
import ComposableArchitecture
import Foundation
import FirebaseAuth
import GoogleSignIn

@Reducer
struct DearDiary {
    @ObservableState
    struct State: Sendable {
        @Shared(.appStorage("uid")) var uid = ""
        @Shared(.appStorage("diary_name")) var diaryName = ""
        
        
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case didAppear
        case navigateToFeature
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.continuousClock) private var runner
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                return .run { send in
                    // Displays splash screen for a second.
                    try await runner.sleep(for: .seconds(1))
                    await send(.navigateToFeature)
                }.animation(.easeIn)
            case .navigateToFeature:
                if state.uid.isEmpty { state.destination = .auth(Account.State()) }
                if !state.diaryName.isEmpty { state.destination = .diary(Diary.State()) }
                return .none
            case \.destination.auth.delegate.navigateToDiary:
                state.destination = .diary(Diary.State())
                return .none
            case \.destination.auth.destination.signUp.delegate.navigateToDiary:
                state.destination = .diary(Diary.State())
                return .none
            case \.destination.auth.destination.signIn.delegate.navigateToDiary:
                state.destination = .diary(Diary.State())
                return .none
            case \.destination.auth.destination.setUp.delegate.navigateToDiary:
                state.destination = .diary(Diary.State())
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .onChange(of: \.uid) { oldValue, newValue in
            
        }
    }
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    enum Destination {
        case auth(Account)
        case diary(Diary)
    }
}
