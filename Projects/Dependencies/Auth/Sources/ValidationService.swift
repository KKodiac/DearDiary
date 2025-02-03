import Foundation

extension ValidationService: ValidationServiceInterface {
    func validate(password: String, with confirmPassword: String) throws {
        guard password == confirmPassword else {
            throw ValidationError.passwordDoesNotMatch
        }
    }
}
