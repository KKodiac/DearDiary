import ComposableArchitecture
import SwiftUI

public struct SettingView: View {
    @Bindable var store: StoreOf<Setting>

    public init(store: StoreOf<Setting>) {
        self.store = store
    }

    public var body: some View {
        Form {
            Section("Your diary") {
                TextField("Diary name", text: $store.draftName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit { store.send(.saveName) }
                Button("Save name") { store.send(.saveName) }
            }
            if let error = store.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Error: \(error)")
                }
            }
            Section {
                Button("Sign out", role: .destructive) { store.send(.requestSignOut) }
                if store.isSigningOut {
                    ProgressView("Signing out…")
                }
            } footer: {
                Text("Signing out keeps diary entries on this device. They are available when you sign back in to the same account.")
            }
        }
        .disabled(store.isSigningOut)
        .navigationBarBackButtonHidden(store.isSigningOut)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Sign out of Dear Diary?", isPresented: $store.isSignOutConfirmationPresented, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { store.send(.confirmSignOut) }
            Button("Cancel", role: .cancel) { store.send(.cancelSignOut) }
        }
    }
}
