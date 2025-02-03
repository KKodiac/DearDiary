import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Registration.self)
struct RegistrationScreen: View {
    @Bindable var store: StoreOf<Registration>
    
    public var body: some View {
        ZStack {
            DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
            
            VStack {
                Spacer()
                titleSection
                registrationForm
                Spacer()
                buttonSection
            }
            .primaryHorizontalPadding()
        }
        .toolbar { toolbarContent }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
    
    private var titleSection: some View {
        Text("Sign Up")
            .secondaryTextStyle()
            .padding(.bottom, Layout.Padding.titleBottom)
    }
    
    private var registrationForm: some View {
        VStack(spacing: Layout.Spacing.form) {
            PrimaryTextField("Your Name", text: $store.name)
                .textContentType(.name)
            PrimaryTextField("Your Email", text: $store.email)
                .textContentType(.emailAddress)
            PrimarySecureField("Password", text: $store.password)
                .textContentType(.newPassword)
            PrimarySecureField("Confirm Password", text: $store.confirmPassword)
                .textContentType(.newPassword)
        }
        .textFieldStyle(SecondaryTextFieldStyle())
        .textInputAutocapitalization(.never)
    }
    
    private var buttonSection: some View {
        VStack {
            PrimaryButton(label: "Sign Up") {
                send(.didTapSignUpWithEmail)
            }
            .padding(.vertical, Layout.Spacing.medium)
            
            Button {
                send(.didTapNavigateToSignIn)
            } label: {
                Text("Go to Sign In")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                    .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
            }
            .padding(.bottom, Layout.Padding.bottom)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                send(.didTapNavigateToBack)
            } label: {
                DesignSystemAsset.back.swiftUIImage.foregroundStyle(.black)
            }
        }
    }
    
    private var errorAlert: some View {
        Button("OK") {
            store.isPresented.toggle()
        }
    }
}
