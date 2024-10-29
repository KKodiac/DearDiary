import ComposableArchitecture
import SwiftUI

public struct SettingView: View {
    @Bindable var store: StoreOf<Setting>
    
    public init(store: StoreOf<Setting>) {
        self.store = store
    }
    
    public var body: some View {
        EmptyView()
    }
}
