import Foundation
import ExternalDependencies

public struct ThreadRunResponseDTO: Decodable {
    let id: String
    let object: String
    let createdAt: Int
    let assistantID: String
    let threadID: String
    let status: String
    let startedAt: Int?
    let expiresAt: Int
    let cancelledAt: Int?
    let failedAt: Int?
    let completedAt: Int?
    let requiredAction: String?
    let lastError: String?
    let model: String
    let instructions: String
    let tools: [String]
    let toolResources: [String: AnyCodable]
    let metadata: [String: AnyCodable]
    let temperature: Double
    let topP: Double
    let maxCompletionTokens: Int?
    let maxPromptTokens: Int?
    let truncationStrategy: TruncationStrategyDTO?
    let incompleteDetails: String?
    let usage: String?
    let responseFormat: String
    let toolChoice: String
    let parallelToolCalls: Bool
    
    struct TruncationStrategyDTO: Codable {
        let type: String
        let lastMessages: String?
    }
}

