import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct ChatScreen: View {
    @Bindable var store: StoreOf<Memoir>
    @FocusState private var isComposerFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        VStack(spacing: 8) {
            chatHistory
            if let error = store.errorMessage, !store.composing {
                VStack(alignment: .leading, spacing: 4) {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.red)
                    Button("Retry") { store.send(.didTapRetry) }
                        .disabled(store.isWorking || store.failedMessage == nil)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if store.isWorking && !store.composing {
                ProgressView("Waiting for your diary…")
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            chatInput
        }
        .onChange(of: store.composing) { _, composing in
            if composing { isComposerFocused = false }
        }
    }

    private var chatHistory: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.dialogues, id: \.id) { dialogue in
                    chatBubble(for: dialogue)
                }
            }
            .padding(.vertical, 8)
        }
        .defaultScrollAnchor(.bottom)
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Chat Input
    private var chatInput: some View {
        HStack(alignment: .bottom, spacing: 8) {
            textField
            sendButton
        }
        .sheet(
            isPresented: $store.composing,
            onDismiss: { store.send(.didReceiveCancelled) }
        ) {
            VStack(spacing: 16) {
                if store.isWorking {
                    ProgressView("Writing your diary…")
                } else if let error = store.errorMessage {
                    Text(error).multilineTextAlignment(.center)
                    Button("Retry") { store.send(.didTapRetry) }
                    Button("Cancel", role: .cancel) { store.send(.didReceiveCancelled) }
                }
            }
            .padding(32)
            .presentationDetents([.medium])
        }
    }
    
    private var textField: some View {
        TextField(
            text: $store.dialogue,
            prompt: Text("What happened today?"),
            axis: .vertical
        ) {
            Text("Message")
        }
        .textFieldStyle(
            ChatTextFieldStyle(colorScheme: colorScheme)
        )
        .lineLimit(1...4)
        .focused($isComposerFocused)
        .disabled(store.isWorking)
    }
    
    private var sendButton: some View {
        Button {
            store.send(.didTapSendButton)
        } label: {
            DesignSystemAsset.send.swiftUIImage
                .padding(10)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .background(DesignSystemAsset.ddBackgroundAccent.swiftUIColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            colorScheme == .dark
                            ? DesignSystemAsset.ddSecondary.swiftUIColor
                            : DesignSystemAsset.ddAccent.swiftUIColor
                        )
                }
        }
        .accessibilityLabel("Send message")
        .disabled(store.isWorking || store.dialogue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    // MARK: - Chat Bubble
    private func chatBubble(for content: Dialogue) -> some View {
        HStack {
            if content.role == .user {
                Spacer()
            } else {
                assistantProfile
            }
            
            bubbleContent(for: content)
            
            if content.role == .assistant {
                Spacer()
            }
        }
    }
    
    private var assistantProfile: some View {
        VStack {
            Circle()
                .fill(DesignSystemAsset.ddAccent.swiftUIColor)
                .frame(width: 44, height: 44)
                .overlay {
                    DesignSystemAsset.imoji.swiftUIImage
                }
            Spacer()
        }
    }
    
    private func bubbleContent(for content: Dialogue) -> some View {
        VStack(alignment: .leading) {
            if content.role == .assistant {
                Text(store.diaryName)
                    .font(.subheadline.weight(.semibold))
            }
            
            VStack(alignment: .trailing) {
                messageContent(for: content)
                timestamp(for: content)
            }
            .padding([.top, .leading], content.role == .user ? 0 : 5)
        }
    }
    
    private func messageContent(for content: Dialogue) -> some View {
        VStack {
            Text(content.content)
                .font(.body)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .foregroundStyle(
                    content.role == .user
                    ? .white
                    : colorScheme == .dark
                    ? .white
                    : .black
                )
        }
        .background(
            content.role == .user
            ? DesignSystemAsset.ddAccent.swiftUIColor
            : colorScheme == .dark
            ? DesignSystemAsset.ddPrimary.swiftUIColor
            : Color.white
        )
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: content.role == .user ? 14 : 0,
            bottomLeadingRadius: 14,
            bottomTrailingRadius: 14,
            topTrailingRadius: content.role == .user ? 0 : 14
        ))
    }
    
    private func timestamp(for content: Dialogue) -> some View {
        Text(content.createdAt.formatted(date: .omitted, time: .shortened))
            .font(.footnote)
            .fontWeight(.light)
            .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
    }
}
