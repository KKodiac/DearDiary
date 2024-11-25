import Foundation
import SwiftData

import ComposableArchitecture

public struct PersistenceSchemaV1: VersionedSchema {
    public static var models: [any PersistentModel.Type] = [
        UserModel.self,
        EntryModel.self,
        DialogueModel.self,
    ]

    public static var versionIdentifier = Schema.Version(1, 0, 0)
}
