import Newtype

public struct Timestamp {
    public let unix: UnixTimestamp
    public let identifier: Identifier
    private let comparableIdentifier: ComparableIdentifier // used for comparison
}

extension Timestamp {
    public struct Identifier: Newtype, CustomStringConvertible {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public struct ComparableIdentifier: Newtype, Comparable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    enum Error: Swift.Error {
        case invalidTimestamp(String)
    }
    
    init(_ value: String) throws {
        let components = value.split(separator: ".", maxSplits: 1)
        
        guard components.count == 2,
              let timestamp = Int(components[0]),
              let comparableIdentifier = Int(components[1])
        else { throw Error.invalidTimestamp(value) }
        
        self.init(
            unix: UnixTimestamp(rawValue: timestamp),
            identifier: .init(rawValue: String(components[1])),
            comparableIdentifier: .init(rawValue: comparableIdentifier)
        )
    }
}

extension Timestamp: Comparable {
    public static func == (lhs: Timestamp, rhs: Timestamp) -> Bool {
        return lhs.unix == rhs.unix
    }
    
    public static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        return (lhs.unix, lhs.comparableIdentifier) < (rhs.unix, rhs.comparableIdentifier)
    }
}

extension Timestamp: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try "\(self)".encode(to: encoder)
    }
}

extension Timestamp: CustomStringConvertible {
    public var description: String {
        return "\(unix).\(identifier)"
    }
}
