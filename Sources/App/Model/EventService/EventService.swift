import Vapor

final class EventService {
    private let verificationToken: String
    private let router: Router
    private var handlers: [(Message) throws -> Void]
    
    init(verificationToken: String, router: Router) {
        self.verificationToken = verificationToken
        self.router = router
        self.handlers = []
    }
    
    func start() throws {
        router.post("event") { [verificationToken] request -> Future<AnyResponse> in
            return try request.content.decode(Post.self).map { post in
                guard post.token == verificationToken else { throw Abort(.forbidden) }
                
                switch post.content {
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
