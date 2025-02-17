import Foundation
import Moya

public protocol AssistantsServiceInterface: Sendable {
    func startMessage(with text: String) async throws -> ThreadRunResponseDTO
    func sendMessage(with text: String) async throws -> MessagesResponseDTO
}

final class AssistantsService {
    internal let provider: MoyaProvider<MultiTarget>
    internal var configuration: AssistantConfiguration
    
    public init(
        provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>(
            plugins: [
                AccessTokenPlugin(tokenClosure: { _ in
                    let path = Bundle.main.path(forResource: "Info", ofType: "plist")
                    let plist = NSDictionary(contentsOfFile: path!)
                    return (plist?["OpenAIToken"] as? String)!
                })
            ]
        ),
        assistantID: String = {
            let path = Bundle.main.path(forResource: "Info", ofType: "plist")
            let plist = NSDictionary(contentsOfFile: path!)
            return (plist?["AssistantID"] as? String)!
        }()
    ) {
        self.provider = provider
        self.configuration = AssistantConfiguration(assistantID: assistantID)
    }
}
