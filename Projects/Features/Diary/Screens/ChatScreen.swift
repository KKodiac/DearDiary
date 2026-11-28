import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct ChatScreen: View {
    @Bindable var store: StoreOf<Memoir>
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        VStack {
            if let error = store.errorMessage, !store.composing {
                VStack(alignment: .leading, spacing: 4) {
                    Text(error).font(.footnote)
                    Button {
                        store.send(.didTapRetry)
                    } label: {
                        Text("Retry")
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .disabled(store.isWorking || store.failedMessage == nil)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
            }
            if store.isWorking && !store.composing {
                ProgressView("Waiting for your diary…").font(.footnote)
            }
            chatHistory
            chatInput
        }
    }
    
    // MARK: - Chat History
    private var chatHistory: some View {
        ScrollView {
            ScrollViewReader { proxy in
                ForEach(store.dialogues, id: \.id) { dialogue in
                    chatBubble(for: dialogue)
                        .id(dialogue.id)
                }
                .onChange(of: store.dialogues) { _, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue.last?.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Chat Input
    private var chatInput: some View {
        HStack(alignment: .bottom) {
            textField
            Spacer()
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
            .presentationDetents([.medium, .large])
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
        .accessibilityLabel("Message")
        .onSubmit { store.send(.didTapSendButton) }
        .disabled(store.isWorking)
    }
    
    private var sendButton: some View {
        Button {
            store.send(.didTapSendButton)
        } label: {
            DesignSystemAsset.send.swiftUIImage
                .renderingMode(.template)
                .foregroundStyle(.primary)
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
                assistantProfile.accessibilityHidden(true)
            }
            
            bubbleContent(for: content)
            
            if content.role == .assistant {
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(content.role == .user ? "You" : store.diaryName)
        .accessibilityValue("\(content.content), \(content.createdAt.formatted(date: .omitted, time: .shortened))")
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
                Text("\(store.diaryName)")
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
                    content.role == .user ? Color.white : Color.primary
                )
        }
        .background(
            content.role == .user
            ? DesignSystemAsset.ddAccentFill.swiftUIColor
            : DesignSystemAsset.ddSecondaryBackground.swiftUIColor
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
