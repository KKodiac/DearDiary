import Foundation
import Persistence
import SwiftData
import Testing
@testable import Diary

@MainActor
struct DiaryTransformerTests {
    @Test func entryRoundTripPreservesIdentityAndFields() throws {
        let entry = Entry(
            id: UUID(),
            title: "A quiet day",
            content: "I went for a walk.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        var transformer = DiaryTransformer()
        try transformer.configure(for: entry)

        let model = try transformer.map(entry, to: EntryModel.self)
        let result = try transformer.map(model, to: Entry.self)

        #expect(model.id == entry.id)
        #expect(result == entry)
        #expect(EntryValueTransformer.allowsReverseTransformation())
    }

    @Test func dialogueRoundTripPreservesIdentityAndFields() throws {
        let dialogue = Dialogue(
            id: UUID(),
            content: "How was your walk?",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            role: .assistant
        )
        var transformer = DiaryTransformer()
        try transformer.configure(for: dialogue)

        let model = try transformer.map(dialogue, to: DialogueModel.self)
        let result = try transformer.map(model, to: Dialogue.self)

        #expect(model.id == dialogue.id)
        #expect(result == dialogue)
        #expect(DialogueValueTransformer.allowsReverseTransformation())
    }

    @Test func updatingEntryPreservesRelationships() throws {
        let model = EntryModel(title: "Before", content: "Before", createdAt: .now)
        let user = UserModel(name: "Writer", email: "writer@example.com", password: nil)
        let dialogue = DialogueModel(content: "Hello", createAt: .now, role: .user)
        model.user = user
        model.dialogues = [dialogue]
        dialogue.entry = model
        let entry = Entry(id: model.id, title: "After", content: "Edited", createdAt: model.createdAt)
        var transformer = DiaryTransformer()
        try transformer.configure(for: entry)

        let updated = try transformer.map(entry, updating: model)

        #expect(updated === model)
        #expect(updated.title == "After")
        #expect(updated.content == "Edited")
        #expect(updated.user === user)
        #expect(updated.dialogues.count == 1)
        #expect(updated.dialogues.first === dialogue)
        #expect(dialogue.entry === model)
    }

    @Test func updatingDialoguePreservesEntryRelationship() throws {
        let entry = EntryModel(title: "Title", content: "Content", createdAt: .now)
        let model = DialogueModel(content: "Before", createAt: .now, role: .user)
        model.entry = entry
        let dialogue = Dialogue(id: model.id, content: "After", createdAt: model.createAt, role: .assistant)
        var transformer = DiaryTransformer()
        try transformer.configure(for: dialogue)

        let updated = try transformer.map(dialogue, updating: model)

        #expect(updated === model)
        #expect(updated.content == "After")
        #expect(updated.role == .assistant)
        #expect(updated.entry === entry)
    }

    @Test func updatingDifferentIdentityFailsWithoutMutation() throws {
        let model = EntryModel(title: "Original", content: "Original", createdAt: .now)
        let entry = Entry(title: "Replacement", content: "Replacement")
        var transformer = DiaryTransformer()
        try transformer.configure(for: entry)

        #expect(throws: DiaryTransformer.TransformerError.identityMismatch) {
            try transformer.map(entry, updating: model)
        }
        #expect(model.title == "Original")
        #expect(model.content == "Original")
    }

    @Test func mappingRequiresConfigurationAndMatchingTypes() throws {
        let entry = Entry(title: "Title", content: "Content")
        var transformer = DiaryTransformer()
        #expect(throws: DiaryTransformer.TransformerError.transformerNameNotConfigured) {
            try transformer.map(entry, to: EntryModel.self)
        }

        try transformer.configure(for: entry)
        #expect(throws: DiaryTransformer.TransformerError.invalidTransformation) {
            try transformer.map(entry, to: DialogueModel.self)
        }
        #expect(throws: DiaryTransformer.TransformerError.invalidTransformation) {
            try transformer.map(DialogueModel(content: "Content", createAt: .now, role: .user), to: Dialogue.self)
        }
    }

    @Test func unsupportedConfigurationClearsPreviousSelection() throws {
        struct UnsupportedValue: ValueMappable {}
        let entry = Entry(title: "Title", content: "Content")
        var transformer = DiaryTransformer()
        try transformer.configure(for: entry)

        #expect(throws: DiaryTransformer.TransformerError.undefinedValueTransformer) {
            try transformer.configure(for: UnsupportedValue())
        }
        #expect(throws: DiaryTransformer.TransformerError.transformerNameNotConfigured) {
            try transformer.map(entry, to: EntryModel.self)
        }
    }
}
