import SwiftUI

public struct PrimaryButton: View {
    let label: LocalizedStringKey
    let action: () -> Void
    
    public init(label: LocalizedStringKey, action: @escaping () -> Void) {
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

