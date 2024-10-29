import SwiftUI

public struct PrimaryDivider: View {
    public init() { }
    public var body: some View {
        Divider()
            .overlay {
                Text("OR")
                    .font(.caption)
                    .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
                    .padding(.horizontal)
                    .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
            }
            .padding(.vertical)
    }
}
