import Combine
import Foundation

public protocol AppleAuthServiceInterface {
    func login() async throws -> AuthCredential
}

class AppleAuthService: NSObject {
    var serviceSubject = PassthroughSubject<AuthCredential, AppleAuthError>()
}
