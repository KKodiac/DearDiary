import Foundation

import Moya

public protocol DefaultTargetType: TargetType, AccessTokenAuthorizable { }

extension DefaultTargetType {
    public var baseURL: URL {
        return URL(string: "https://api.openai.com/v1")!
    }
    
    public var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "OpenAI-Beta": "assistants=v2"
        ]
    }
}

extension DefaultTargetType {
    public var authorizationType: AuthorizationType? {
        .bearer
    }
}
