import ComposableArchitecture
import Foundation
import ExternalDependencies

@Reducer
public struct Setup: Sendable {
    public init() { }
    @ObservableState
    public struct State: Sendable {
        var expanded: Bool
        var personalities: [Personality]
        
        @Shared var name: String
        @Shared var personality: Personality
        @Shared(.appStorage("uid")) var uid = ""
        
        init(
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
    
    public enum Action: ViewAction, Sendable {
        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
        
        public enum ViewAction: Sendable, BindableAction {
            case didAppear
            case didTapPicker(Personality)
            case didTapGetStarted
            
            case binding(_ action: BindingAction<State>)
        }
        
        public enum DelegateAction: Sendable {
            case navigateToDiary
        }
        
        public enum InternalAction: Sendable { }
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
