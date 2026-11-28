import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem

public struct ResultScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var store: StoreOf<Result>
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if store.entry != nil {
                    mainContent
                        .safeAreaInset(edge: .bottom, alignment: .trailing) {
                            editButton
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .background(.background)
                        }
                } else {
                    ContentUnavailableView(
                        "Diary entry unavailable",
                        systemImage: "doc.questionmark",
                        description: Text("Go back and compose your diary entry again.")
                    )
                }
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
            if let error = store.saveError {
                Text(error).font(.callout)
            }
        }
    }
    
    @ViewBuilder
    private var dateDivider: some View {
        if let entry = store.entry {
            DateDivider(
                colorScheme: colorScheme,
                date: Calendar.current.startOfDay(for: entry.createdAt)
            )
            .padding(.bottom, 10)
        }
    }
    
    private var titleText: some View {
        Text(store.title)
            .font(.title2.bold())
            .accessibilityAddTraits(.isHeader)
    }
    
    @ViewBuilder
    private var contentEditor: some View {
        if store.editable && !store.isSaving {
            TextEditor(text: $store.content)
                .accessibilityLabel("Diary entry")
        } else {
            ScrollView {
                Text(store.content)
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
                .foregroundStyle(.white)
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
            Text(store.isSaving ? "Saving…" : "Save")
                .padding(.horizontal, 10)
        }
        .buttonStyle(ToolbarPrimaryButtonStyle())
        .disabled(store.entry == nil || store.isSaving)
    }
}

