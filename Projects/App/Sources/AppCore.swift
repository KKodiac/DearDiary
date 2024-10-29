import Account
import Diary
import ComposableArchitecture
import Foundation

@Reducer
struct DearDiary: Sendable {
    @ObservableState
    struct State: Sendable {
        @Shared(.appStorage("uid")) var uid = ""
        @Shared(.appStorage("needs_initial_setup")) var needsInitialSetup = true
        @Shared(.appStorage("diary_name")) var diaryName = ""
        
        
        @Presents var destination: Destination.State?
    }
    
    enum Action: Sendable {
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
            case .destination(.presented(.auth(.delegate(.navigateToDiary)))):
                state.destination = .diary(Diary.State())
                return .none
            case .destination(.presented(.auth(.destination(
                .presented(.signUp(.delegate(.navigateToDiary))))))):
                state.destination = .diary(Diary.State())
                return .none
            case .destination(.presented(.auth(.destination(
                .presented(.signIn(.delegate(.navigateToDiary))))))):
                state.destination = .diary(Diary.State())
                return .none
            case .destination(.presented(.auth(.destination(
                .presented(.setUp(.delegate(.navigateToDiary))))))):
                state.destination = .diary(Diary.State())
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
    
    @Reducer
    struct Destination: Sendable {
        enum State: Sendable {
            case auth(Account.State)
            case diary(Diary.State)
        }
        
        enum Action: Sendable {
            case auth(Account.Action)
            case diary(Diary.Action)
        }
        
        var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }
}
