import ComposableArchitecture
import Foundation
import OSLog

@Reducer
public struct Result: Sendable {
    @ObservableState
    public struct State: Sendable {
        var entry: Entry?
        var editable: Bool
        var title: String = ""
        var content: String = ""
        
        public init(entry: Entry? = nil, editable: Bool = false) {
            self.entry = entry
            self.editable = editable
        }
    }
    
    public enum Action: BindableAction, Sendable {
        case didAppear
        case didTapEditButton
        case didTapSaveButton
        case didTapBackButton
        
        case didTapNavigateToDiary
        
        case didSaveEntry
        
        case didReceiveEntryNil
        
        case binding(BindingAction<State>)
    }
    
    
    @Dependency(\.dismiss) private var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didAppear:
                guard let entry = state.entry else {
                    return .send(.didReceiveEntryNil)
                }
                state.title = entry.title
                state.content = entry.content
                return .none
                
            case .didTapSaveButton:
                guard let _ = state.entry else {
                    return .none
                }
                return .run { send in
                    await send(.didSaveEntry)
                }
                
            case .didTapBackButton:
                return .run { _ in await dismiss() }
                
            case .didTapEditButton:
                state.editable.toggle()
                return .none
            default:
                return .none
            }
        }
    }
}
