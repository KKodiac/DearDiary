import ComposableArchitecture
import SwiftUI
import DesignSystem

@ViewAction(for: Setup.self)
struct SetupScreen: View {
    @Bindable var store: StoreOf<Setup>
    
    var body: some View {
        VStack {
            Spacer()
            titleSection
            Spacer()
            formSection
            Spacer()
            getStartedButton
        }
        .padding(.all)
        .padding(.horizontal)
        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
        .onAppear { send(.didAppear) }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack {
            Text("Dear Diary")
                .primaryTextStyle()
                .offset(y: Layout.Offset.title)
            
            DesignSystemAsset.diary.swiftUIImage
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
                .font(
                    DesignSystemFontFamily.Pretendard.regular
                        .swiftUIFont(size: 14)
                )
            
            TextField(text: $store.name) {
                Text("ex) Kitty")
            }
            .textFieldStyle(PrimaryTextFieldStyle())
        }
    }
    
    private var personalitySection: some View {
        VStack(alignment: .leading) {
            Text("Select the personality of your diary...")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
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
            send(.didTapGetStarted)
        }
    }
}
