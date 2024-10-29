import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct ChatScreen: View {
    @Bindable var store: StoreOf<Memoir>
    @AppStorage("DiaryName") private var diaryName: String?
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        VStack {
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
            // Sheet content
        }
    }
    
    private var textField: some View {
        TextField(
            text: $store.dialogue,
            prompt: Text("What happened today?"),
            axis: .vertical
        ) {
            Text("Hello World")
        }
        .textFieldStyle(
            ChatTextFieldStyle(colorScheme: colorScheme)
        )
        .onSubmit { store.send(.didTapSendButton) }
    }
    
    private var sendButton: some View {
        Button {
            store.send(.didTapSendButton)
        } label: {
            DesignSystemAsset.send.swiftUIImage
                .padding(10)
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
        .padding(.vertical, 10)
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
                .font(.subheadline)
                .fontWeight(.light)
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
