import Foundation

public protocol ValidationServiceInterface {
    func validate(password: String, with confirmPassword: String) throws
}

final class ValidationService: NSObject {
    
}
