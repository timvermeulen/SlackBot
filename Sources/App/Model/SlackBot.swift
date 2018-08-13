import Vapor

public final class SlackBot {
    private let app: Application
    private let router: Router
    private let oauth: OAuth
    
    private let eventsAPI: EventsAPI
    private let slashCommandService: SlashCommandService
    
    // TODO: add persistence for this
    private var installations: [ID<Team>: Installation] = [:]
    
    public init(oauth: OAuth, signingSecret: SigningSecret) throws {
        let router = EngineRouter.default()
        
        var middlewares = MiddlewareConfig()
        middlewares.use(ErrorMiddleware.self)
        
        var services = Services.default()
        services.register(router, as: Router.self)
        services.register(middlewares)
        
        app = try Application(
            environment: .detect(),
            services: services
        )
        
        self.router = router
        self.oauth = oauth
        self.eventsAPI = EventsAPI(signingSecret: signingSecret, router: router)
        self.slashCommandService = SlashCommandService(router: router)
    }
}

public extension SlackBot {
    func start() throws {
        router.get("hello") { _ in
            "Hello, world!"
        }
        
        setUpOAuth()
        try eventsAPI.start()
        try app.run()
    }
    
    func handleMessage(_ handler: @escaping (AuthorizedBot, Message) throws -> Void) {
        eventsAPI.handleMessage { request, teamID, message in
            guard let installation = self.installations[teamID],
                  installation.app != message.user
            else { return }
            
            let installedBot = try AuthorizedBot(
                installation: installation,
                request: request
            )
            
            try handler(installedBot, message)
        }
    }
    
    func addSlashCommand(
        at path: PathComponentsRepresentable...,
        makeResponse: @escaping (Request, Client) throws -> Future<SlashCommandResponse>
    ) {
        slashCommandService.addSlashCommand(at: path) { request in
            try makeResponse(request, request.make(Client.self))
        }
    }
}

private extension SlackBot {
    func setUpOAuth() {
        let state = UUID().uuidString
        
        router.get("oauth") { [oauth] request -> Future<HTTPResponseStatus> in
            let code = try request.query.get(String.self, at: "code")
            let responseState = try request.query.get(String.self, at: "state")
            
            guard responseState == state else { throw Abort(.badRequest) }
            
            return try request.make(Client.self).get("""
                https://slack.com/api/oauth.access?\
                code=\(code)&\
                redirect_uri=http://\(try request.requireHost())/oauth
                """,
                headers: oauth.headers
            )
                .flatMap { try $0.content.decode(Installation.self) }
                .do { self.installations[$0.team] = $0 }
                .map { _ in .ok }
        }
        
        router.get("install") { [oauth] request -> Response in
            return request.redirect(to:
                """
                https://slack.com/oauth/authorize?\
                client_id=\(oauth.clientID)&\
                scope=\(oauth.scope)&\
                redirect_uri=http://\(try request.requireHost())/oauth&\
                state=\(state)
                """
            )
        }
    }
}

private extension Request {
    func requireHost() throws -> String {
        guard let host = http.headers.firstValue(name: .host) else { throw Abort(.badRequest) }
        return host
    }
}
