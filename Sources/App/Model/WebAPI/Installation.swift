import Vapor
import Fluent
import FluentSQLite

struct Installation: Codable {
    let app: ID<User>
    let team: ID<Team>
    let accessToken: OAuth.AccessToken
    
    enum CodingKeys: String, CodingKey {
        case app = "app_user_id"
        case team = "team_id"
        case accessToken = "access_token"
    }
}

extension Installation: Reflectable {}

struct SQLiteModelWrapper<Model: Codable> {
    let model: Model
    var id: Int?
    
    init(_ model: Model) {
        self.model = model
    }
}

extension SQLiteModelWrapper: SQLiteModel {
    enum CodingKeys: CodingKey {
        case id
    }
    
    init(from decoder: Decoder) throws {
        model = try .init(from: decoder)
        id = try decoder.container(keyedBy: CodingKeys.self).decodeIfPresent(Int.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        try model.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
    }
}

extension SQLiteModelWrapper: Migration {}
