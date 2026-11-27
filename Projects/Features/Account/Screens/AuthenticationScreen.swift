import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Authentication.self)
struct AuthenticationScreen: View {
    @Bindable public var store: StoreOf<Authentication>
    
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email, password
    }

    public var body: some View {
        ZStack {
            DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    welcomeSection
                    socialLoginButtons
                        .disabled(store.isSubmitting)
                    if store.isSubmitting {
                        ProgressView("Signing in…")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    PrimaryDivider()
                    credentialsSection
                    loginSection
                }
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
                .primaryHorizontalPadding()
                .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar { toolbarContent }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
    
    @ViewBuilder
    private var welcomeSection: some View {
        Text("Welcome Back")
            .font(.largeTitle.bold())
    }
    
    @ViewBuilder
    private var socialLoginButtons: some View {
        HStack(spacing: Layout.Spacing.extraLarge) {
            CircularButton(image: DesignSystemAsset.google) {
                focusedField = nil
                send(.didTapSignInWithGoogle)
            }
            CircularButton(image: DesignSystemAsset.apple) {
                focusedField = nil
                send(.didTapSignInWithApple)
            }
        }
    }
    
    @ViewBuilder
    private var credentialsSection: some View {
        VStack(spacing: 12) {
            TextField("Your Email", text: Binding(store.$email))
                .textContentType(.emailAddress)
                .focused($focusedField, equals: .email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
            SecureField("Password", text: Binding(store.$password))
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit { submit() }
        }
        .textFieldStyle(PrimaryTextFieldStyle())
        .disabled(store.isSubmitting)
    }
    
    @ViewBuilder
    private var loginSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(label: "Log In") {
                submit()
            }
            .disabled(store.isSubmitting)


            Button {
                send(.didTapNavigateToSignUp)
            } label: {
                Text("Go to Sign Up")
                    .font(.subheadline.weight(.semibold))
                    .frame(minHeight: 44)
                    .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
            }
            .disabled(store.isSubmitting)
        }
    }
    
    private func submit() {
        guard !store.isSubmitting else { return }
        focusedField = nil
        send(.didTapSignInWithEmail)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                send(.didTapNavigateToBack)
            } label: {
                Label("Back", systemImage: "chevron.backward")
                    .labelStyle(.iconOnly)
            }
            .disabled(store.isSubmitting)
        }
    }
}
