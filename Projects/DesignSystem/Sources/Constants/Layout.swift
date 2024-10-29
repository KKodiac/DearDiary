import Foundation

public enum Layout {
    public enum Spacing {
        public static let tiny: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 15
        public static let large: CGFloat = 20
        public static let extraLarge: CGFloat = 30
        public static let form: CGFloat = 30
    }
    
    public enum Padding {
        public static let form: CGFloat = 9
        public static let horizontal: CGFloat = 33
        public static let vertical: CGFloat = 94
        public static let top: CGFloat = 20
        public static let bottom: CGFloat = 30
        public static let titleBottom: CGFloat = 70
    }
    
    public enum Offset {
        public static let title: CGFloat = -20
        public static let content: CGFloat = -50
    }
    
    public enum CornerRadius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 10
        public static let large: CGFloat = 20
    }
} 