import Combine
import ComposableArchitecture
import OSLog
import SwiftUI

@Reducer
public struct Memoir: Sendable {
    public init() {}
    @ObservableState
    public struct State: Sendable {
        @Shared(.appStorage("diary_name")) var diaryName: String = "Diary"
        
        var memoirText: String = "Hi"
        var initialized: Bool = false
        var dialogues: [Dialogue] = []
        var progress: Double = 0.0
        var threadId: String?
        var dialogue: String = ""
        var showHeader: Bool = false
        var composing: Bool = false
        
        @Presents var destination: Destination.State?
    }
    
    public enum Action: BindableAction, Sendable {
        case didAppear
        case didTapNavigateToBack
        
        case didTapSayHelloButton
        case didTapSendButton
        case didTapComposeButton
        case didTapToggleHeaderButton
        
        case didReceiveDialogue(Dialogue)
        case didReceiveEntry(Entry)
        case didReceiveError(any Error)
        case didReceiveCancelled
        
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    public struct Destination: Sendable {
        @ObservableState
        public enum State: Sendable {
            case result(Result.State)
        }
        
        public enum Action: Sendable {
            case result(Result.Action)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didAppear:
                state.showHeader = true
                return .none
                
            case .didTapSayHelloButton:
                withAnimation(.bouncy) { state.initialized = true }
                
                let message = "Hello, \(state.diaryName)"
                state.dialogues.append(Dialogue(
                    content: message,
                    createdAt: .now, role: .user))
                return .run { send in
//                    try await diary.startAssistantThread()
//                    let response = try await diary.talk(message)
//                    await send(.didReceiveDialogue(response))
                } catch: { error, send in
//                    await send(.didReceiveError(error as! DiaryUseCaseErrors))
                }
                
            case .didTapSendButton:
                guard !state.dialogue.isEmpty else { return .none }
                let dialogue = Dialogue(
                    content: state.dialogue,
                    createdAt: .now, role: .user)
                state.dialogues.append(dialogue)
                state.dialogue = ""
                return .run { send in
//                    let dialogue = try await diary.talk(dialogue.content)
//                    await send(.didReceiveDialogue(dialogue))
                }
                
            case let .didReceiveDialogue(dialogue):
                state.dialogues.append(dialogue)
                return .none
                
            case .didReceiveError:
                state.composing = false
                return .none
                
            case .didTapNavigateToBack:
                return .run { _ in await dismiss() }
                
            case .didTapComposeButton:
                state.composing.toggle()
                return .run { send in
//                    if let entry = try await diary.compose() {
//                        await send(.didReceiveEntry(entry))
//                    }
                } catch: { error, send in
                    await send(.didReceiveError(error))
                }
                
            case .didReceiveEntry(let entry):
                state.composing = false
                state.destination = .result(Result.State(entry: entry))
                return .none
                
            case .didReceiveCancelled:
                state.composing = false
                return .none
                
            case .didTapToggleHeaderButton:
                state.showHeader.toggle()
                return .none
                
            case \.destination.result.didSaveEntry:
                return .run { _ in await dismiss() }
                
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
}
