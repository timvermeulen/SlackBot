import Foundation
import Newtype

public struct UnixTimestamp: Newtype, Codable, Equatable, Comparable, CustomStringConvertible {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public extension UnixTimestamp {
    init(date: Date) {
        self.init(rawValue: Int(date.timeIntervalSince1970))
    }
    
    static var current: UnixTimestamp {
        return UnixTimestamp(date: Date())
    }
}
