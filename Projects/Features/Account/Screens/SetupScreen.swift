import ComposableArchitecture
import SwiftUI
import DesignSystem

@ViewAction(for: Setup.self)
struct SetupScreen: View {
    @Bindable var store: StoreOf<Setup>
    
    var body: some View {
        VStack {
            Spacer()
            Text("Dear Diary")
                .primaryTextStyle()
                .offset(y: Layout.Offset.title)
            
            DesignSystemAsset.diary.swiftUIImage
            Spacer()
            
            VStack(alignment: .leading, spacing: Layout.Spacing.medium) {
                Text("Name your diary...")
                    .font(
                        DesignSystemFontFamily.Pretendard.regular
                            .swiftUIFont(size: 14)
                    )
                
                TextField(text: $store.name) {
                    Text("ex) Kitty")
                }
                .textFieldStyle(PrimaryTextFieldStyle())
                
                Text("Select the personality of your diary...")
                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .padding(.top, Layout.Padding.top)
                
                DisclosureGroup(
                    isExpanded: $store.expanded,
                    content: {
                        ForEach(store.personalities, id: \.self) { personality in
                            Divider()
                            Button { } label: {
                                HStack {
                                    Text(personality.rawValue).font(.headline)
                                    Spacer()
                                }
                            }
                        }
                    },
                    label: {
                        Text(store.personality.rawValue)
                    }
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
            Spacer()
            PrimaryButton(label: "Get Started") { }
        }
        .padding(.all)
        .padding(.horizontal)
        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
        .onAppear { }
    }
}
