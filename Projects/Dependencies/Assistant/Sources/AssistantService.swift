#if canImport(FoundationModels)
import Foundation
import FoundationModels

actor OnDeviceAssistant {
    private var session: Any?

    @available(iOS 26.0, *)
    func start(_ message: String) async throws -> String {
        try checkAvailability()
        let newSession = LanguageModelSession(instructions: Self.conversationInstructions)
        session = newSession
        return try await newSession.respond(to: message).content
    }

    @available(iOS 26.0, *)
    func send(_ message: String) async throws -> String {
        try checkAvailability()
        guard let session = session as? LanguageModelSession else { return try await start(message) }
        return try await session.respond(to: message).content
    }

    @available(iOS 26.0, *)
    func compose(conversation: String) async throws -> AssistantDiaryEntry {
        try checkAvailability()
        let session = LanguageModelSession(instructions: Self.compositionInstructions)
        let response = try await session.respond(
            to: "Write a concise first-person diary entry using only details from this conversation. Preserve the writer’s meaning and tone.\n\n\(Self.contextualExcerpt(conversation))",
            generating: GeneratedDiary.self
        )
        return AssistantDiaryEntry(title: response.content.title, content: response.content.content)
    }

    @available(iOS 26.0, *)
    private func checkAvailability() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            return
        case .unavailable(.deviceNotEligible):
            throw OnDeviceAssistantError.deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            throw OnDeviceAssistantError.appleIntelligenceDisabled
        case .unavailable(.modelNotReady):
            throw OnDeviceAssistantError.modelNotReady
        case .unavailable:
            throw OnDeviceAssistantError.unavailable
        }
    }

    @available(iOS 26.0, *)
    private static func contextualExcerpt(_ conversation: String) -> String {
        let maximumCharacters = 2_500
        guard conversation.count > maximumCharacters else { return conversation }
        return "Earlier conversation omitted. Recent conversation:\n" + String(conversation.suffix(maximumCharacters))
    }

    @available(iOS 26.0, *)
    private static let conversationInstructions = """
    You are a kind, attentive diary companion. Respond warmly and briefly to what the person shares. Ask at most one gentle follow-up question when it helps them reflect. Do not invent facts, diagnose, or present yourself as a therapist.
    """

    @available(iOS 26.0, *)
    private static let compositionInstructions = """
    You help people turn their own conversation into a personal diary entry. Use first person, retain the writer’s perspective, and only include details present in the supplied conversation. Do not add advice or invented events.
    """
}

@available(iOS 26.0, *)
@Generable
private struct GeneratedDiary {
    @Guide(description: "A short, personal title for this diary entry")
    let title: String

    @Guide(description: "The diary entry written in the first person")
    let content: String
}

@available(iOS 26.0, *)
private enum OnDeviceAssistantError: LocalizedError {
    case deviceNotEligible
    case appleIntelligenceDisabled
    case modelNotReady
    case unavailable

    var errorDescription: String? {
        switch self {
        case .deviceNotEligible:
            "This device does not support Apple Intelligence. On-device diary writing is unavailable."
        case .appleIntelligenceDisabled:
            "Turn on Apple Intelligence in Settings to use on-device diary writing."
        case .modelNotReady:
            "Apple Intelligence is still preparing its on-device model. Try again shortly."
        case .unavailable:
            "Apple Intelligence is currently unavailable. Try again later."
        }
    }
}
#endif
