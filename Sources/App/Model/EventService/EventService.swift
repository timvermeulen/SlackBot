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
    
    private func verifyToken(_ token: String) throws {
        if token != verificationToken { throw Abort(.forbidden) }
    }
    
    func start() throws {
        router.post("event") { request -> Future<AnyResponse> in
            let post = try request.content.decode(Post.self)
            
            return post.map(to: AnyResponse.self) { post in
                try self.verifyToken(post.token)
                
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
