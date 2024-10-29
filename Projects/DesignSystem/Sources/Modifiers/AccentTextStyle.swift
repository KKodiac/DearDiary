import SwiftUI

public struct AccentTextStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 14))
            .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
    }
}

public extension View {
    func accentTextStyle() -> some View {
        modifier(AccentTextStyle())
    }
}

