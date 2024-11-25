import Foundation
import Dependencies
import SwiftData

public struct PersistenceClient {
    public let user: UserRepository
    public let entry: EntryRepository
    
    public init(
        user: UserRepository,
        entry: EntryRepository
    ) {
        self.user = user
        self.entry = entry
    }
}

extension DependencyValues {
    var persistence: PersistenceClient {
        get { self[PersistenceClient.self] }
        set { self[PersistenceClient.self] = newValue }
    }
}

extension PersistenceClient: DependencyKey {
    public static var liveValue = PersistenceClient(
        user: UserModelRepository(
            modelContainer: try! ModelContainer(
                for: UserModel.self,
                migrationPlan: MigrationPlan.self,
                configurations: ModelConfiguration(
                    schema: Schema(
                        versionedSchema: PersistenceSchemaV1.self
                    )
                )
            )
        ),
        entry: EntryModelRepository(
            modelContainer: try! ModelContainer(
                for: EntryModel.self, UserModel.self, DialogueModel.self,
                migrationPlan: MigrationPlan.self,
                configurations: ModelConfiguration(
                    schema: Schema(
                        versionedSchema: PersistenceSchemaV1.self
                    )
                )
            )
        )
    )
}
