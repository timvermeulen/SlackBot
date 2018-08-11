extension EventService {
    enum Post {
        case challenge(String)
        case event(Event, teams: [TeamID])
    }
}

extension EventService.Post: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case challenge
        case event
        case teams = "authed_teams"
    }
    
    enum PostType: String, Decodable {
        case verification = "url_verification"
        case event = "event_callback"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PostType.self, forKey: .type)
        
        switch type {
        case .verification:
            let challenge = try container.decode(String.self, forKey: .challenge)
            self = .challenge(challenge)
            
        case .event:
            let event = try container.decode(Event.self, forKey: .event)
            let teams = try container.decode([TeamID].self, forKey: .teams)
            self = .event(event, teams: teams)
        }
    }
}
