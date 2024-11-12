import ComposableArchitecture
import DesignSystem
import Account
import Diary
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<DearDiary>
    
    init(store: StoreOf<DearDiary> = .init(initialState: { DearDiary.State() }(), reducer: {
        DearDiary()
    })) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystemAsset.ddPrimaryBackground.swiftUIColor
                    .ignoresSafeArea()
                Text("Dear Diary").primaryTextStyle().offset(y: -50)
                if let store = store.scope(state: \.destination?.auth, action: \.destination.auth) {
                    AccountView(store: store)
                }
            }
            .onAppear {
                store.send(.didAppear)
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.diary,
                    action: \.destination.diary
                )
            ) { store in
                DiaryView(store: store)
            }
        }
    }
}
