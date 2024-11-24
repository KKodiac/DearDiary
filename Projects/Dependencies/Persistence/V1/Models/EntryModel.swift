import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    public final class EntryModel {
        @Attribute(.unique)
        public var id: UUID
        
        public var title: String
        public var content: String
        public var createdAt: Date
        
        public init(
            id: UUID = UUID(),
            title: String,
            content: String,
            createdAt: Date
        ) {
            self.id = id
            self.title = title
            self.content = content
            self.createdAt = createdAt
        }
    }
}
