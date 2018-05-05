extension EventService {
    struct Post {
        let token: String
        let content: Content
    }
}

extension EventService.Post {
    enum PostType: String, Decodable {
        case verification = "url_verification"
        case event = "event_callback"
    }
    
    enum Content {
        case challenge(String)
        case event(AnyEvent)
    }
}

extension EventService.Post: Decodable {
    enum CodingKeys: CodingKey {
        case type
        case challenge
        case token
        case event
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PostType.self, forKey: .type)
        
        token = try container.decode(String.self, forKey: .token)
        
        switch type {
        case .verification:
            let challenge = try container.decode(String.self, forKey: .challenge)
            content = .challenge(challenge)
            
        case .event:
            let event = try container.decode(AnyEvent.self, forKey: .event)
            content = .event(event)
        }
    }
}
