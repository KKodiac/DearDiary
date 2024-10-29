import SwiftUI

public struct PrimaryButton: View {
    let label: String
    let action: () -> Void
    
    public init(label: String, action: @escaping () -> Void) {
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(label)
                Spacer()
            }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

