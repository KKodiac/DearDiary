import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Account.self)
public struct AccountView: View {
    @Bindable public var store: StoreOf<Account>
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    public init(store: StoreOf<Account>) {
        self.store = store
    }
    
    @ViewBuilder
    public var socialSection: some View {
        HStack(spacing: 25) {
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
    public var emailSection: some View {
        VStack {
            PrimaryDivider()
            
            PrimaryButton(label: "Sign Up with Email") {
                send(.didTapSignUpWithEmail)
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    public var confirmSection: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 0))
            : AnyLayout(HStackLayout(spacing: 3))
        layout {
            Text("Have an Existing Account?")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Button {
                send(.didTapSignInWithEmail)
            } label: {
                Text("Log In")
                    .font(.subheadline.bold())
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
            }
        }
        .padding(.bottom, 30)
    }
    
    public var body: some View {
        Group {
            if let setup = store.scope(state: \.destination?.setUp, action: \.destination.setUp) {
                SetupScreen(store: setup)
                    .navigationBarBackButtonHidden()
            } else {
                accountNavigation
            }
        }
    }

    private var accountNavigation: some View {
        NavigationStack {
            ZStack {
                DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Dear Diary")
                            .primaryTextStyle()
                            .accessibilityAddTraits(.isHeader)
                        if store.error != nil {
                            Text("Sign-in is unavailable. Please try again later.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.bottom)
                        }
                        socialSection
                        emailSection
                        confirmSection
                    }
                    .primaryHorizontalPadding()
                    .padding(.top, 40)
                }
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
            .onAppear {
                send(.didAppear)
            }
        }
    }
}
