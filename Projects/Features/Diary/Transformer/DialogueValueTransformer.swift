import Foundation
import Persistence

public final class DialogueValueTransformer: ValueTransformer {
    internal static let name = NSValueTransformerName(rawValue: "DialogueValueTransformer")
    
    // From Dialogue to DialogueModel
    public override class func transformedValueClass() -> AnyClass {
        return DialogueModel.self
    }
    
    // Perform the transformation from Dialogue to DialogueModel
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let dialogue = value as? Dialogue else { return nil }
        return DialogueModel(
            content: dialogue.content,
            createAt: dialogue.createdAt,
            role: dialogue.role
        )
    }
    
    // Perform the reverse transformation from DialogueModel to Dialogue
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let dialogueModel = value as? DialogueModel else { return nil }
        return Dialogue(
            content: dialogueModel.content,
            createdAt: dialogueModel.createAt,
            role: dialogueModel.role
        )
    }
}
