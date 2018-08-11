import Vapor
import Crypto

private extension HTTPHeaderName {
    static let slackTimestamp = HTTPHeaderName("X-Slack-Request-Timestamp")
    static let slackSignature = HTTPHeaderName("X-Slack-Signature")
}

// TODO: move to a separate file
private extension Request {
    func verifySigningSecret(_ signingSecret: String) throws {
        guard let timestamp = http.headers.firstValue(name: .slackTimestamp),
              let signature = http.headers.firstValue(name: .slackSignature)
        else { throw Abort(.forbidden) }
        
        // TODO: Slack recommends verifying that the timestamp is recent (e.g. within the last 5
        // minutes) in order to prevent a replay attack
        
        let digest = try HMAC.SHA256.authenticate(
            "v0:\(timestamp):\(http.body)",
            key: signingSecret
        )
        
        if "v0=\(digest.hexEncodedString())" != signature {
            throw Abort(.forbidden)
        }
    }
}

final class EventService {
    private let signingSecret: String
    private let router: Router
    private var handlers: [(Client, _ teamID: String, Message) throws -> Void]
    
    init(signingSecret: String, router: Router) {
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
    
    func handleMessage(_ handler: @escaping (Client, _ team: String, Message) throws -> Void) {
        handlers.append(handler)
    }
}
