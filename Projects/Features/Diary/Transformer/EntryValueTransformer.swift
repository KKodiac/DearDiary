import Foundation
import Persistence

public final class EntryValueTransformer: ValueTransformer {
    internal static let name = NSValueTransformerName(rawValue: "EntryValueTransformer")
    
    // From Entry to EntryModel
    public override class func transformedValueClass() -> AnyClass {
        return EntryModel.self
    }
    
    public override class func allowsReverseTransformation() -> Bool {
        true
    }

    // Perform the transformation from Entry to EntryModel
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let entry = value as? Entry else { return nil }
        return EntryModel(
            id: entry.id,
            title: entry.title,
            content: entry.content,
            createdAt: entry.createdAt
        )
    }
    
    // Perform the reverse transformation from EntryModel to Entry
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let entryModel = value as? EntryModel else { return nil }
        return Entry(
            id: entryModel.id,
            title: entryModel.title,
            content: entryModel.content,
            createdAt: entryModel.createdAt
        )
    }
}
