public protocol MessageSegmentRepresentableByID {
    static func messageSegment(for id: ID<Self>) -> MessageSegment
}

extension ID: MessageSegmentRepresentable where Model: MessageSegmentRepresentableByID {
    public var messageSegment: MessageSegment {
        return Model.messageSegment(for: self)
    }
}

extension MessageSegmentRepresentableByID where Self: MessageSegmentRepresentable & Identifiable {
    var messageSegment: MessageSegment {
        return Self.messageSegment(for: id)
    }
}

extension User: MessageSegmentRepresentableByID {
    public static func messageSegment(for id: ID<User>) -> MessageSegment {
        return .user(id)
    }
}

extension Channel: MessageSegmentRepresentableByID {
    public static func messageSegment(for id: ID<Channel>) -> MessageSegment {
        return .channel(id)
    }
}
