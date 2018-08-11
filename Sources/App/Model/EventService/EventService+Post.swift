extension EventService {
    enum Post {
        case challenge(String)
        case event(Event)
    }
}

extension EventService.Post: Decodable {
    enum CodingKeys: CodingKey {
        case type
        case challenge
        case event
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
            self = .event(event)
        }
    }
}
