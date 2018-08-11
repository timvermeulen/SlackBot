public struct CustomEmoji {
    public let name: String
    public let imageURL: URL
    
    public init(name: String, imageURL: URL) {
        self.name = name
        self.imageURL = imageURL
    }
}
