import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    final class Dialogue {
        @Attribute(.unique) var id: UUID
        var content: String
        var createAt: String
        var role: Role
        
        init(id: UUID, content: String, createAt: String, role: Role) {
            self.id = id
            self.content = content
            self.createAt = createAt
            self.role = role
        }
    }
    
    enum Role: String, Codable {
        case user
        case assistant
    }
}
