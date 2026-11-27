import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Account.self)
public struct AccountView: View {
    @Bindable public var store: StoreOf<Account>
    
    public init(store: StoreOf<Account>) {
        self.store = store
    }
    
    @ViewBuilder
    public var socialSection: some View {
        HStack(spacing: 25) {
            CircularButton(image: DesignSystemAsset.google) {
                send(.didTapSignInWithGoogle)
            }
            
            CircularButton(image: DesignSystemAsset.apple) {
                send(.didTapSignInWithApple)
            }
        }
    }
    
    @ViewBuilder
    public var emailSection: some View {
        VStack {
            PrimaryDivider()
            
            PrimaryButton(label: "Sign Up with Email") {
                send(.didTapSignUpWithEmail)
            }
        }
    }
    
    @ViewBuilder
    public var confirmSection: some View {
        HStack(spacing: 3) {
            Text("Have an Existing Account?")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Button {
                send(.didTapSignInWithEmail)
            } label: {
                Text("Log In")
                    .font(.subheadline.weight(.semibold))
                    .frame(minHeight: 44)
                    .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Dear Diary")
                            .primaryTextStyle()
                            .padding(.bottom, 24)
                        if store.isSubmitting {
                            ProgressView("Signing in…")
                                .font(.callout)
                        } else if store.error != nil {
                            Text("Sign-in is unavailable. Please try again later.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Group {
                            socialSection
                            emailSection
                            confirmSection
                        }
                        .disabled(store.isSubmitting)
                    }
                    .frame(maxWidth: 440)
                    .frame(maxWidth: .infinity)
                    .primaryHorizontalPadding()
                    .padding(.vertical, 32)
                }
                .defaultScrollAnchor(.center, for: .alignment)
            }
            .onOpenURL { url in
                send(.didReceiveOpenURL(url))
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.authentication,
                    action: \.destination.authentication
                )
            ) { store in
                AuthenticationScreen(store: store)
                    .navigationBarBackButtonHidden()
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.registration,
                    action: \.destination.registration
                )
            ) { store in
                RegistrationScreen(store: store)
                    .navigationBarBackButtonHidden()
            }
            .fullScreenCover(
                item: $store.scope(
                    state: \.destination?.setUp,
                    action: \.destination.setUp
                )
            ) { store in
                SetupScreen(store: store)
                    .navigationBarBackButtonHidden()
            }
            .onAppear {
                send(.didAppear)
            }
        }
    }
}
