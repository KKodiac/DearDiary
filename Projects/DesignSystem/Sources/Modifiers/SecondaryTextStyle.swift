import SwiftUI

public struct SecondaryTextStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(
                DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18)
            )
    }
}

public extension View {
    func secondaryTextStyle() -> some View {
        modifier(SecondaryTextStyle())
    }
}
