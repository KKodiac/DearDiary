import Dependencies
import Foundation

public struct AssistantDiaryEntry: Equatable, Sendable {
    public let title: String
    public let content: String

    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

public struct AssistantClient: Sendable {
    public var start: @Sendable (_ message: String) async throws -> String
    public var send: @Sendable (_ message: String) async throws -> String
    public var compose: @Sendable (_ conversation: String) async throws -> AssistantDiaryEntry

    public static func live() -> Self {
        #if canImport(FoundationModels)
        let model = OnDeviceAssistant()
        return .init(
            start: { message in
                guard #available(iOS 26.0, *) else { throw FoundationModelsUnavailableError.unsupportedOS }
                return try await model.start(message)
            },
            send: { message in
                guard #available(iOS 26.0, *) else { throw FoundationModelsUnavailableError.unsupportedOS }
                return try await model.send(message)
            },
            compose: { conversation in
                guard #available(iOS 26.0, *) else { throw FoundationModelsUnavailableError.unsupportedOS }
                return try await model.compose(conversation: conversation)
            }
        )
        #else
        return .init(
            start: { _ in throw FoundationModelsUnavailableError.unsupportedOS },
            send: { _ in throw FoundationModelsUnavailableError.unsupportedOS },
            compose: { _ in throw FoundationModelsUnavailableError.unsupportedOS }
        )
        #endif
    }
}

private enum FoundationModelsUnavailableError: LocalizedError {
    case unsupportedOS

    var errorDescription: String? {
        "On-device writing requires iOS 26 or later and a device that supports Apple Intelligence."
    }
}

extension AssistantClient: DependencyKey {
    public static let liveValue: AssistantClient = live()
}

extension DependencyValues {
    public var assistantClient: AssistantClient {
        get { self[AssistantClient.self] }
        set { self[AssistantClient.self] = newValue }
    }
}
