extension Attachment {
    public struct Footer: Codable {
        let contents: MessageContents
        let icon: String?
        let timestamp: UnixTimestamp?
        
        public init(contents: MessageContents, icon: String? = nil, timestamp: UnixTimestamp? = nil) {
            self.contents = contents
            self.icon = icon
            self.timestamp = timestamp
        }
        
        enum CodingKeys: String, CodingKey {
            case contents = "footer"
            case icon = "footer_icon"
            case timestamp = "ts"
        }
    }
}

extension Attachment.Footer: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(contents: [value])
    }
}
