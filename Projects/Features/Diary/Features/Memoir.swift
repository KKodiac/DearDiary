import Combine
import ComposableArchitecture
import OSLog
import SwiftUI
import InternalDependencies

@Reducer
public struct Memoir {
    public init() {}
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared(.appStorage("diary_name")) var diaryName: String = "Diary"
        
        var memoirText: String = "Hi"
        var initialized: Bool = false
        var dialogues: [Dialogue] = []
        var progress: Double = 0.0
        var threadID: String?
        var dialogue: String = ""
        var showHeader: Bool = false
        var composing: Bool = false
        
        @Presents var destination: Destination.State?
    }
    
    public enum Action: BindableAction, Equatable, Sendable {
        case didAppear
        case didTapNavigateToBack
        
        case didTapSayHelloButton
        case didTapSendButton
        case didTapComposeButton
        case didTapToggleHeaderButton
        
        case didReceiveDialogue(Dialogue)
        case didReceiveEntry(Entry)
        case didReceiveError(FeatureError)
        case didReceiveCancelled
        
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case result(Result)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.assistantClient) var assistants
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
                return .run { send in
                    await send(.didReceiveDialogue(
                        Dialogue(
                            content: message,
                            createdAt: .now,
                            role: .user
                        )
                    ))
                    let dto = try await assistants.start(message)
//                    await send(.didReceiveDialogue(
//                        Dialogue(
//                            content: dto.content,
//                            createdAt: Date(timeIntervalSince1970: TimeInterval(dto.createAt)),
//                            role: .assistant
//                        )
//                    ))
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
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Memoir {
    public enum FeatureError: LocalizedError, Equatable, Sendable {
        
    }
}
