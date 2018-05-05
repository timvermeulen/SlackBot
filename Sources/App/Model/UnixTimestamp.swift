import Foundation

public struct UnixTimestamp: Newtype, Codable, Equatable, Comparable, CustomStringConvertible {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension UnixTimestamp {
    public static var current: UnixTimestamp {
        return UnixTimestamp(rawValue: Int(Date().timeIntervalSince1970))
    }
}
