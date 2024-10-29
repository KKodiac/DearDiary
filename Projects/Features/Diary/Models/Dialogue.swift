import Foundation

public struct Dialogue: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var content: String
    public var createdAt: Date
    public var role: Role
    
    public init(id: UUID = UUID(), content: String, createdAt: Date, role: Role) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.role = role
    }
}

extension Dialogue {
    public static let mock: [Dialogue] = [
        .init(content: "Hello Kitty", createdAt: Date.now, role: .user),
        .init(content: "Hello! How are you!", createdAt: Date.now.addingTimeInterval(1000), role: .assistant),
        .init(content: "I haven't been feeling good since this morning because I've been feeling heavy, but I'm angry that a stranger stepped on my heel on the bus and passed me unapologetically", createdAt: Date.now.addingTimeInterval(5000), role: .user),
        .init(content: "I see. You have been feeling heavy since this morning and have experienced something unpleasant. Anything good happen today?", createdAt: Date.now.addingTimeInterval(10000), role: .assistant)
    ]
}
