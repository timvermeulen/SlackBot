import Vapor
import Crypto

final class EventService {
    private let signingSecret: SigningSecret
    private let router: Router
    private var handlers: [(Client, TeamID, Message) throws -> Void]
    
    init(signingSecret: SigningSecret, router: Router) {
        self.signingSecret = signingSecret
        self.router = router
        self.handlers = []
    }
    
    func start() throws {
        router.post("event") { [signingSecret] request -> Future<AnyResponse> in
            try request.verifySigningSecret(signingSecret)
            let client = try request.make(Client.self)
            
            return try request.content.decode(Post.self).map { post in
                switch post {
                case .challenge(let challenge):
                    return AnyResponse(challenge)
                    
                case .event(let event, let teams):
                    if case .messageEvent(.default(let message)) = event {
                        for handler in self.handlers {
                            for team in teams {
                                try handler(client, team, message)
                            }
                        }
                    }
                    
                    return AnyResponse(HTTPStatus.ok)
                }
            }
        }
    }
    
    func handleMessage(_ handler: @escaping (Client, TeamID, Message) throws -> Void) {
        handlers.append(handler)
    }
}
