import Vapor

struct ResponseMessage {
    let style: ResponseStyle
    let contents: MessageContents
    let attachments: [Attachment]?
    let target: Target
}

public enum ResponseStyle {
    case inline
    case threaded
}

extension ResponseMessage: Encodable {
    enum CodingKeys: String, CodingKey {
        case text
        case channel
        case threadTimestamp = "thread_ts"
        case attachments
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(contents,      forKey: .text)
        try container.encode(target.source, forKey: .channel)
        try container.encodeIfPresent(attachments, forKey: .attachments)
        
        if case .threaded = style {
            try container.encode(target.timestamp, forKey: .threadTimestamp)
        }
    }
}
