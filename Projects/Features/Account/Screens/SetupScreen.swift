import ComposableArchitecture
import SwiftUI
import DesignSystem

@ViewAction(for: Setup.self)
struct SetupScreen: View {
    @Bindable public var store: StoreOf<Setup>
    
    @FocusState private var isNameFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleSection
                formSection
                if let error = store.errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                getStartedButton
            }
            .frame(maxWidth: 440)
            .frame(maxWidth: .infinity)
            .primaryHorizontalPadding()
            .padding(.vertical, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea())
        .onAppear { send(.didAppear) }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack {
            Text("Dear Diary")
                .primaryTextStyle()
            
            DesignSystemAsset.diary.swiftUIImage
                .accessibilityHidden(true)
        }
    }
    
    private var formSection: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.medium) {
            diaryNameSection
            personalitySection
        }
    }
    
    private var diaryNameSection: some View {
        VStack(alignment: .leading) {
            Text("Name your diary...")
                .font(.subheadline)
            
            TextField(text: Binding(store.$name)) {
                Text("ex) Kitty")
            }
            .textFieldStyle(PrimaryTextFieldStyle())
            .focused($isNameFocused)
            .submitLabel(.done)
            .onSubmit { isNameFocused = false }
        }
    }
    
    private var personalitySection: some View {
        VStack(alignment: .leading) {
            Text("Select the personality of your diary...")
                .font(.subheadline)
                .padding(.top, Layout.Padding.top)
            
            personalityPicker
        }
    }
    
    private var personalityPicker: some View {
        DisclosureGroup(
            isExpanded: $store.expanded,
            content: { personalityOptions },
            label: { Text(store.personality.rawValue) }
        )
        .padding(Layout.Padding.form)
        .background(DesignSystemAsset.ddFill.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))
        .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
        .overlay {
            RoundedRectangle(cornerRadius: Layout.CornerRadius.medium)
                .stroke(DesignSystemAsset.ddSolid.swiftUIColor)
        }
    }
    
    private var personalityOptions: some View {
        ForEach(store.personalities, id: \.self) { personality in
            Divider()
            Button {
                send(.didTapPicker(personality))
            } label: {
                HStack {
                    Text(personality.rawValue).font(.headline)
                    Spacer()
                }
            }
        }
    }
    
    private var getStartedButton: some View {
        PrimaryButton(label: "Get Started") {
            isNameFocused = false
            send(.didTapGetStarted)
        }
    }
}
