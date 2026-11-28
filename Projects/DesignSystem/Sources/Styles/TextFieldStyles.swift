import SwiftUI

public struct PrimaryTextFieldStyle: TextFieldStyle {
    public init() { }
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
            .padding(9)
            .frame(minHeight: 44)
            .background(DesignSystemAsset.ddFill.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(DesignSystemAsset.ddPrimary.swiftUIColor)
            }
    }
}

public struct SecondaryTextFieldStyle: TextFieldStyle {
    public init() { }
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
            .frame(minHeight: 44)

        Rectangle()
            .fill(DesignSystemAsset.ddAccent.swiftUIColor)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

public struct ChatTextFieldStyle: TextFieldStyle {
    private let colorScheme: ColorScheme?

    public init(colorScheme: ColorScheme? = nil) {
        self.colorScheme = colorScheme
    }
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .font(.subheadline)
            .padding(10)
            .frame(minHeight: 44)
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            .background(DesignSystemAsset.ddSecondaryBackground.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
