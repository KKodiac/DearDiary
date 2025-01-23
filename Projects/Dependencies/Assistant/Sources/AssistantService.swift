import Foundation
import Dependencies
import Moya

extension AssistantsService: AssistantsServiceInterface {
    func startMessage(with content: String) async throws -> ThreadRunResponseDTO {
        try await withCheckedThrowingContinuation { continuation in
            let dto = ThreadRunRequestDTO(
                assistantID: AssistantsService.defaultAssistantID,
                thread: Thread(message: [
                    Messages(role: .user, content: content)
                ])
            )
            
            provider.request(.target(RunsRouter.createThreadAndRun(parameter: dto))) { completion in
                switch completion {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let mappedResponse = try filteredResponse.map(ThreadRunResponseDTO.self)
                        
                        try self.configure(mappedResponse.threadID)
                        
                        continuation.resume(with: .success(mappedResponse))
                    } catch let error as AssistantError {
                        continuation.resume(throwing: error)
                    } catch {
                        let assistantError = AssistantError(error: RunsAssistantError(error: error))
                        continuation.resume(throwing: assistantError)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension AssistantsService {
    func configure(_ currentThreadID: String) throws {
        guard self.currentThreadID == nil else {
            throw AssistantError.activeThreadFound
        }
        self.currentThreadID = currentThreadID
    }
}
