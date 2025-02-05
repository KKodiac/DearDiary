import ComposableArchitecture
import Foundation
import ExternalDependencies

@Reducer
public struct Setup: Sendable {
    public init() { }
    @ObservableState
    public struct State: Sendable, Equatable {
        var expanded: Bool
        var personalities: [Personality]
        
        @Shared var name: String
        @Shared var personality: Personality
        
        public init(
            expanded: Bool = false,
            personalities: [Personality] = [],
            name: String = "",
            personality: Personality = .basic
        ) {
            self.expanded = expanded
            self.personalities = personalities
            self._name = Shared(wrappedValue: name, .appStorage("diary_name"))
            self._personality = Shared(wrappedValue: personality, .appStorage("diary_personality"))
        }
    }
    
    public enum Action: ViewAction, Sendable, Equatable {
        case view(ViewActions)
        case delegate(DelegateActions)
        case `internal`(InternalActions)

        public enum ViewActions: BindableAction, Sendable, Equatable {
            case didAppear
            case didTapPicker(Personality)
            case didTapGetStarted
            
            case binding(_ action: BindingAction<State>)
        }
        
        @CasePathable
        public enum DelegateActions: Sendable, Equatable {
            case navigateToDiary
        }
        
        public enum InternalActions: Sendable, Equatable { }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                    case .didAppear:
                        return .none
                    case .didTapPicker(let personality):
                        state.personality = personality
                        state.expanded.toggle()
                        return .none
                    case .didTapGetStarted:
                        return .send(.delegate(.navigateToDiary))
                    case .binding(_):
                        return .none
                }
            }
        }
    }
}
