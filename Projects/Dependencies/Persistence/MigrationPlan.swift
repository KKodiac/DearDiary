import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        PersistenceSchemaV1.self,
        PersistenceSchemaV2.self
    ]
    
    static let stages: [MigrationStage] = [
        .lightweight(fromVersion: PersistenceSchemaV1.self, toVersion: PersistenceSchemaV2.self)
    ]
}

public typealias EntryModel = PersistenceSchemaV2.EntryModel
public typealias UserModel = PersistenceSchemaV2.UserModel
public typealias DialogueModel = PersistenceSchemaV2.DialogueModel
public typealias Role = PersistenceSchemaV2.Role
