
import Foundation
import SwiftData
import Testing
import Persistence
@MainActor
struct EntryPersistenceTests {
    @Test
    func migratesAndPersistsEntriesWithoutCrossingAccountBoundaries() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("diary.store")
        let date = Date(timeIntervalSince1970: 1700000000)
        let legacyID = UUID()
        try autoreleasepool {
            let schema = Schema(versionedSchema: PersistenceSchemaV1.self)
            let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: url)])
            let context = ModelContext(container)
            let user = PersistenceSchemaV1.UserModel(name: "Legacy", email: "legacy@example.com", password: nil)
            let dialogue = PersistenceSchemaV1.DialogueModel(content: "Hello", createAt: date, role: .user)
            let entry = PersistenceSchemaV1.EntryModel(id: legacyID, title: "Legacy title", content: "Legacy content", createdAt: date, user: user, dialogues: [dialogue])
            context.insert(entry)
            try context.save()
        }
        let schema = Schema(versionedSchema: PersistenceSchemaV2.self)
        func open() throws -> ModelContainer {
            try PersistenceClient.makeModelContainer(configuration: ModelConfiguration(schema: schema, url: url))
        }
        let container = try open()
        let context = ModelContext(container)
        let migrated = try context.fetch(FetchDescriptor<EntryModel>())
        try #require(migrated.count == 1)
        #expect(migrated[0].id == legacyID && migrated[0].ownerID == nil)
        #expect(migrated[0].user?.name == "Legacy" && migrated[0].dialogues.first?.content == "Hello")
        let repository = try PersistenceClient(modelContainer: container).entry
        let intervalStart = date.addingTimeInterval(-10)
        let intervalEnd = date.addingTimeInterval(10)
        let unowned = try await repository.entries(from: intervalStart, until: intervalEnd, ownerID: "alice")
        #expect(unowned.isEmpty)
        let id = UUID()
        let dialogue = StoredDialogue(id: UUID(), content: "New dialogue", createdAt: date, role: .assistant)
        try await repository.save(StoredEntry(id: id, title: "New", content: "Content", createdAt: date, dialogues: [dialogue]), ownerID: "alice")
        try await repository.save(StoredEntry(id: id, title: "Edited", content: "Edited content", createdAt: date), ownerID: "alice")
        let alice = try await repository.entries(from: intervalStart, until: intervalEnd, ownerID: "alice")
        #expect(alice.count == 1 && alice[0].title == "Edited" && alice[0].dialogues == [dialogue])
        try await repository.save(
            StoredEntry(id: UUID(), title: "Next day", content: "Outside range", createdAt: intervalEnd),
            ownerID: "alice"
        )
        let sameDay = try await repository.entries(from: intervalStart, until: intervalEnd, ownerID: "alice")
        #expect(sameDay == alice)
        let bob = try await repository.entries(from: intervalStart, until: intervalEnd, ownerID: "bob")
        #expect(bob.isEmpty)
        do {
            try await repository.save(alice[0], ownerID: "bob")
            Issue.record("Cross-account overwrite allowed")
        } catch EntryStorageError.ownershipMismatch { }
        do {
            try await repository.save(StoredEntry(id: legacyID, title: "Claim", content: "Claim", createdAt: date), ownerID: "alice")
            Issue.record("Legacy entry silently claimed")
        } catch EntryStorageError.ownershipMismatch { }
        let reopened = try PersistenceClient(modelContainer: open()).entry
        let reloaded = try await reopened.entries(from: intervalStart, until: intervalEnd, ownerID: "alice")
        #expect(reloaded == alice)

        let legacy = try await reopened.legacyEntries()
        let original = try #require(legacy.first)
        #expect(legacy.map(\.id) == [legacyID])
        #expect(original.title == "Legacy title")
        #expect(original.content == "Legacy content")
        #expect(original.dialogues.map(\.content) == ["Hello"])

        try await reopened.recoverLegacyEntry(id: legacyID, ownerID: "alice")
        try await reopened.recoverLegacyEntry(id: legacyID, ownerID: "alice")
        await #expect(throws: EntryStorageError.ownershipMismatch) {
            try await reopened.recoverLegacyEntry(id: legacyID, ownerID: "bob")
        }

        let afterRecovery = try PersistenceClient(modelContainer: open()).entry
        let remaining = try await afterRecovery.legacyEntries()
        let recovered = try await afterRecovery.search(query: "Legacy content", ownerID: "alice")
        let otherAccount = try await afterRecovery.search(query: "Legacy content", ownerID: "bob")
        let recoveredDiary = try await afterRecovery.entries(from: intervalStart, until: intervalEnd, ownerID: "alice")
        #expect(remaining.isEmpty)
        #expect(recovered == [original])
        #expect(otherAccount.isEmpty)
        #expect(recoveredDiary.contains(original))

    }
}

extension EntryPersistenceTests {
    @Test
    func searchesTitleAndContentWithinCurrentAccount() async throws {
        let schema = Schema(versionedSchema: PersistenceSchemaV2.self)
        let container = try PersistenceClient.makeModelContainer(
            configuration: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        context.insert(EntryModel(title: "Café legacy", content: "Unassigned", createdAt: .now))
        try context.save()
        let repository = try PersistenceClient(modelContainer: container).entry
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let older = StoredEntry(id: UUID(), title: "Café morning", content: "A calm day", createdAt: date)
        let newer = StoredEntry(id: UUID(), title: "Evening walk", content: "A cafe after walking", createdAt: date.addingTimeInterval(10))
        let otherAccount = StoredEntry(id: UUID(), title: "Café with Bob", content: "Private", createdAt: date.addingTimeInterval(20))
        try await repository.save(older, ownerID: "alice")
        try await repository.save(newer, ownerID: "alice")
        try await repository.save(otherAccount, ownerID: "bob")

        let matches = try await repository.search(query: "  CAFÉ \n", ownerID: "alice")
        #expect(matches == [newer, older])
        let titleMatches = try await repository.search(query: "MORNING", ownerID: "alice")
        #expect(titleMatches == [older])
        let contentMatches = try await repository.search(query: "walking", ownerID: "alice")
        #expect(contentMatches == [newer])
        let bobMatches = try await repository.search(query: "cafe", ownerID: "bob")
        #expect(bobMatches == [otherAccount])
        let empty = try await repository.search(query: " \n\t", ownerID: "alice")
        #expect(empty.isEmpty)
        let absent = try await repository.search(query: "unmatched", ownerID: "alice")
        #expect(absent.isEmpty)
        let legacy = try await repository.search(query: "legacy", ownerID: "alice")
        #expect(legacy.isEmpty)
        do {
            _ = try await repository.search(query: "cafe", ownerID: "")
            Issue.record("Search allowed without an account owner")
        } catch EntryStorageError.missingOwner { }
    }
}
