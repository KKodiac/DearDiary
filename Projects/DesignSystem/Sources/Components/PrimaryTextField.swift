import SwiftUI

public struct PrimaryTextField: View {
    public let header: LocalizedStringKey
    @Binding public var text: String
    @Binding public var status: TextFieldStatus
    
    public init(_ header: LocalizedStringKey, text: Binding<String>, status: Binding<TextFieldStatus> = .constant(.default)) {
        self.header = header
        self._text = text
        self._status = status
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(header).accentTextStyle()
            TextField("", text: $text)
        }
    }
}

public enum TextFieldStatus {
    case `default`
    case error(message: String)
}
