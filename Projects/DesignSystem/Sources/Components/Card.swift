import SwiftUI

public struct Card: View {
    let title: String
    let content: String
    let timestamp: Date
    
    public init(title: String, content: String, timestamp: Date) {
        self.title = title
        self.content = content
        self.timestamp = timestamp
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    titleText
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer(minLength: 0)
                    timeText
                }
                VStack(alignment: .leading, spacing: 4) {
                    titleText
                    timeText
                }
            }
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DesignSystemAsset.ddBackgroundFill.swiftUIColor,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .padding(.horizontal)
    }

    private var titleText: some View {
        Text(title)
            .font(.headline)
    }

    private var timeText: some View {
        Text(timestamp.formatted(date: .omitted, time: .shortened))
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
