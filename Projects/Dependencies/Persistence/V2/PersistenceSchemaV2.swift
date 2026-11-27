import SwiftData

public struct PersistenceSchemaV2: VersionedSchema {
    public static let models: [any PersistentModel.Type] = [
        PersistenceSchemaV2.UserModel.self, PersistenceSchemaV2.EntryModel.self, PersistenceSchemaV2.DialogueModel.self,
    ]
    public static let versionIdentifier = Schema.Version(2, 0, 0)
}
