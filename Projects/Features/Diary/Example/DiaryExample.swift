import SwiftUI

import ComposableArchitecture

import Diary


@main
struct DiaryExampleApp: App {
    let exampleStore = StoreOf<Diary>(initialState: Diary.State()) {
        Diary()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DiaryView(store: exampleStore)
                    .onAppear {  exampleStore.send(.view(.didAppear)) }
            }
        }
    }
}
