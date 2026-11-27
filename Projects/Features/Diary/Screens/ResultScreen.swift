import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem

public struct ResultScreen: View {
    @FocusState private var isEditorFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var store: StoreOf<Result>
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if store.entry != nil {
                    mainContent
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
                Text(error).foregroundStyle(.red).font(.callout)
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
    }
    
    private var contentEditor: some View {
        TextEditor(text: $store.content)
            .font(.body)
            .focused($isEditorFocused)
            .onChange(of: store.editable) { _, editable in
                isEditorFocused = editable
            }
            .scrollDismissesKeyboard(.interactively)
            .multilineTextAlignment(.leading)
            .disabled(!store.editable || store.isSaving)
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
        .disabled(store.isSaving)
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
            if store.entry != nil { editButton }
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
        Text(
            "\(String(Calendar.current.component(.year, from: Date.now))).\(Calendar.current.component(.month, from: Date.now))"
        ).bold()
    }
    
    private var saveButton: some View {
        Button {
            isEditorFocused = false
            store.send(.didTapSaveButton)
        } label: {
            HStack(spacing: 6) {
                if store.isSaving {
                    ProgressView().tint(.white)
                }
                Text(store.isSaving ? "Saving…" : "Save")
            }
            .padding(.horizontal, 8)
        }
        .buttonStyle(ToolbarPrimaryButtonStyle())
        .disabled(store.entry == nil || store.isSaving)
    }
}

