import AuthenticationServices
import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Authentication.self)
struct AuthenticationScreen: View {
    @Bindable var store: StoreOf<Authentication>
    @Environment(\.authorizationController) private var controller
    
    public var body: some View {
        ZStack {
            DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
            
            VStack {
                Spacer()
                welcomeSection
                socialLoginButtons
                PrimaryDivider().padding(.vertical, Layout.Spacing.medium)
                credentialsSection
                Spacer()
                loginSection
            }
            .primaryHorizontalPadding()
        }
        .toolbar { toolbarContent }
        .alert(isPresented: $store.isPresented, error: store.error) { errorAlert }
    }
    
    private var welcomeSection: some View {
        Text("Welcome Back")
            .secondaryTextStyle()
            .padding(.bottom, Layout.Padding.bottom)
    }
    
    private var socialLoginButtons: some View {
        HStack(spacing: Layout.Spacing.extraLarge) {
            CircularButton(image: DesignSystemAsset.google) {
                let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let viewController = firstScene?.windows.first?.rootViewController
                send(.didTapSignInWithGoogle(viewController))
            }
            CircularButton(image: DesignSystemAsset.apple) {
                send(.didTapSignInWithApple(controller))
            }
        }
    }
    
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
    
    private var loginSection: some View {
        VStack {
            PrimaryButton(label: "Log In") {
                // Add login action
            }
            .padding(.vertical, Layout.Spacing.medium)
            
            Button {
                // Add navigation action
            } label: {
                Text("Go to Sign Up")
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
