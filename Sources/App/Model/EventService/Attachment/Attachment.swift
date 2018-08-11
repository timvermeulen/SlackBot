public struct Attachment {
    let contents: MessageContents?
    let pretext: MessageContents?
    let fallback: String?
    let color: Color?
    
    let imageURL: URL?
    let thumbnailURL: URL?
    
    let title: Title?
    let author: Author?
    let footer: Footer?
    
    let fields: [Field]?
    
    public init(
        contents: MessageContents? = nil,
        pretext: MessageContents? = nil,
        fallback: String? = nil,
        color: Color? = nil,
        imageURL: URL? = nil,
        thumbnailURL: URL? = nil,
        fields: [Field]? = nil,
        title: Title? = nil,
        author: Author? = nil,
        footer: Footer? = nil
    ) {
        self.contents = contents
        self.pretext = pretext
        self.fallback = fallback
        self.color = color
        
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        
        self.fields = fields
        
        self.title = title
        self.author = author
        self.footer = footer
    }
}

extension Attachment: Encodable {
    enum CodingKeys: String, CodingKey {
        case text
        case pretext
        case fallback
        case color
        case imageURL = "image_url"
        case thumbnailURL = "thumb_url"
        case fields
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(contents,     forKey: .text)
        try container.encodeIfPresent(pretext,      forKey: .pretext)
        try container.encodeIfPresent(fallback,     forKey: .fallback)
        try container.encodeIfPresent(color,        forKey: .color)
        
        try container.encodeIfPresent(imageURL,     forKey: .imageURL)
        try container.encodeIfPresent(thumbnailURL, forKey: .thumbnailURL)
        
        try container.encodeIfPresent(fields,       forKey: .fields)
        
        try title?.encode(to: encoder)
        try author?.encode(to: encoder)
        try footer?.encode(to: encoder)
    }
}

extension Attachment: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.init(
            contents:     try container.decodeIfPresent(MessageContents.self, forKey: .text),
            pretext:      try container.decodeIfPresent(MessageContents.self, forKey: .pretext),
            fallback:     try container.decodeIfPresent(String.self,          forKey: .fallback),
            color:        try container.decodeIfPresent(Color.self,           forKey: .color),
            imageURL:     try container.decodeIfPresent(URL.self,             forKey: .imageURL),
            thumbnailURL: try container.decodeIfPresent(URL.self,             forKey: .thumbnailURL),
            fields:       try container.decodeIfPresent([Field].self,         forKey: .fields),
            title:        try Title(from: decoder),
            author:       try Author(from: decoder),
            footer:       try Footer(from: decoder)
        )
    }
}
