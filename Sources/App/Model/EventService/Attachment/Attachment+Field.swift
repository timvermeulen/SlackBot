extension Attachment {
    public struct Field: Codable {
        let title: String
        let contents: MessageContents
        let isShort: Bool?
        
        public init(title: String, contents: MessageContents, isShort: Bool? = nil) {
            self.title = title
            self.contents = contents
            self.isShort = isShort
        }
        
        enum CodingKeys: String, CodingKey {
            case title
            case contents = "value"
            case isShort = "short"
        }
    }
}
