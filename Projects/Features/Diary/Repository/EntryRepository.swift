import Foundation

protocol EntryCommandRepository {
    func create(title: String, content: String, createdAt: Date) async throws
    func upsert(id: UUID, title: String, content: String, createdAt: Date) async throws
}

protocol EntryQueryRepository {
    func find(by id: UUID) async -> Predicate<EntryModel>
    func find(by title: String) async -> Predicate<EntryModel>
    func find(by title: String, and createAt: Date) async -> Predicate<EntryModel>
}

protocol EntryRepository: EntryCommandRepository, EntryQueryRepository { }
