extension Attachment {
    public struct Title: Codable {
        let contents: MessageContents
        let link: URL?
        
        public init(contents: MessageContents, link: URL? = nil) {
            self.contents = contents
            self.link = link
        }
        
        enum CodingKeys: String, CodingKey {
            case contents = "title"
            case link = "title_link"
        }
    }
}

extension Attachment.Title: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(contents: [value])
    }
}
