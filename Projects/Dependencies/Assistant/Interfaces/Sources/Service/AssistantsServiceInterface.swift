import Foundation
import Moya

public protocol AssistantsServiceInterface {
    func startMessage(with text: String) async throws -> ThreadRunResponseDTO
}

final class AssistantsService {
    internal let provider: MoyaProvider<MultiTarget>
    internal var currentThreadID: String? = nil
    
    public init(
        provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>(
            plugins: [AccessTokenPlugin(tokenClosure: { _ in
                let path = Bundle.main.path(forResource: "Info", ofType: "plist")
                let plist = NSDictionary(contentsOfFile: path!)
                return (plist?["OpenAIToken"] as? String)!
            })]
        )
    ) {
        self.provider = provider
    }
    
    internal static let defaultAssistantID: String = {
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: path!)
        return (plist?["AssistantID"] as? String)!
    }()
}
