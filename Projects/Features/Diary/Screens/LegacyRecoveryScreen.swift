import ComposableArchitecture
import SwiftUI

struct LegacyRecoveryScreen: View {
    let store: StoreOf<LegacyRecovery>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if let error = store.error {
                    Section {
                        Text(error)
                        Button("Reload older entries") { store.send(.load) }
                    }
                }

                if store.isLoading {
                    ProgressView("Looking for older entries…")
                } else if let entry = store.reviewedEntry, let account = store.account {
                    Section("Review entry") {
                        Text(entry.title.isEmpty ? "Untitled entry" : entry.title).font(.headline)
                        Text(entry.createdAt, format: .dateTime.year().month().day().hour().minute())
                        Text(entry.content)
                    }
                    if !entry.dialogues.isEmpty {
                        Section("Conversation") {
                            ForEach(entry.dialogues, id: \.id) { dialogue in
                                LabeledContent(dialogue.role == .user ? "You" : "Assistant") {
                                    Text(dialogue.content)
                                }
                            }
                        }
                    }
                    Section {
                        Text("Signed in as \(account.email ?? account.id)")
                        Text("Confirm only if you wrote this entry. Recovery assigns it to this account on this device.")
                        Button("This is my entry. Recover it.") { store.send(.confirmOwnership) }
                        Button("Back to older entries") { store.send(.cancelReview) }
                        if store.isRecovering {
                            ProgressView("Recovering entry…")
                        }
                    }
                } else if store.hasLoaded {
                    if store.didRecoverEntry {
                        Text("Entry recovered. Find it by its original date or in Search.")
                    }
                    if store.entries.isEmpty {
                        Text("There are no older entries to recover.")
                    } else {
                        Section {
                            ForEach(store.entries, id: \.id) { entry in
                                Button {
                                    store.send(.review(entry))
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(entry.title.isEmpty ? "Untitled entry" : entry.title)
                                        Text(entry.createdAt, format: .dateTime.year().month().day().hour().minute())
                                            .font(.callout)
                                    }
                                }
                            }
                        } header: {
                            Text("Older entries")
                        } footer: {
                            Text("These entries were saved on this device before they were linked to an account. Review each entry before recovering it.")
                        }
                    }
                }
            }
            .disabled(store.isRecovering)
            .navigationTitle("Recover Older Entries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .disabled(store.isRecovering)
                }
            }
        }
        .interactiveDismissDisabled(store.isRecovering)
        .task { await store.send(.load).finish() }
    }
}
