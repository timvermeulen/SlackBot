/// Instances of types that implement `MessageSegmentRepresentable`
/// can be converted to `MessageSegment`s, which in turn can be used
/// in chat messages.
public protocol MessageSegmentRepresentable {
    var messageSegment: MessageSegment { get }
}

extension MessageSegment: MessageSegmentRepresentable {
    public var messageSegment: MessageSegment {
        return self
    }
}

extension String: MessageSegmentRepresentable {
    public var messageSegment: MessageSegment {
        return .raw(self)
    }
}

extension Substring: MessageSegmentRepresentable {
    public var messageSegment: MessageSegment {
        return String(self).messageSegment
    }
}

extension Int: MessageSegmentRepresentable {
    public var messageSegment: MessageSegment {
        return String(self).messageSegment
    }
}

extension MessageSegmentRepresentable where Self: EmojiRepresentable {
    public var messageSegment: MessageSegment {
        return emoji.messageSegment
    }
}

extension Command: MessageSegmentRepresentable {
    public var messageSegment: MessageSegment {
        return .command(self)
    }
}
