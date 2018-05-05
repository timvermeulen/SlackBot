// see https://api.slack.com/events
enum EventType: String, Codable {
    case message
    case reactionAdded = "reaction_added"
}

protocol Event: Decodable {
    static var eventType: EventType { get }
    func toAnyEvent() -> AnyEvent
}

public enum AnyEvent {
    case messageEvent(AnyMessageEvent)
    case reactionAdded
}

extension AnyEvent: Decodable {
    enum CodingKeys: String, CodingKey {
        case eventType = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EventType.self, forKey: .eventType)
        
        switch type {
        case .message:
            let messageEvent = try AnyMessageEvent(from: decoder)
            self = .messageEvent(messageEvent)
            
        case .reactionAdded:
            self = .reactionAdded // TODO
        }
    }
}
