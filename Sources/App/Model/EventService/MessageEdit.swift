public struct MessageEdit: Codable {
    // TODO
}

extension MessageEdit: MessageEvent {
    static var messageEventType: MessageEventType? {
        return .messageChanged
    }
    
    func toAnyMessageEvent() -> AnyMessageEvent {
        return .edit(self)
    }
}
