import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ResultScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var store: StoreOf<Result>
    
    public var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                editButton
            }
            .onAppear { store.send(.didAppear) }
            .padding(.horizontal)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
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
            date: store.entry!.createdDate
        )
        .padding(.bottom, 10)
    }
    
    private var titleText: some View {
        Text(store.title)
            .font(
                DesignSystemFontFamily.Pretendard.bold
                    .swiftUIFont(size: 23)
            )
    }
    
    private var contentEditor: some View {
        TextEditor(text: $store.content)
            .multilineTextAlignment(.leading)
            .disabled(!store.editable)
    }
    
    // MARK: - Edit Button
    private var editButton: some View {
        VStack(alignment: .trailing) {
            Spacer()
            HStack {
                Spacer()
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
        }
        .padding(.trailing, 10)
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

