public struct ID<Model>: Newtype, Equatable, Codable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ID: CustomStringConvertible {
    public var description: String {
        return "\(Model.self)(\(rawValue))"
    }
}

public protocol Identifiable {
    var id: ID<Self> { get }
}
