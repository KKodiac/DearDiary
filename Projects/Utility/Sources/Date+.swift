import Foundation

public extension Date {
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
}
