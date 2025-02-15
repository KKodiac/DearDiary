import Dependencies
import Foundation

public struct AssistantClient {
    private let assistants: AssistantsServiceInterface
    
    public init(assistantsService: AssistantsServiceInterface) {
        self.assistants = assistantsService
    }
}

extension AssistantClient: DependencyKey {
    public static let liveValue = AssistantClient(
        assistantsService: AssistantsService()
    )
}
