import AuthenticationServices
import Combine

extension AppleAuthService: AppleAuthServiceInterface {
    public func login() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
            serviceSubject.sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }, receiveValue: { value in
                continuation.resume(returning: value)
            })
            .cancel()
        }
    }
}

extension AppleAuthService: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            serviceSubject.send(completion: .failure(.unknown))
            return
        }
        
        guard let identityTokenData = appleIDCredential.identityToken else {
            serviceSubject.send(completion: .failure(.tokenMissing))
            return
        }
        
        let identityToken =  String(
            decoding: identityTokenData,
            as: UTF8.self
        )
        
        let provider = OAuthProvider
            .appleCredential(
                withIDToken: identityToken,
                rawNonce: nil,
                fullName: appleIDCredential.fullName
            )
        
        self.serviceSubject.send(provider)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        serviceSubject.send(
            completion: .failure(.init(error: error))
        )
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
