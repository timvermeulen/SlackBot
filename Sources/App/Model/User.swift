public struct User: Decodable {
    public let id: ID<User>
    public let username: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username = "name"
    }
}
