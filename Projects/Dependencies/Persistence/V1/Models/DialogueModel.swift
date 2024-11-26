import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    public final class DialogueModel {
        @Attribute(.unique)
        public var id: UUID
        
        public var content: String
        public var createAt: Date
        public var role: Role
        
        // MARK: - Many-to-One Relationship with EntryModel
        public var entry: EntryModel?
        
        public init(
            id: UUID = UUID(),
            content: String,
            createAt: Date,
            role: Role
        ) {
            self.id = id
            self.content = content
            self.createAt = createAt
            self.role = role
        }
    }
    
    public enum Role: String, Codable, Sendable {
        case user
        case assistant
    }
}
