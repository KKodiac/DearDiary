import Foundation
import SwiftData

@ModelActor
final actor EntryModelRepository: EntryRepository {
    func entries(from start: Date, until end: Date, ownerID: String) throws -> [StoredEntry] {
        guard !ownerID.isEmpty else { throw EntryStorageError.missingOwner }
        let predicate = #Predicate<EntryModel> {
            $0.ownerID == ownerID && $0.createdAt >= start && $0.createdAt < end
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\EntryModel.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor).map(storedEntry)
    }

    func search(query: String, ownerID: String) throws -> [StoredEntry] {
        guard !ownerID.isEmpty else { throw EntryStorageError.missingOwner }
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        let descriptor = FetchDescriptor(
            predicate: #Predicate<EntryModel> { $0.ownerID == ownerID },
            sortBy: [SortDescriptor(\EntryModel.createdAt, order: .reverse)]
        )
        // Scope in the store first; normalize text locally for consistent accent matching.
        return try modelContext.fetch(descriptor).filter {
            $0.title.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                || $0.content.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }.map(storedEntry)
    }

    private func storedEntry(_ entry: EntryModel) -> StoredEntry {
        StoredEntry(
            id: entry.id,
            title: entry.title,
            content: entry.content,
            createdAt: entry.createdAt,
            dialogues: entry.dialogues.sorted { $0.createAt < $1.createAt }.map {
                StoredDialogue(id: $0.id, content: $0.content, createdAt: $0.createAt, role: $0.role)
            }
        )
    }

    func save(_ entry: StoredEntry, ownerID: String) throws {
        guard !ownerID.isEmpty else { throw EntryStorageError.missingOwner }
        let id = entry.id
        let descriptor = FetchDescriptor(predicate: #Predicate<EntryModel> { $0.id == id })
        let existing = try modelContext.fetch(descriptor).first
        // Never claim an unowned legacy entry or overwrite another account's entry implicitly.
        if let existing, existing.ownerID != ownerID {
            throw EntryStorageError.ownershipMismatch
        }
        do {
            let model = existing ?? EntryModel(
                id: entry.id,
                title: entry.title,
                content: entry.content,
                createdAt: entry.createdAt,
                ownerID: ownerID
            )
            if existing == nil { modelContext.insert(model) }
            model.title = entry.title
            model.content = entry.content
            model.createdAt = entry.createdAt
            // Existing relationships stay intact when a caller only edits the entry text.
            if !entry.dialogues.isEmpty {
                let existingDialogueIDs = Set(model.dialogues.map(\.id))
                for dialogue in entry.dialogues where !existingDialogueIDs.contains(dialogue.id) {
                    let dialogueModel = DialogueModel(
                        id: dialogue.id,
                        content: dialogue.content,
                        createAt: dialogue.createdAt,
                        role: dialogue.role
                    )
                    modelContext.insert(dialogueModel)
                    model.dialogues.append(dialogueModel)
                }
            }
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
