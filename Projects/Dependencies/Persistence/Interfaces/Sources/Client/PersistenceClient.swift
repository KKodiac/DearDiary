import Foundation
import Dependencies
import SwiftData

public struct PersistenceClient: Sendable {
    private struct Repositories: Sendable {
        let user: any UserRepository
        let entry: any EntryRepository
    }

    private let repositories: Result<Repositories, any Error>

    /// Access can throw if the persistent store could not be opened.
    public var user: any UserRepository {
        get throws { try repositories.get().user }
    }

    /// Access can throw if the persistent store could not be opened.
    public var entry: any EntryRepository {
        get throws { try repositories.get().entry }
    }

    public init(user: any UserRepository, entry: any EntryRepository) {
        repositories = .success(Repositories(user: user, entry: entry))
    }

    public init(modelContainer: ModelContainer) {
        self.init(
            user: UserModelRepository(modelContainer: modelContainer),
            entry: EntryModelRepository(modelContainer: modelContainer)
        )
    }

    private init(error: any Error) {
        repositories = .failure(error)
    }

    /// Opens the store without deleting or replacing it on failure.
    /// Call again and replace the dependency to retry a failed initialization.
    public static func live() throws -> Self {
        let container = try makeModelContainer()
        return Self(
            user: UserModelRepository(modelContainer: container),
            entry: EntryModelRepository(modelContainer: container)
        )
    }

    /// Creates the current store, migrating older schema versions without discarding data.
    public static func makeModelContainer(configuration: ModelConfiguration? = nil) throws -> ModelContainer {
        let schema = Schema(versionedSchema: PersistenceSchemaV2.self)
        return try ModelContainer(
            for: schema,
            migrationPlan: MigrationPlan.self,
            configurations: [configuration ?? ModelConfiguration(schema: schema)]
        )
    }

}

public extension DependencyValues {
    var persistence: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}

extension PersistenceClient: DependencyKey {
    public static let liveValue: Self = {
        do {
            return try live()
        } catch {
            return Self(error: error)
        }
    }()
}
