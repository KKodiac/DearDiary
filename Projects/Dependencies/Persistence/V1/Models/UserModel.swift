import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    public final class UserModel {
        @Attribute(.unique)
        public var id: UUID
        
        public var name: String
        public var email: String
        public var password: String?
        
        public init(
            id: UUID = UUID(),
            name: String,
            email: String,
            password: String?
        ) {
            self.id = id
            self.name = name
            self.email = email
            self.password = password
        }
    }
}