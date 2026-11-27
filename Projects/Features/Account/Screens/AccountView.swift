import ComposableArchitecture
import DesignSystem
import SwiftUI

@ViewAction(for: Account.self)
public struct AccountView: View {
    @Bindable public var store: StoreOf<Account>
    @Environment(\.authorizationController) private var controller
    
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
            .padding(.vertical)
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
                    .font(
                        DesignSystemFontFamily.Pretendard.bold
                            .swiftUIFont(size: 16)
                    )
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
                Text("Dear Diary").primaryTextStyle().offset(y: -50)
                VStack {
                    Spacer()
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
