import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Authentication.self)
struct AuthenticationScreen: View {
    @Bindable public var store: StoreOf<Authentication>
    
    public var body: some View {
        ZStack {
            DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    welcomeSection
                    socialLoginButtons
                    PrimaryDivider().padding(.vertical, Layout.Spacing.medium)
                    credentialsSection
                    loginSection
                }
                .primaryHorizontalPadding()
                .padding(.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar { toolbarContent }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
    
    @ViewBuilder
    private var welcomeSection: some View {
        Text("Welcome Back")
            .secondaryTextStyle()
            .accessibilityAddTraits(.isHeader)
            .padding(.bottom, Layout.Padding.bottom)
    }
    
    @ViewBuilder
    private var socialLoginButtons: some View {
        HStack(spacing: Layout.Spacing.extraLarge) {
            CircularButton(image: DesignSystemAsset.google) {
                send(.didTapSignInWithGoogle)
            }
            .accessibilityLabel("Sign in with Google")
            CircularButton(image: DesignSystemAsset.apple) {
                send(.didTapSignInWithApple)
            }
            .accessibilityLabel("Sign in with Apple")
        }
    }
    
    @ViewBuilder
    private var credentialsSection: some View {
        VStack(spacing: Layout.Spacing.form) {
            PrimaryTextField("Your Email", text: $store.email)
                .textContentType(.emailAddress)
            PrimarySecureField("Password", text: $store.password)
                .textContentType(.newPassword)
        }
        .textFieldStyle(SecondaryTextFieldStyle())
        .textInputAutocapitalization(.never)
    }
    
    @ViewBuilder
    private var loginSection: some View {
        VStack {
            PrimaryButton(label: "Log In") {
                send(.didTapSignInWithEmail)
            }
            .padding(.vertical, Layout.Spacing.medium)
            
            Button {
                send(.didTapNavigateToSignUp)
            } label: {
                Text("Go to Sign Up")
                    .font(.subheadline.bold())
                    .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
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
                Image(systemName: "chevron.backward")
                    .foregroundStyle(.primary)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Back")
        }
    }
}
