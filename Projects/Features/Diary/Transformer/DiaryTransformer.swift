import ComposableArchitecture
import Foundation
import SwiftData
import Persistence

protocol ValueMappable {}

struct DiaryTransformer: Sendable {
    private enum Kind: Sendable {
        case entry
        case dialogue

        var transformer: ValueTransformer {
            switch self {
            case .entry: EntryValueTransformer()
            case .dialogue: DialogueValueTransformer()
            }
        }
    }

    private var kind: Kind?

    mutating func configure<Value: ValueMappable>(for value: Value) throws {
        switch value {
        case is Entry:
            kind = .entry
        case is Dialogue:
            kind = .dialogue
        default:
            kind = nil
            throw TransformerError.undefinedValueTransformer
        }
    }

    func map<Value: ValueMappable, Model: PersistentModel>(
        _ value: Value,
        to model: Model.Type
    ) throws -> Model {
        guard let kind else { throw TransformerError.transformerNameNotConfigured }
        guard let model = kind.transformer.transformedValue(value) as? Model else {
            throw TransformerError.invalidTransformation
        }
        return model
    }

    func map<Value: ValueMappable, Model: PersistentModel>(
        _ model: Model,
        to value: Value.Type
    ) throws -> Value {
        guard let kind else { throw TransformerError.transformerNameNotConfigured }
        guard let value = kind.transformer.reverseTransformedValue(model) as? Value else {
            throw TransformerError.invalidTransformation
        }
        return value
    }

    /// Updates scalar fields on an existing model, retaining its relationship graph.
    /// Creating a new model from a value object cannot restore relationships, because
    /// the value objects intentionally contain only the diary's display fields.
    func map<Value: ValueMappable, Model: PersistentModel>(
        _ value: Value,
        updating model: Model
    ) throws -> Model {
        guard let kind else { throw TransformerError.transformerNameNotConfigured }
        switch (kind, value, model) {
        case let (.entry, entry as Entry, model as EntryModel):
            guard entry.id == model.id else { throw TransformerError.identityMismatch }
            model.title = entry.title
            model.content = entry.content
            model.createdAt = entry.createdAt
        case let (.dialogue, dialogue as Dialogue, model as DialogueModel):
            guard dialogue.id == model.id else { throw TransformerError.identityMismatch }
            model.content = dialogue.content
            model.createAt = dialogue.createdAt
            model.role = dialogue.role
        default:
            throw TransformerError.invalidTransformation
        }
        return model
    }
}

extension DiaryTransformer {
    enum TransformerError: Error, Equatable {
        case undefinedValueTransformer
        case transformerNameNotConfigured
        case invalidTransformation
        case identityMismatch
    }
}

extension DependencyValues {
    var transformer: DiaryTransformer {
        get { self[DiaryTransformer.self] }
        set { self[DiaryTransformer.self] = newValue }
    }
}

extension DiaryTransformer: DependencyKey {
    static let liveValue = DiaryTransformer()
    static let testValue = DiaryTransformer()
}
