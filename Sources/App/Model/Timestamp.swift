public struct Timestamp {
    public let unix: UnixTimestamp
    public let identifier: String
    private let identifierValue: Int // used for comparison
}

extension Timestamp {
    enum Error: Swift.Error {
        case invalidTimestamp(String)
    }
    
    init(_ value: String) throws {
        let components = value.split(separator: ".", maxSplits: 1)
        
        guard
            components.count == 2,
            let timestamp = Int(components[0]),
            let identifierValue = Int(components[1])
            else { throw Error.invalidTimestamp(value) }
        
        self.init(
            unix: UnixTimestamp(rawValue: timestamp),
            identifier: String(components[1]),
            identifierValue: identifierValue
        )
    }
}

extension Timestamp: Comparable {
    public static func == (left: Timestamp, right: Timestamp) -> Bool {
        return left.unix == right.unix
    }
    
    public static func < (left: Timestamp, right: Timestamp) -> Bool {
        return (left.unix, left.identifierValue) < (right.unix, right.identifierValue)
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
