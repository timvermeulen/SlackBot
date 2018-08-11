// see https://api.slack.com/events/message
enum MessageEventType: String, Codable {
    case meMessage = "me_message"
    case messageChanged = "message_changed"
    case messageDeleted = "message_deleted"
}

public enum MessageEvent {
    case `default`(Message)
    case edit(MessageEdit)
}

extension MessageEvent: Decodable {
    enum CodingKeys: String, CodingKey {
        case subtype
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(MessageEventType.self, forKey: .subtype)
        
        switch type {
        case nil:
            let message = try Message(from: decoder)
            self = .default(message)
            
        // TODO
        case .meMessage?, .messageChanged?, .messageDeleted?:
            self = .edit(MessageEdit())
        }
    }
}
