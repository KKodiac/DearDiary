import SwiftUI

public struct PrimaryHorizontalPadding: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 33)
    }
}

public struct FormVerticalPadding: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.vertical, 94)
    }
}

public extension View {
    func primaryHorizontalPadding() -> some View {
        modifier(PrimaryHorizontalPadding())
    }
    
    func formVerticalPadding() -> some View {
        modifier(PrimaryHorizontalPadding())
    }
}
