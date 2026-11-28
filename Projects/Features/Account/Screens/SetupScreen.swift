import ComposableArchitecture
import SwiftUI
import DesignSystem

@ViewAction(for: Setup.self)
struct SetupScreen: View {
    @Bindable public var store: StoreOf<Setup>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleSection
                formSection
                if let error = store.errorMessage {
                    Text(error).font(.callout).foregroundStyle(.secondary)
                }
                getStartedButton
            }
            .padding(24)
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
                .accessibilityAddTraits(.isHeader)
            
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
                .accessibilityHidden(true)
            
            TextField(text: $store.name) {
                Text("ex) Kitty")
            }
            .textFieldStyle(PrimaryTextFieldStyle())
            .accessibilityLabel("Diary name")
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
            label: {
                Text(store.personality.rawValue)
                    .frame(minHeight: 44)
                    .accessibilityLabel("Diary personality")
                    .accessibilityValue(store.personality.rawValue)
            }
        )
        .padding(Layout.Padding.form)
        .background(DesignSystemAsset.ddFill.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))
        .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
        .overlay {
            RoundedRectangle(cornerRadius: Layout.CornerRadius.medium)
                .stroke(DesignSystemAsset.ddPrimary.swiftUIColor)
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
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .accessibilityAddTraits(store.personality == personality ? .isSelected : [])
        }
    }
    
    private var getStartedButton: some View {
        PrimaryButton(label: "Get Started") {
            send(.didTapGetStarted)
        }
    }
}
