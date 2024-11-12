import Foundation
import SwiftData

import ComposableArchitecture

struct PersistenceSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] = [
        User.self,
        Entry.self
    ]

    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
}
