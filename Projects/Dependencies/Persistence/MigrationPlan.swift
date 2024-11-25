import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [
        PersistenceSchemaV1.self
    ]
    
    static var stages: [MigrationStage] = [
        
    ]
}

public typealias EntryModel = PersistenceSchemaV1.EntryModel
public typealias UserModel = PersistenceSchemaV1.UserModel
public typealias DialogueModel = PersistenceSchemaV1.DialogueModel
