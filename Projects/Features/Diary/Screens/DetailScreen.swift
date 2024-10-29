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
        ZStack {
            mainContent
            editButtonOverlay
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
            .font(
                DesignSystemFontFamily.Pretendard.bold
                    .swiftUIFont(size: 23)
            )
    }
    
    private var contentEditor: some View {
        TextEditor(text: $store.entry.content)
            .multilineTextAlignment(.leading)
            .disabled(!store.editable)
    }
    
    // MARK: - Edit Button
    private var editButtonOverlay: some View {
        VStack(alignment: .trailing) {
            Spacer()
            HStack {
                Spacer()
                editButton
            }
        }
        .padding(.trailing, 10)
    }
    
    private var editButton: some View {
        Button {
            store.send(.didTapEditButton)
        } label: {
            Image(systemName: store.editable ? "checkmark" : "pencil")
                .bold()
                .foregroundColor(.white)
                .padding()
        }
        .background(DesignSystemAsset.ddAccent.swiftUIColor)
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
            DesignSystemAsset.back.swiftUIImage
                .foregroundStyle(.black)
        }
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
