import SwiftUI

public struct PrimaryTextStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.title.bold())
    }
}

public extension View {
    func primaryTextStyle() -> some View {
        modifier(PrimaryTextStyle())
    }
}
