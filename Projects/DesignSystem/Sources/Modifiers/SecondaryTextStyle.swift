import SwiftUI

public struct SecondaryTextStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.headline)
    }
}

public extension View {
    func secondaryTextStyle() -> some View {
        modifier(SecondaryTextStyle())
    }
}
