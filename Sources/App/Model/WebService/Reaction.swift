import Vapor

struct Reaction {
    let target: Target
    let emoji: EmojiRepresentable
}

extension Reaction: Encodable {
    enum CodingKeys: CodingKey {
        case name
        case channel
        case timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(emoji.name,       forKey: .name)
        try container.encode(target.source,    forKey: .channel)
        try container.encode(target.timestamp, forKey: .timestamp)
    }
}

extension Reaction: WebServiceSendable {
    static let endpoint = "reactions.add"
}
