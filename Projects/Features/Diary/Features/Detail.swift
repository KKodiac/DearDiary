import ComposableArchitecture

@Reducer
public struct Detail: Sendable {
    public init() { }
    @ObservableState
    public struct State: Sendable {
        var entry: Entry
        var editable: Bool
        public init(
            entry: Entry,
            editable: Bool = false
        ) {
            self.entry = entry
            self.editable = editable
        }
    }
    
    public enum Action: Sendable, BindableAction {
        case didTapBackButton
        
        case didTapSaveButton
        case didTapEditButton
        
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.dismiss) private var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .didTapBackButton:
                return .run { _ in
                    await dismiss()
                }
                
            case .didTapEditButton:
                state.editable.toggle()
                return .none
                
            case .didTapSaveButton:
                let entry = state.entry
                return .run { send in
                    await dismiss()
                }
                
            default:
                return .none
            }
        }
    }
}
