import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    final class User {
        @Attribute(.unique) var id: UUID
        var name: String
        var email: String
        var password: String?
        
        init(id: UUID, name: String, email: String, password: String? = nil) {
            self.id = id
            self.name = name
            self.email = email
            self.password = password
        }
    }
}
