import Vapor
import Crypto

// TODO: move to a separate file
private extension Request {
    func verifySigningSecret(_ signingSecret: String) throws {
        guard let timestamp = http.headers["X-Slack-Request-Timestamp"].first,
              let signature = http.headers["X-Slack-Signature"].first
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
    private var handlers: [(Message) throws -> Void]
    
    init(signingSecret: String, router: Router) {
        self.signingSecret = signingSecret
        self.router = router
        self.handlers = []
    }
    
    func start() throws {
        router.post("event") { [signingSecret] request -> Future<AnyResponse> in
            try request.verifySigningSecret(signingSecret)
            
            return try request.content.decode(Post.self).map { post in
                switch post {
                case .challenge(let challenge):
                    return AnyResponse(challenge)
                    
                case .event(let event):
                    if case .messageEvent(.default(let message)) = event {
                        try self.handlers.forEach { try $0(message) }
                    }
                    
                    return AnyResponse(HTTPStatus.ok)
                }
            }
        }
        
        router.get("hello") { _ in
            return "Hello, world!"
        }
    }
    
    func handleMessage(_ handler: @escaping (Message) throws -> Void) {
        handlers.append(handler)
    }
}
