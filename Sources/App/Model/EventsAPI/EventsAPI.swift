import Vapor
import Crypto

final class EventsAPI {
    private let signingSecret: SigningSecret
    private let router: Router
    private var handlers: [(Request, Client, ID<Team>, Message) throws -> Void]
    
    init(signingSecret: SigningSecret, router: Router) {
        self.signingSecret = signingSecret
        self.router = router
        self.handlers = []
    }
}

extension EventsAPI {
    func start() throws {
        router.post("event") { [signingSecret] request -> Future<AnyResponse> in
            try request.verifySigningSecret(signingSecret)
            
            return try request.content.decode(Post.self).map { post in
                switch post {
                case .challenge(let challenge):
                    return AnyResponse(challenge)
                    
                case .event(let event, let teams):
                    switch event {
                    case .messageEvent(.default(let message)):
                        let client = try request.make(Client.self)
                        
                        for handler in self.handlers {
                            for team in teams {
                                try handler(request, client, team, message)
                            }
                        }
                        
                    default:
                        break
                    }
                    
                    return AnyResponse(HTTPStatus.ok)
                }
            }
        }
    }
    
    func handleMessage(_ handler: @escaping (Request, Client, ID<Team>, Message) throws -> Void) {
        handlers.append(handler)
    }
}
