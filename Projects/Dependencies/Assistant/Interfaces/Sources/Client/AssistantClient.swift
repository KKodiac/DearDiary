import Dependencies
import Foundation

public struct AssistantClient: Sendable {
    private let assistants: AssistantsServiceInterface
    
    public var start: @Sendable (_ message: String) async throws -> ThreadRunResponseDTO
    
    public static func live() -> Self {
        let assistants = AssistantsService()
        return .init(
            assistants: assistants,
            start: { message in try await assistants.startMessage(with: message) }
        )
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
