extension Attachment {
    public struct Author: Codable {
        let name: MessageContents
        let link: URL?
        let iconURL: URL?
        
        public init(name: MessageContents, link: URL? = nil, iconURL: URL? = nil) {
            self.name = name
            self.link = link
            self.iconURL = iconURL
        }
        
        enum CodingKeys: String, CodingKey {
            case name = "author_name"
            case link = "author_link"
            case iconURL = "author_icon"
        }
    }
}

extension Attachment.Author: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(name: [value])
    }
}
