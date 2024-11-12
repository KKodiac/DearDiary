import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] = [
        PersistenceSchemaV1.self
    ]
    
    static var stages: [MigrationStage] = [
        
    ]
}

