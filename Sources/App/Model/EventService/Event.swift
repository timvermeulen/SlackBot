// see https://api.slack.com/events
enum EventType: String, Codable {
    case message
    case reactionAdded = "reaction_added"
}

public enum Event {
    case messageEvent(MessageEvent)
    case reactionAdded
}

extension Event: Decodable {
    enum CodingKeys: String, CodingKey {
        case eventType = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EventType.self, forKey: .eventType)
        
        switch type {
        case .message:
            let messageEvent = try MessageEvent(from: decoder)
            self = .messageEvent(messageEvent)
            
        case .reactionAdded:
            self = .reactionAdded // TODO
        }
    }
}
