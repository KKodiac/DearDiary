import SwiftUI

public struct PrimaryTextStyle: ViewModifier {
    @ScaledMetric(relativeTo: .title) private var fontSize: CGFloat = 26

    public func body(content: Content) -> some View {
        content
            .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: fontSize))
    }
}

public extension View {
    func primaryTextStyle() -> some View {
        modifier(PrimaryTextStyle())
    }
}
