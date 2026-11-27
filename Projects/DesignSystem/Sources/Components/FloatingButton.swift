import SwiftUI

public struct FloatingButton: View {
    let image: DesignSystemImages
    let action: () -> Void
    
    public init(image: DesignSystemImages, action: @escaping () -> Void) {
        self.image = image
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Image(asset: image)
                .padding(15)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Circle())
        }
        .background(DesignSystemAsset.ddAccentFill.swiftUIColor)
        .clipShape(Circle())
    }
}
