import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    public final class EntryModel {
        @Attribute(.unique)
        public var id: UUID
        
        // MARK: - One-to-Many Relationship with DialogueModel
        @Relationship(
            deleteRule: .cascade,
            inverse: \DialogueModel.entry
        )
        public var dialogues = [DialogueModel]()
        
        // MARK: - Many-to-One Relationship with UserModel
        public var user: UserModel?
        
        public var title: String
        public var content: String
        public var createdAt: Date
        
        public init(
            id: UUID = UUID(),
            title: String,
            content: String,
            createdAt: Date,
            user: UserModel? = nil,
            dialogues: [DialogueModel] = []
        ) {
            self.id = id
            self.title = title
            self.content = content
            self.createdAt = createdAt
            
            self.user = user
            self.dialogues = dialogues
        }
    }
}
