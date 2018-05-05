public protocol Newtype {
    associatedtype RawValue
    
    var rawValue: RawValue { get }
    init(rawValue: RawValue)
}

extension Newtype where Self: CustomStringConvertible {
    public var description: String {
        return String(describing: rawValue)
    }
}

extension Newtype where Self: Encodable, RawValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension Newtype where Self: Decodable, RawValue: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(rawValue: try RawValue(from: decoder))
    }
}

extension Newtype where Self: Equatable, RawValue: Equatable {
    public static func == (left: Self, right: Self) -> Bool {
        return left.rawValue == right.rawValue
    }
}

extension Newtype where Self: Hashable, RawValue: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension Newtype where Self: Comparable, RawValue: Comparable {
    public static func < (left: Self, right: Self) -> Bool {
        return left.rawValue < right.rawValue
    }
}

extension Newtype where Self: ExpressibleByStringLiteral, RawValue: ExpressibleByStringLiteral {
    public init(stringLiteral: RawValue.StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: stringLiteral))
    }
}

extension Newtype where Self: ExpressibleByIntegerLiteral, RawValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral: RawValue.IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: integerLiteral))
    }
}

extension Newtype where Self: ExpressibleByFloatLiteral, RawValue: ExpressibleByFloatLiteral {
    public init(floatLiteral: RawValue.FloatLiteralType) {
        self.init(rawValue: RawValue(floatLiteral: floatLiteral))
    }
}
