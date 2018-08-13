import Vapor

struct EphemeralMessage {
    let contents: MessageContents
    let attachments: [Attachment]?
    let target: Target
}

extension EphemeralMessage: Encodable {
    enum CodingKeys: String, CodingKey {
        case text
        case attachments
        case channel
        case user
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(contents,      forKey: .text)
        try container.encode(target.source, forKey: .channel)
        try container.encode(target.user,   forKey: .user)
        try container.encodeIfPresent(attachments, forKey: .attachments)
    }
}
