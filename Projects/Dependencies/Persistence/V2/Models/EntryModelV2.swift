import Foundation
import SwiftData

extension PersistenceSchemaV2 {
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
        
        public var ownerID: String?

        public var title: String
        public var content: String
        public var createdAt: Date
        
        public init(
            id: UUID = UUID(),
            title: String,
            content: String,
            createdAt: Date,
            ownerID: String? = nil,
            user: UserModel? = nil,
            dialogues: [DialogueModel] = []
        ) {
            self.id = id
            self.title = title
            self.content = content
            self.createdAt = createdAt
            self.ownerID = ownerID
            
            self.user = user
            self.dialogues = dialogues
        }
    }
}
