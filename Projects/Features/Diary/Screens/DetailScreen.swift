import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct DiaryDetailView: View {
    @Bindable var store: StoreOf<Detail>
    @FocusState private var isEditorFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    public init(store: StoreOf<Detail>) {
        self.store = store
    }
    
    public var body: some View {
        mainContent
            .padding(.horizontal)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(alignment: .leading) {
            dateDivider
            titleText
            contentEditor
        }
    }
    
    private var dateDivider: some View {
        DateDivider(
            colorScheme: colorScheme,
            date: store.entry.createdAt
        )
        .padding(.bottom, 10)
    }
    
    private var titleText: some View {
        Text(store.entry.title)
            .font(.title2.bold())
    }
    
    private var contentEditor: some View {
        TextEditor(text: $store.entry.content)
            .font(.body)
            .focused($isEditorFocused)
            .onChange(of: store.editable) { _, editable in
                isEditorFocused = editable
            }
            .scrollDismissesKeyboard(.interactively)
            .multilineTextAlignment(.leading)
            .disabled(!store.editable)
    }
    
    private var editButton: some View {
        Button {
            store.send(.didTapEditButton)
        } label: {
            Label(
                store.editable ? "Done editing" : "Edit entry",
                systemImage: store.editable ? "checkmark" : "pencil"
            )
            .labelStyle(.iconOnly)
        }
    }

    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            backButton
        }
        
        ToolbarItem(placement: .principal) {
            dateTitle
        }
        
        ToolbarItemGroup(placement: .topBarTrailing) {
            editButton
            saveButton
        }
    }
    
    private var backButton: some View {
        Button {
            store.send(.didTapBackButton)
        } label: {
            Label("Back", systemImage: "chevron.backward")
                .labelStyle(.iconOnly)
        }
    }
    
    private var dateTitle: some View {
        Text(store.entry.createdAt, format: .dateTime.month(.abbreviated).year())
            .bold()
    }

    private var saveButton: some View {
        Button {
            isEditorFocused = false
            store.send(.didTapSaveButton)
        } label: {
            Text("Save")
                .padding(.horizontal, 10)
        }
        .buttonStyle(ToolbarPrimaryButtonStyle())
    }
}
