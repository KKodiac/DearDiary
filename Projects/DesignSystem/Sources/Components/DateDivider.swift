import SwiftUI

public struct DateDivider: View {
    private let colorScheme: ColorScheme?
    private let date: Date
    public init(colorScheme: ColorScheme? = nil, date: Date) {
        self.colorScheme = colorScheme
        self.date = date
    }
    public var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(spacing: 16) {
                Text(date, format: .dateTime.month(.abbreviated).day())
                    .font(.body)
                VStack {
                    Divider()
                        .foregroundStyle(
                            colorScheme == .dark
                            ? .white
                            : DesignSystemAsset.ddSecondary.swiftUIColor
                        )
                }
            }
            Text(date, format: .dateTime.hour().minute())
                .font(.footnote)
                .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
        }
    }
}
