import SwiftUI

public struct PrimaryMenuStyle: MenuStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.secondary)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(DesignSystemAsset.ddSolid.swiftUIColor)
            }
    }
}
