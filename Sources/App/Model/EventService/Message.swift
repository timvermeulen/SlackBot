public struct Message {
    public let text: String
    public let timestamp: Timestamp
    
    public let user: ID<User>
    public let source: Source
    public let threadTimestamp: Timestamp?
    
    public let contents: MessageContents
}

public extension Message {
    var isThreaded: Bool {
        return threadTimestamp != nil
    }
}

extension Message: Decodable {
    enum CodingKeys: String, CodingKey {
        case text
        case timestamp = "event_ts"
        case threadTimestamp = "thread_ts"
        case user
        case channel
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
        timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
        user = try container.decode(ID.self, forKey: .user)
        source = try container.decode(Source.self, forKey: .channel)
        threadTimestamp = try container.decodeIfPresent(Timestamp.self, forKey: .threadTimestamp)
        
        contents = try container.decode(MessageContents.self, forKey: .text)
    }
}

extension Message: MessageEvent {
    static var messageEventType: MessageEventType? {
        return nil
    }
    
    func toAnyMessageEvent() -> AnyMessageEvent {
        return .default(self)
    }
}
