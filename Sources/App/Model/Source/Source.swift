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
        let id = try String(from: decoder)
        
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
        switch self {
        case .channel(let id):
            try id.encode(to: encoder)
        case .im(let id):
            try id.encode(to: encoder)
        case .group(let id):
            try id.encode(to: encoder)
        }
    }
}

// TODO: consider if these are really needed
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
            return "\(id)"
        case .im(let id):
            return "\(id)"
        case .group(let id):
            return "\(id)"
        }
    }
}
