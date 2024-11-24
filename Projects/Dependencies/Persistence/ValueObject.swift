import Foundation
import SwiftData

/// TCA only allows `struct` types to be used as its State properties.
/// This protocol is used to define a `struct` type that can be used as a value object.
/// Value objects will be mapped from SwiftData's `PersistentModel` types.
public struct ValueObject: Sendable, Codable {
    
}

public protocol ValueToModelMappable {
    associatedtype Model = SwiftData.PersistentModel
    associatedtype Value = ValueObject
    func toModel(_ value: Value) -> Model
}

public protocol ModelToValueMappable {
    associatedtype Model = SwiftData.PersistentModel
    associatedtype Value = ValueObject
    func toValue(_ model: Model) -> Value
}
