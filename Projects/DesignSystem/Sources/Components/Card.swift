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
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(content)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(3)
        }
        .multilineTextAlignment(.leading)
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(
            DesignSystemAsset.ddBackgroundFill.swiftUIColor,
            in: RoundedRectangle(cornerRadius: 20)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .padding([.horizontal, .top])
    }
}
