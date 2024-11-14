import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    public final class DialogueModel {
        @Attribute(.unique)
        public var id: UUID
        
        public var content: String
        public var createAt: String
        public var role: Role
        
        internal init(id: UUID, content: String, createAt: String, role: Role) {
            self.id = id
            self.content = content
            self.createAt = createAt
            self.role = role
        }
    }
    
    public enum Role: String, Codable {
        case user
        case assistant
    }
}
