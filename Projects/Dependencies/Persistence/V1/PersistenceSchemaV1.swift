import Foundation
import SwiftData

import ComposableArchitecture

public struct PersistenceSchemaV1: VersionedSchema {
    public static let models: [any PersistentModel.Type] = [
        PersistenceSchemaV1.UserModel.self,
        PersistenceSchemaV1.EntryModel.self,
        PersistenceSchemaV1.DialogueModel.self,
    ]

    public static let versionIdentifier = Schema.Version(1, 0, 0)
}
