import Core
import Newtype

// TODO: constrain `Model` in some way?
public struct ID<Model>: Newtype, Equatable, Hashable, Codable {
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

extension ID: ReflectionDecodable {
    public static func reflectDecoded() throws -> (ID<Model>, ID<Model>) {
        let (a, b) = String.reflectDecoded()
        return (.init(rawValue: a), .init(rawValue: b))
    }
}

public protocol Identifiable {
    var id: ID<Self> { get }
}
