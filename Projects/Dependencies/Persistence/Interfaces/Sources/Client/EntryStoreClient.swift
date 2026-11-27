import Dependencies
import Foundation

public struct EntryStoreClient: Sendable {
    public var load: @Sendable (_ start: Date, _ end: Date, _ ownerID: String) async throws -> [StoredEntry]
    public var save: @Sendable (_ entry: StoredEntry, _ ownerID: String) async throws -> Void
    public var search: @Sendable (_ query: String, _ ownerID: String) async throws -> [StoredEntry]

    public init(
        load: @escaping @Sendable (Date, Date, String) async throws -> [StoredEntry],
        save: @escaping @Sendable (StoredEntry, String) async throws -> Void,
        search: @escaping @Sendable (String, String) async throws -> [StoredEntry] = { _, _ in throw EntryStorageError.missingOwner }
    ) {
        self.load = load
        self.save = save
        self.search = search
    }
}

extension EntryStoreClient: DependencyKey {
    public static let liveValue = Self(
        load: { start, end, ownerID in
            @Dependency(\.persistence) var persistence
            let repository: any EntryRepository
            do { repository = try persistence.entry }
            catch { repository = try PersistenceClient.live().entry }
            return try await repository.entries(from: start, until: end, ownerID: ownerID)
        },
        save: { entry, ownerID in
            @Dependency(\.persistence) var persistence
            let repository: any EntryRepository
            do { repository = try persistence.entry }
            catch { repository = try PersistenceClient.live().entry }
            try await repository.save(entry, ownerID: ownerID)
        },
        search: { query, ownerID in
            @Dependency(\.persistence) var persistence
            let repository: any EntryRepository
            do { repository = try persistence.entry }
            catch { repository = try PersistenceClient.live().entry }
            return try await repository.search(query: query, ownerID: ownerID)
        }
    )

    public static let testValue = Self(
        load: { _, _, _ in throw EntryStorageError.missingOwner },
        save: { _, _ in throw EntryStorageError.missingOwner },
        search: { _, _ in throw EntryStorageError.missingOwner }
    )
}

public extension DependencyValues {
    var entryStore: EntryStoreClient {
        get { self[EntryStoreClient.self] }
        set { self[EntryStoreClient.self] = newValue }
    }
}
