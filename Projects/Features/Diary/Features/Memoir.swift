import ComposableArchitecture
import SwiftUI
import Assistant

@Reducer
public struct Memoir {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared(.appStorage("diary_name")) var diaryName: String = "Diary"
        var memoirText = "Hi"
        var initialized = false
        var dialogues: [Dialogue] = []
        var progress = 0.0
        var threadID: String?
        var dialogue = ""
        var showHeader = false
        var composing = false
        var isWorking = false
        var errorMessage: String?
        var failedMessage: String?
        var retryingComposition = false
        var retryStartsNewThread = false
        var hasThread = false
        @Presents var destination: Destination.State?
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case didAppear, didTapNavigateToBack, didTapSayHelloButton, didTapSendButton
        case didTapComposeButton, didTapToggleHeaderButton, didTapRetry
        case didReceiveDialogue(Dialogue), didReceiveEntry(Entry), didReceiveError(FeatureError)
        case didReceiveCancelled
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination { case result(Result) }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.assistantClient) var assistants
    private enum CancelID { case request }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didAppear:
                state.showHeader = true
                return .none
            case .didTapSayHelloButton:
                guard !state.isWorking else { return .none }
                withAnimation(.bouncy) { state.initialized = true }
                let message = "Hello, \(state.diaryName)"
                state.dialogues.append(Dialogue(content: message, createdAt: .now, role: .user))
                state.failedMessage = message
                state.retryingComposition = false
                state.retryStartsNewThread = true
                state.isWorking = true
                state.errorMessage = nil
                return .run { send in
                    let response = try await assistants.start(message)
                    await send(.didReceiveDialogue(Dialogue(content: response, createdAt: .now, role: .assistant)))
                } catch: { error, send in
                    await send(.didReceiveError(FeatureError(message: error.localizedDescription)))
                }.cancellable(id: CancelID.request, cancelInFlight: true)
            case .didTapSendButton:
                guard !state.isWorking else { return .none }
                let text = state.dialogue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return .none }
                state.dialogues.append(Dialogue(content: text, createdAt: .now, role: .user))
                state.dialogue = ""
                state.failedMessage = text
                state.retryingComposition = false
                state.retryStartsNewThread = !state.hasThread
                state.isWorking = true
                state.errorMessage = nil
                return sendRequest(text, startNewThread: state.retryStartsNewThread)
            case .didTapComposeButton:
                guard !state.isWorking, !state.dialogues.isEmpty else { return .none }
                state.composing = true
                state.isWorking = true
                state.errorMessage = nil
                state.retryingComposition = true
                state.retryStartsNewThread = !state.hasThread
                let transcript = state.dialogues.map { "\($0.role == .user ? "User" : state.diaryName): \($0.content)" }.joined(separator: "\n")
                state.failedMessage = transcript
                return sendRequest(transcript, startNewThread: state.retryStartsNewThread, compose: true)
            case .didTapRetry:
                guard !state.isWorking, let message = state.failedMessage else { return .none }
                state.isWorking = true
                state.errorMessage = nil
                return sendRequest(message, startNewThread: state.retryStartsNewThread, compose: state.retryingComposition)
            case let .didReceiveDialogue(dialogue):
                state.dialogues.append(dialogue)
                state.isWorking = false
                state.hasThread = true
                state.failedMessage = nil
                return .none
            case let .didReceiveError(error):
                state.isWorking = false
                state.errorMessage = error.message
                return .none
            case .didReceiveEntry(let entry):
                state.isWorking = false
                state.failedMessage = nil
                state.composing = false
                state.destination = .result(Result.State(entry: entry, dialogues: state.dialogues))
                return .none
            case .didReceiveCancelled:
                state.composing = false
                state.isWorking = false
                return .cancel(id: CancelID.request)
            case .didTapNavigateToBack:
                return .run { _ in await dismiss() }
            case .didTapToggleHeaderButton:
                state.showHeader.toggle()
                return .none
            case \.destination.result.didSaveEntry:
                return .run { _ in await dismiss() }
            case .binding, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func sendRequest(_ message: String, startNewThread: Bool = false, compose: Bool = false) -> Effect<Action> {
        .run { send in
            if compose {
                let composition = try await assistants.compose(message)
                await send(.didReceiveEntry(Entry(title: composition.title, content: composition.content)))
            } else {
                let response = startNewThread ? try await assistants.start(message) : try await assistants.send(message)
                await send(.didReceiveDialogue(Dialogue(content: response, createdAt: .now, role: .assistant)))
            }
        } catch: { error, send in
            await send(.didReceiveError(FeatureError(message: error.localizedDescription)))
        }.cancellable(id: CancelID.request, cancelInFlight: true)
    }
}

extension Memoir {
    public struct FeatureError: LocalizedError, Equatable, Sendable {
        public let message: String
        public init(message: String) { self.message = message }
        public var errorDescription: String? { message }
    }
}
