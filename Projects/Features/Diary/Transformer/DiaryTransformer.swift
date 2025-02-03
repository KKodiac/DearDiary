import ComposableArchitecture
import Foundation
import SwiftData

import Persistence

internal protocol ValueMappable { }

internal struct DiaryTransformer {
    internal init(
        entryTransformer: EntryValueTransformer = EntryValueTransformer(),
        dialogueTransformer: DialogueValueTransformer = DialogueValueTransformer()
    ) {
        ValueTransformer
            .setValueTransformer(
                entryTransformer,
                forName: EntryValueTransformer.name
            )
        ValueTransformer
            .setValueTransformer(
                dialogueTransformer,
                forName: DialogueValueTransformer.name
            )
    }
    
    private var name: NSValueTransformerName? = nil
    
    internal mutating func configure<Value: ValueMappable>(for value: Value) throws {
        if value is Entry {
            self.name = EntryValueTransformer.name
        }
        if value is Dialogue {
            self.name = DialogueValueTransformer.name
        }
        throw TransformerError.undefinedValueTransformer
    }
    
    internal func map<Value: ValueMappable, Model: PersistentModel>(_ value: Value, to model: Model.Type) throws -> Model? {
        guard let name = self.name else { throw TransformerError.transformerNameNotConfigured }
        
        let transformer = ValueTransformer(forName: name)
        return transformer?.transformedValue(value) as? Model
    }
    
    internal func map<Value: ValueMappable, Model: PersistentModel>(_ model: Model, to value: Value.Type) throws -> Value? {
        guard let name = self.name else { throw TransformerError.transformerNameNotConfigured }
        
        let transformer = ValueTransformer(forName: name)
        return transformer?.reverseTransformedValue(model) as? Value
    }
}

extension DiaryTransformer {
    internal enum TransformerError: Error {
        case missingValueTransformer
        case undefinedValueTransformer
        case transformerNameNotConfigured
    }
}

extension DependencyValues {
    var transformer: DiaryTransformer {
        get { self[DiaryTransformer.self] }
        set { self[DiaryTransformer.self] = newValue }
    }
}

extension DiaryTransformer: DependencyKey {
    static var liveValue = DiaryTransformer()
}

extension DiaryTransformer: TestDependencyKey {
    static var testValue = DiaryTransformer()
}
