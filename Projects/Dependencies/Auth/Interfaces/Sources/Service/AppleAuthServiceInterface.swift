import Combine
import Foundation

public protocol AppleAuthServiceInterface {
    func login() async throws -> AuthCredential
}

final class AppleAuthService: NSObject {
    var serviceSubject = PassthroughSubject<AuthCredential, AppleAuthError>()
}
