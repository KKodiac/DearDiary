import AuthenticationServices

final class AppleAuthService: NSObject, AppleAuthServiceInterface {
    @MainActor private var controller: ASAuthorizationController?
    @MainActor private var continuation: CheckedContinuation<AuthCredential, Error>?

    @MainActor
    func login() async throws -> AuthCredential {
        guard controller == nil else { throw AppleAuthError.notInteractive }

        return try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            self.continuation = continuation
            self.controller = controller
            controller.performRequests()
        }
    }

    @MainActor
    private func finish(
        _ result: Result<AuthCredential, Error>,
        from controller: ASAuthorizationController
    ) {
        guard self.controller === controller, let continuation else { return }
        self.continuation = nil
        self.controller = nil
        continuation.resume(with: result)
    }
}

extension AppleAuthService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            finish(.failure(AppleAuthError.invalidResponse), from: controller)
            return
        }
        guard let token = credential.identityToken else {
            finish(.failure(AppleAuthError.tokenMissing), from: controller)
            return
        }
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: String(decoding: token, as: UTF8.self),
            rawNonce: nil,
            fullName: credential.fullName
        )
        finish(.success(firebaseCredential), from: controller)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        finish(.failure(AppleAuthError(error: error)), from: controller)
    }
}

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return UIWindow()
        }
        
        return window
    }
}
