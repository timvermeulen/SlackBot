// TODO: make this a struct with static members instead
public protocol EmojiRepresentable: MessageSegmentRepresentable {
    var name: String { get }
}

extension EmojiRepresentable {
    public var emoji: String {
        return ":\(name):"
    }
    
    public var messageSegment: MessageSegment {
        return emoji.messageSegment
    }
}

extension Emoji: EmojiRepresentable {
    public var name: String {
        return rawValue
    }
}

extension CustomEmoji: EmojiRepresentable {}
