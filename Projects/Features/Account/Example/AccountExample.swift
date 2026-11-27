import SwiftUI

import ComposableArchitecture

import Account


@main
struct AccountExampleApp: App {
    let exampleStore = StoreOf<Account>(initialState: Account.State()) {
        Account()
    }
    var body: some Scene {
        WindowGroup {
            AccountView(store: exampleStore)
                .onAppear {  exampleStore.send(.view(.didAppear)) }
        }
    }
}
