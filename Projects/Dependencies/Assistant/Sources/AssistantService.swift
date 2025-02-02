import Foundation
import Dependencies
import Moya

extension AssistantsService: AssistantsServiceInterface {
    func startMessage(with content: String) async throws -> ThreadRunResponseDTO {
        try await withCheckedThrowingContinuation { continuation in
            let dto = ThreadRunRequestDTO(
                assistantID: configuration.assistantID,
                text: content
            )
            
            provider.request(.target(RunsRouter.createThreadAndRun(parameter: dto))) { completion in
                switch completion {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let mappedResponse = try filteredResponse.map(ThreadRunResponseDTO.self)
                        
                        try self.configure(with: mappedResponse.threadID)
                        
                        continuation.resume(with: .success(mappedResponse))
                    } catch {
                        continuation.resume(throwing: AssistantError(error: error))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func sendMessage(with content: String) async throws -> MessagesResponseDTO {
        try await withCheckedThrowingContinuation { continuation in
            let dto = MessagesRequestDTO(role: .user, content: content)
            let result = Result { try configuration.fetchThreadID() }
            
            switch result {
            case .success(let threadID):
                provider.request(.target(MessagesRouter.createMessage(threadID, parameter: dto))) { completion in
                    switch completion {
                    case .success(let response):
                        do {
                            let filteredResponse = try response.filterSuccessfulStatusCodes()
                            let mappedResponse = try filteredResponse.map(MessagesResponseDTO.self)
                            continuation.resume(with: .success(mappedResponse))
                        } catch {
                            let assistantError = AssistantError(error: error)
                            continuation.resume(throwing: assistantError)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: AssistantError(error: error))
                    }
                }
            case .failure(let error):
                continuation.resume(throwing: AssistantError(error: error))
            }
        }
    }
}

extension AssistantsService {
    func configure(with newThreadID: String) throws {
        guard configuration.isAssistantThreadActive else {
            throw AssistantError.configurationFailed
        }
        self.configuration.update(threadID: newThreadID)
    }
}
