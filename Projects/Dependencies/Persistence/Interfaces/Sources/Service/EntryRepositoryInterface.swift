import Foundation

public struct StoredDialogue: Equatable, Sendable {
    public let id: UUID
    public let content: String
    public let createdAt: Date
    public let role: Role

    public init(id: UUID, content: String, createdAt: Date, role: Role) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.role = role
    }
}

public struct StoredEntry: Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let content: String
    public let createdAt: Date
    public let dialogues: [StoredDialogue]

    public init(id: UUID, title: String, content: String, createdAt: Date, dialogues: [StoredDialogue] = []) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.dialogues = dialogues
    }
}

public enum EntryStorageError: Error, Equatable, Sendable {
    case missingOwner
    case ownershipMismatch
}

public protocol EntryRepository: Sendable {
    func entries(from start: Date, until end: Date, ownerID: String) async throws -> [StoredEntry]
    func save(_ entry: StoredEntry, ownerID: String) async throws
    func search(query: String, ownerID: String) async throws -> [StoredEntry]
}
