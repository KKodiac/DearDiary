import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Registration.self)
struct RegistrationScreen: View {
    @Bindable public var store: StoreOf<Registration>
    
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, email, password, confirmPassword
    }

    public var body: some View {
        ZStack {
            DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    registrationForm
                    buttonSection
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
    
    private var titleSection: some View {
        Text("Sign Up")
            .font(.largeTitle.bold())
    }
    
    private var registrationForm: some View {
        VStack(spacing: 12) {
            TextField("Your Name", text: $store.name)
                .textContentType(.name)
                .focused($focusedField, equals: .name)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit { focusedField = .email }
            TextField("Your Email", text: $store.email)
                .textContentType(.emailAddress)
                .focused($focusedField, equals: .email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
            SecureField("Password", text: $store.password)
                .textContentType(.newPassword)
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }
            SecureField("Confirm Password", text: $store.confirmPassword)
                .textContentType(.newPassword)
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit { submit() }
        }
        .textFieldStyle(PrimaryTextFieldStyle())
        .disabled(store.isSubmitting)
    }
    
    private var buttonSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(label: "Sign Up") {
                submit()
            }
            .disabled(store.isSubmitting)
            .overlay(alignment: .trailing) {
                if store.isSubmitting {
                    ProgressView()
                        .tint(.white)
                        .padding(.trailing, 16)
                        .accessibilityLabel("Creating your account…")
                }
            }

            Button {
                send(.didTapNavigateToSignIn)
            } label: {
                Text("Go to Sign In")
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
        send(.didTapSignUpWithEmail)
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
