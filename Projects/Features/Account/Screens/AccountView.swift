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
                let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let viewController = firstScene?.windows.first?.rootViewController
                send(.didTapSignInWithGoogle(viewController))
            }
            
            CircularButton(image: DesignSystemAsset.apple) {
                send(.didTapSignInWithApple(controller))
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
        NavigationStack {
            ZStack {
                DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea()
                Text("Dear Diary").primaryTextStyle().offset(y: -50)
                VStack {
                    Spacer()
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
                    state: \.destination?.signIn,
                    action: \.destination.signIn
                )
            ) { store in
                AuthenticationScreen(store: store)
                    .navigationBarBackButtonHidden()
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.signUp,
                    action: \.destination.signUp
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
