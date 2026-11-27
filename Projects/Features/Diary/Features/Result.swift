import ComposableArchitecture
import Foundation
import OSLog
import Persistence

@Reducer
public struct Result {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared(.appStorage("client_uid")) var uid = ""
        var isSaving = false
        var saveError: String?
        var dialogues: [Dialogue]
        var entry: Entry?
        var editable: Bool
        var title: String = ""
        var content: String = ""
        
        public init(entry: Entry? = nil, editable: Bool = false, dialogues: [Dialogue] = []) {
            self.dialogues = dialogues
            self.entry = entry
            self.editable = editable
        }
    }
    
    public enum Action: BindableAction, Equatable, Sendable {
        case didAppear
        case didTapEditButton
        case didTapSaveButton
        case didTapBackButton
        
        case didTapNavigateToDiary
        
        case didSaveEntry
        case didFailSaving
        
        case didReceiveEntryNil
        
        case binding(BindingAction<State>)
    }
    
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.entryStore) private var entryStore
    
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
                guard let entry = state.entry, !state.isSaving else { return .none }
                guard !state.uid.isEmpty else {
                    state.saveError = "Sign in again before saving your diary."
                    return .none
                }
                state.isSaving = true
                state.saveError = nil
                let ownerID = state.uid
                let record = StoredEntry(
                    id: entry.id,
                    title: state.title,
                    content: state.content,
                    createdAt: entry.createdAt,
                    dialogues: state.dialogues.map {
                        StoredDialogue(id: $0.id, content: $0.content, createdAt: $0.createdAt, role: $0.role)
                    }
                )
                return .run { send in
                    do {
                        try await entryStore.save(record, ownerID)
                        await send(.didSaveEntry)
                    } catch {
                        await send(.didFailSaving)
                    }
                }
            case .didSaveEntry:
                state.isSaving = false
                if var entry = state.entry {
                    entry.title = state.title
                    entry.content = state.content
                    state.entry = entry
                }
                return .none
            case .didFailSaving:
                state.isSaving = false
                state.saveError = "Your diary couldn’t be saved. Your draft is still here. Tap Save to try again."
                return .none

            case .didTapBackButton:
                return .run { _ in await dismiss() }
                
            case .didReceiveEntryNil:
                state.editable = false
                state.title = ""
                state.content = ""
                return .none

            case .didTapEditButton:
                guard state.entry != nil, !state.isSaving else { return .none }
                state.editable.toggle()
                return .none
            default:
                return .none
            }
        }
    }
}
