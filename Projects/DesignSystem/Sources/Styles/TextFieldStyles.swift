import SwiftUI

public struct PrimaryTextFieldStyle: TextFieldStyle {
    public init() { }
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
            .padding(9)
            .background(DesignSystemAsset.ddFill.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(DesignSystemAsset.ddSolid.swiftUIColor)
            }
    }
}

public struct SecondaryTextFieldStyle: TextFieldStyle {
    public init() { }
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)

        Divider().foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
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
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .background(DesignSystemAsset.ddSecondaryBackground.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
