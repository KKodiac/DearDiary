import SwiftUI

public struct PrimaryDivider: View {
    public init() { }

    public var body: some View {
        HStack {
            Rectangle()
                .fill(Color(uiColor: .separator))
                .frame(height: 1)
            Text("OR")
                .font(.caption)
                .foregroundStyle(DesignSystemAsset.ddAccent.swiftUIColor)
                .fixedSize()
            Rectangle()
                .fill(Color(uiColor: .separator))
                .frame(height: 1)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical)
        .accessibilityHidden(true)
    }
}
