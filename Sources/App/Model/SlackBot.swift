import Vapor

public struct OAuth {
    let clientID: String
    let clientSecret: String
    let scopes: [String]
    
    public init(clientID: String, clientSecret: String, scopes: [String]) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.scopes = scopes
    }
    
    var headers: HTTPHeaders {
        return ["Authorization": "Basic \(Data("\(clientID):\(clientSecret)".utf8).base64EncodedString())"]
    }
    
    var scope: String {
        return scopes.joined(separator: " ")
    }
}

public final class SlackBot {
    private let app: Application
    private let router: Router
    private let oauth: OAuth
    private let url: String
    
    private let eventService: EventService
    private let webService: WebService
    private let slashCommandService: SlashCommandService
    
    // TODO: add persistence for this
    private var installations: [String: Installation] = [:]
    
    public init(oauth: OAuth, signingSecret: String, url: String) throws {
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
        self.url = url
        
        self.eventService = EventService(signingSecret: signingSecret, router: router)
        self.webService = WebService()
        self.slashCommandService = SlashCommandService(router: router)
    }
}

public extension SlackBot {
    func start() throws {
        router.get("hello") { _ in
            "Hello, world!"
        }
        
        setUpOAuth()
        try eventService.start()
        try app.run()
    }
    
    func handleMessage(_ handler: @escaping (InstalledBot, Message) throws -> Void) {
        eventService.handleMessage { [webService] client, teamID, message in
            guard let installation = self.installations[teamID],
                  installation.appID != message.user
            else { return }
            
            let installedBot = InstalledBot(
                webService: webService,
                installation: installation,
                client: client
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
        let redirectURI = "\(url)/oauth"
        let state = UUID().uuidString
        
        router.get("oauth") { [oauth] request -> Future<HTTPResponseStatus> in
            struct Response: Decodable {
                let code: String
                let state: String
            }
            
            let response = try request.query.decode(Response.self)
            guard response.state == state else { throw Abort(.badRequest) }
            
            return try request.make(Client.self).get("""
                https://slack.com/api/oauth.access?\
                code=\(response.code)&\
                redirect_uri=\(redirectURI)
                """,
                headers: oauth.headers
            )
                .flatMap { try $0.content.decode(Installation.self) }
                .do { self.installations[$0.teamID] = $0 }
                .catch { print("error: \($0)") } // TODO: log this error properly
                .map { _ in .ok }
        }
        
        router.get("install") { [oauth] request in
            request.redirect(to:
                """
                https://slack.com/oauth/authorize?\
                client_id=\(oauth.clientID)&\
                scope=\(oauth.scope)&\
                redirect_uri=\(redirectURI)&\
                state=\(state)
                """
            )
        }
    }
}
