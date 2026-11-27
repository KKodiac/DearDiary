import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct DiaryDetailView: View {
    @Bindable var store: StoreOf<Detail>
    @Environment(\.colorScheme) private var colorScheme
    
    public init(store: StoreOf<Detail>) {
        self.store = store
    }
    
    public var body: some View {
        mainContent
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                editButton.padding(.vertical, 8)
            }
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
            .accessibilityAddTraits(.isHeader)
    }
    
    @ViewBuilder
    private var contentEditor: some View {
        if store.editable {
            TextEditor(text: $store.entry.content)
                .accessibilityLabel("Diary entry")
        } else {
            ScrollView {
                Text(store.entry.content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
    }
    
    // MARK: - Edit Button
    private var editButton: some View {
        Button {
            store.send(.didTapEditButton)
        } label: {
            Image(systemName: store.editable ? "checkmark" : "pencil")
                .bold()
                .foregroundColor(.white)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Circle())
        }
        .accessibilityLabel(store.editable ? "Finish editing" : "Edit entry")
        .background(DesignSystemAsset.ddAccentFill.swiftUIColor)
        .clipShape(Circle())
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
        
        ToolbarItem(placement: .topBarTrailing) {
            saveButton
        }
    }
    
    private var backButton: some View {
        Button {
            store.send(.didTapBackButton)
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundStyle(.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Back")
    }
    
    private var dateTitle: some View {
        Text(
            "\(String(Calendar.current.component(.year, from: Date.now))).\(Calendar.current.component(.month, from: Date.now))"
        ).bold()
    }
    
    private var saveButton: some View {
        Button {
            store.send(.didTapSaveButton)
        } label: {
            Text("Save")
                .padding(.horizontal, 10)
        }
        .buttonStyle(ToolbarPrimaryButtonStyle())
    }
}
