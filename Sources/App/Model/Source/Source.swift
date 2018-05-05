public enum Source {
    case channel(ID<Channel>)
    case im(ID<IM>)
    case group(ID<Group>)
}

extension Source: Codable {
    enum Error: Swift.Error {
        case emptyID
        case invalidID(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        
        guard let character = id.first else { throw Error.emptyID }
        
        switch character {
        case "C":
            self = .channel(ID(rawValue: id))
        case "D":
            self = .im(ID(rawValue: id))
        case "G":
            self = .group(ID(rawValue: id))
        default:
            throw Error.invalidID(id)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .channel(let id):
            try container.encode(id)
        case .im(let id):
            try container.encode(id)
        case .group(let id):
            try container.encode(id)
        }
    }
}

extension Source {
    public var channel: ID<Channel>? {
        guard case .channel(let id) = self else { return nil }
        return id
    }
    
    public var im: ID<IM>? {
        guard case .im(let id) = self else { return nil }
        return id
    }
    
    public var group: ID<Group>? {
        guard case .group(let id) = self else { return nil }
        return id
    }
    
    public var isChannel: Bool {
        return channel != nil
    }
    
    public var isIM: Bool {
        return im != nil
    }
    
    public var isGroup: Bool {
        return group != nil
    }
}

extension Source: CustomStringConvertible {
    public var description: String {
        switch self {
        case .channel(let id):
            return String(describing: id)
        case .im(let id):
            return String(describing: id)
        case .group(let id):
            return String(describing: id)
        }
    }
}
