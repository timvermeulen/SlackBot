import Newtype

public struct Team: Decodable {
    public let id: ID<Team>
    public let name: Name
    public let domain: Domain
}

public extension Team {
    struct Name: Newtype, Decodable, CustomStringConvertible {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    struct Domain: Newtype, Decodable, CustomStringConvertible {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
