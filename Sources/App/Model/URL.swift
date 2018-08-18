import Newtype

public struct URL: Newtype, Codable, CustomStringConvertible, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
