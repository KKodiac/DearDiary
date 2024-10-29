import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(DesignSystemAsset.ddAccent.swiftUIColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16.0))
            .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .background(DesignSystemAsset.ddAccent.swiftUIColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .font(.subheadline)
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct ComposeButtonStyle: ButtonStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 34)
            .padding(.vertical, 12)
            .background(DesignSystemAsset.ddAccent.swiftUIColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .font(.system(size: 12))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct PauseButtonStyle: ButtonStyle {
    private let colorScheme: ColorScheme?
    public init(colorScheme: ColorScheme? = nil) {
        self.colorScheme = colorScheme
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 34)
            .padding(.vertical, 12)
            .background(DesignSystemAsset.ddTernaryBackground.swiftUIColor)
            .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .font(.system(size: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        colorScheme == .dark
                        ? DesignSystemAsset.ddSecondary.swiftUIColor
                        : DesignSystemAsset.ddAccent.swiftUIColor
                    )
            }
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct ToolbarPrimaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(DesignSystemAsset.ddAccent.swiftUIColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .font(
                DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 12)
            )
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}
