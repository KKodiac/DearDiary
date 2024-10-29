import SwiftUI

public struct PrimarySecureField: View {
    public let header: String
    @Binding public var text: String
    @Binding public var status: TextFieldStatus
    
    public init(_ header: String, text: Binding<String>, status: Binding<TextFieldStatus> = .constant(.default)) {
        self.header = header
        self._text = text
        self._status = status
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(header).accentTextStyle()
            SecureField("", text: $text)
        }
    }
}
