import Foundation
import SwiftData

extension PersistenceSchemaV1 {
    @Model
    final class Entry {
        var id: UUID
        var title: String
        var content: String
        var createdAt: Date
        
        init(id: UUID, title: String, content: String, createdAt: Date) {
            self.id = id
            self.title = title
            self.content = content
            self.createdAt = createdAt
        }
    }
}
