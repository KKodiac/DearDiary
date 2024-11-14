import Core

protocol LayerDataTransformer {
    associatedtype ValueObject
    associatedtype ModelObject
    
    func transform(from modelObjects: [ModelObject]) -> [ValueObject]
    func transform(_ modelObject: ModelObject) -> ValueObject
}

class BaseLayerDataTransformer<ValueObject, ModelObject>: LayerDataTransformer {
    func transform(_ modelObject: ModelObject) -> ValueObject {
        fatalError("Must be overridden")
    }

    
    func transform(from modelObjects: [ModelObject]) -> [ValueObject] {
        return modelObjects.map { transform($0) }
    }
}

class EntryValueObjectToEntryModelTransformer: BaseLayerDataTransformer<Entry, EntryModel> {
    override func transform(_ modelObject: EntryModel) -> Entry {
        Entry(
            id: modelObject.id,
            title: modelObject.title,
            content: modelObject.content,
            createdAt: modelObject.createdAt
        )
    }
}
