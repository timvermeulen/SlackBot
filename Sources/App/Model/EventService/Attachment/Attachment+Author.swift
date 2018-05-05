extension Attachment {
    public struct Author: Codable {
        let name: MessageContents
        let link: String?
        let icon: String?
        
        public init(name: MessageContents, link: String? = nil, icon: String? = nil) {
            self.name = name
            self.link = link
            self.icon = icon
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "author_name"
            case link = "author_link"
            case icon = "author_icon"
        }
    }
}

extension Attachment.Author: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: [value])
    }
}
