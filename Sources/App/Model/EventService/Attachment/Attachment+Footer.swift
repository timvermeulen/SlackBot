extension Attachment {
    public struct Footer: Codable {
        let contents: MessageContents
        let iconURL: String?
        let timestamp: UnixTimestamp?
        
        public init(
            contents: MessageContents,
            iconURL: String? = nil,
            timestamp: UnixTimestamp? = nil
        ) {
            self.contents = contents
            self.iconURL = iconURL
            self.timestamp = timestamp
        }
        
        enum CodingKeys: String, CodingKey {
            case contents = "footer"
            case iconURL = "footer_icon"
            case timestamp = "ts"
        }
    }
}

extension Attachment.Footer: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(contents: [value])
    }
}
