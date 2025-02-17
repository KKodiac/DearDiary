import AuthenticationServices
import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct MemoirScreen: View {
    @Bindable var store: StoreOf<Memoir>
    @Environment(\.colorScheme) private var colorScheme
    
    public init(store: StoreOf<Memoir>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea(.container, edges: .bottom)
            VStack {
                headerSection
                mainContent
            }
        }
        .navigationBarBackButtonHidden()
        .toolbarRole(.navigationStack)
        .toolbarBackground(.visible, for: .navigationBar)
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.result,
                action: \.destination.result
            )
        ) { store in
            ResultScreen(store: store)
        }
        .toolbar { toolbarContent }
    }
    
    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            navigationHeader
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            settingsButton
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        Group {
            if store.showHeader {
                expandedHeader
                    .opacity(store.state.initialized ? 1 : 0)
            } else {
                collapsedHeader
            }
        }
    }
    
    private var expandedHeader: some View {
        VStack {
            headerDivider
            actionButtons
        }
        .safeAreaPadding(.top)
        .background(
            DesignSystemAsset.toolbarBackground.swiftUIColor
                .shadow(radius: 3, y: 2)
        )
    }
    
    private var headerDivider: some View {
        Divider()
            .foregroundStyle(DesignSystemAsset.ddSecondary.swiftUIColor)
            .overlay {
                Text("Should I ask \(store.diaryName) to write your diary?")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 15)
                    .font(.caption)
                    .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
                    .background(DesignSystemAsset.toolbarBackground.swiftUIColor)
            }
            .padding([.horizontal, .bottom])
    }
    
    private var actionButtons: some View {
        HStack {
            composeButton
            hideButton
        }
        .padding(.bottom)
        .padding(.horizontal, 40)
    }
    
    private var collapsedHeader: some View {
        Button {
            store.send(.didTapToggleHeaderButton, animation: .bouncy)
        } label: {
            Image(systemName: "arrowshape.down.fill")
                .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .padding(.top, 10)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack {
            Spacer()
                .onAppear { store.send(.didAppear, animation: .bouncy) }
            
            contentContainer
        }
    }
    
    private var contentContainer: some View {
        VStack {
            if store.state.initialized {
                ChatScreen(store: store)
            } else {
                initialView
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray.opacity(0.35), lineWidth: 2)
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Supporting Views
    private var navigationHeader: some View {
        HStack {
            backButton
            profileImage
            profileInfo
        }
        .padding(.vertical)
    }
    
    private var backButton: some View {
        Button {
            store.send(.didTapNavigateToBack)
        } label: {
            DesignSystemAsset.back.swiftUIImage.foregroundStyle(.black)
        }
    }
    
    private var profileImage: some View {
        Circle()
            .fill(DesignSystemAsset.ddAccent.swiftUIColor)
            .frame(width: 40, height: 40)
            .overlay {
                DesignSystemAsset.imoji.swiftUIImage
            }
    }
    
    private var profileInfo: some View {
        VStack(alignment: .leading) {
            Text("\(store.diaryName)")
                .fontWeight(.medium)
            Text("My AI Diary")
                .font(.caption)
        }
    }
    
    private var composeButton: some View {
        Button {
            store.send(.didTapComposeButton)
        } label: {
            HStack {
                Spacer()
                Text("Compose")
                Spacer()
            }
        }
        .buttonStyle(ComposeButtonStyle())
    }
    
    private var hideButton: some View {
        Button {
            store.send(.didTapToggleHeaderButton, animation: .bouncy)
        } label: {
            HStack {
                Spacer()
                Text("Hide")
                    .foregroundStyle(
                        colorScheme == .dark
                        ? DesignSystemAsset.ddSecondary.swiftUIColor
                        : DesignSystemAsset.ddAccent.swiftUIColor
                    )
                Spacer()
            }
        }
        .buttonStyle(PauseButtonStyle(colorScheme: colorScheme))
    }
    
    private var initialView: some View {
        Group {
            DesignSystemAsset.character.swiftUIImage
            Text("Say 'Hello!' to your Diary!")
                .opacity(0.6)
                .padding(.bottom, 20)
            
            Button("Hello, \(store.diaryName)") {
                store.send(.didTapSayHelloButton)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
    
    private var settingsButton: some View {
        Button {
            // Settings action
        } label: {
            Image(systemName: "gearshape.fill")
                .tint(DesignSystemAsset.ddPrimary.swiftUIColor)
        }
    }
}
