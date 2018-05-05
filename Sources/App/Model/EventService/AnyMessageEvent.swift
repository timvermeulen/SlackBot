public enum AnyMessageEvent {
    case `default`(Message)
    case edit(MessageEdit)
}

extension AnyMessageEvent: Decodable {
    enum CodingKeys: String, CodingKey {
        case messageEventType = "subtype"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(MessageEventType.self, forKey: .messageEventType)
        
        switch type {
        case nil:
            let message = try Message(from: decoder)
            self = .default(message)
            
        default:
            self = .edit(MessageEdit()) // TODO
        }
    }
}
