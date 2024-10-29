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
                Text(
                    "\(abbreviated()).\(Calendar.current.component(.day, from: date))"
                ).font(
                    DesignSystemFontFamily.Pretendard.regular
                        .swiftUIFont(size: 16)
                )
                VStack {
                    Divider()
                        .foregroundStyle(
                            colorScheme == .dark
                            ? .white
                            : DesignSystemAsset.ddSecondary.swiftUIColor
                        )
                }
            }
            Text(date.formatted(date: .omitted, time: .shortened))
                .font(
                    DesignSystemFontFamily.Pretendard.regular
                        .swiftUIFont(size: 13)
                )
                .foregroundStyle(DesignSystemAsset.ddPrimary.swiftUIColor)
        }
    }
}

func abbreviated() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter.string(from: Date.now)
}
