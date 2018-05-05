// see https://api.slack.com/events/message
enum MessageEventType: String, Codable {
    case meMessage = "me_message"
    case messageChanged = "message_changed"
    case messageDeleted = "message_deleted"
}

protocol MessageEvent: Event {
    static var messageEventType: MessageEventType? { get }
    func toAnyMessageEvent() -> AnyMessageEvent
}

extension MessageEvent {
    static var eventType: EventType {
        return .message
    }
    
    func toAnyEvent() -> AnyEvent {
        return .messageEvent(toAnyMessageEvent())
    }
}
