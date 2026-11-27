import Assistant
import ComposableArchitecture
import Testing
@testable import Diary

@MainActor
struct MemoirTests {
    @Test
    func composeSendsTranscriptAndKeepsDraftAvailableForRetry() async {
        let attempts = CompositionAttempts()
        var state = Memoir.State()
        state.dialogues = [
            Dialogue(content: "I had a quiet morning.", createdAt: .now, role: .user),
            Dialogue(content: "What made it feel quiet?", createdAt: .now, role: .assistant),
        ]
        let store = TestStore(initialState: state) { Memoir() } withDependencies: {
            $0.assistantClient.compose = { transcript in
                #expect(transcript.contains("User: I had a quiet morning."))
                #expect(transcript.contains("Diary: What made it feel quiet?"))
                return try await attempts.compose()
            }
        }

        await store.send(.didTapComposeButton) {
            $0.composing = true
            $0.isWorking = true
            $0.retryingComposition = true
            $0.retryStartsNewThread = true
            $0.failedMessage = "User: I had a quiet morning.\nDiary: What made it feel quiet?"
        }
        await store.receive(.didReceiveError(Memoir.FeatureError(message: "Model unavailable"))) {
            $0.isWorking = false
            $0.errorMessage = "Model unavailable"
        }

        await store.send(.didTapRetry) {
            $0.isWorking = true
            $0.errorMessage = nil
        }
        await store.receive(.didReceiveError(Memoir.FeatureError(message: "Model unavailable"))) {
            $0.isWorking = false
            $0.errorMessage = "Model unavailable"
        }
        #expect(await attempts.count == 2)
        #expect(store.state.composing)
        #expect(store.state.failedMessage != nil)
    }

    @Test
    func duplicateSendAndComposeActionsAreIgnoredWhileWorking() async {
        var state = Memoir.State()
        state.dialogue = "Keep this draft"
        state.dialogues = [Dialogue(content: "A thought", createdAt: .now, role: .user)]
        state.isWorking = true
        let store = TestStore(initialState: state) { Memoir() }

        await store.send(.didTapSendButton)
        await store.send(.didTapComposeButton)

        #expect(store.state.dialogue == "Keep this draft")
        #expect(store.state.dialogues.count == 1)
    }
}

private actor CompositionAttempts {
    private(set) var count = 0

    func compose() throws -> AssistantDiaryEntry {
        count += 1
        throw Memoir.FeatureError(message: "Model unavailable")
    }
}
