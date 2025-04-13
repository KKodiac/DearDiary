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
            DiaryView(store: exampleStore)
                .onAppear {  exampleStore.send(.didAppear) }
        }
    }
}
