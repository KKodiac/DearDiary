import ComposableArchitecture
import Foundation
import Persistence
import Testing
@testable import Diary

@MainActor
struct ResultTests {
    @Test
    func missingEntryClearsDraftAndPreventsEditingOrSaving() async {
        var state = Result.State(editable: true)
        state.title = "Stale title"
        state.content = "Stale content"
        let store = TestStore(initialState: state) {
            Result()
        }

        await store.send(.didAppear)
        await store.receive(.didReceiveEntryNil) {
            $0.editable = false
            $0.title = ""
            $0.content = ""
        }
        await store.send(.didTapEditButton)
        await store.send(.didTapSaveButton)
        await store.finish()
    }
}

extension ResultTests {
    @Test
    func failedSaveKeepsDraftAndCanRetry() async {
        let recorder = SaveAttempts()
        let entry = Entry(id: UUID(), title: "Original", content: "Content", createdAt: .now)
        let dialogue = Dialogue(id: UUID(), content: "Conversation", createdAt: entry.createdAt, role: .user)
        var state = Result.State(entry: entry, dialogues: [dialogue])
        state.$uid = Shared(value: "alice")
        state.title = "Edited title"
        state.content = "Edited draft"
        let store = TestStore(initialState: state) { Result() } withDependencies: {
            $0.entryStore.save = { record, ownerID in
                #expect(ownerID == "alice")
                #expect(record.id == entry.id)
                #expect(record.title == "Edited title" && record.content == "Edited draft")
                #expect(record.dialogues.first?.id == dialogue.id)
                try await recorder.save()
            }
        }
        await store.send(.didTapSaveButton) { $0.isSaving = true }
        await store.receive(.didFailSaving) {
            $0.isSaving = false
            $0.saveError = "Your diary couldn’t be saved. Your draft is still here. Tap Save to try again."
        }
        await store.send(.didTapSaveButton) {
            $0.isSaving = true
            $0.saveError = nil
        }
        await store.receive(.didSaveEntry) {
            $0.isSaving = false
            var updated = entry
            updated.title = "Edited title"
            updated.content = "Edited draft"
            $0.entry = updated
        }
        #expect(await recorder.count == 2)
    }

    @Test
    func duplicateSaveIsIgnoredWhileSaving() async {
        var state = Result.State(entry: Entry.mock[0])
        state.isSaving = true
        let store = TestStore(initialState: state) { Result() }
        await store.send(.didTapSaveButton)
        await store.send(.didTapEditButton)
    }
}

private actor SaveAttempts {
    var count = 0
    func save() throws {
        count += 1
        if count == 1 { throw EntryStorageError.missingOwner }
    }
}
