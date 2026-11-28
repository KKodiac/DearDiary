import Foundation

public protocol AppleAuthServiceInterface {
    @MainActor func login() async throws -> AuthCredential
}
