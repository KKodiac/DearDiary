import SwiftUI

public struct PrimaryTextStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 26))
    }
}

public extension View {
    func primaryTextStyle() -> some View {
        modifier(PrimaryTextStyle())
    }
}
