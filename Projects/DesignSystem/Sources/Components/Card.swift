import SwiftUI

public struct Card: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let content: String
    let timestamp: Date
    
    public init(title: String, content: String, timestamp: Date) {
        self.title = title
        self.content = content
        self.timestamp = timestamp
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(DesignSystemAsset.ddBackgroundFill.swiftUIColor)
            .overlay {
                VStack {
                    HStack {
                        Text(title).font(.body).bold()
                            .foregroundStyle(
                                colorScheme == .dark ? .white : .black
                            )
                        Spacer()
                        Text(timestamp.formatted(date: .omitted, time: .shortened))

                    }
                    Text(content)
                        .multilineTextAlignment(.leading)
                }
                .padding(25)
                .font(.caption)
                .fontWeight(.light)
                .foregroundStyle(
                    colorScheme == .dark ? .white : .gray
                )
            }
            .frame(height: 110)
            .padding([.horizontal, .top])
    }
}
