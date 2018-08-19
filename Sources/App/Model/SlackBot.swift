import Vapor
import FluentSQLite

public final class SlackBot {
    private let app: Application
    private let router: Router
    private let oauth: OAuth
    
    private let eventsAPI: EventsAPI
    private let slashCommandService: SlashCommandService
    
    public init(oauth: OAuth, signingSecret: SigningSecret) throws {
        var services = Services.default()
        try services.register(FluentSQLiteProvider())
        services.register(LogMiddleware.self)
        
        let router = EngineRouter.default()
        services.register(router, as: Router.self)
        
        var middlewares = MiddlewareConfig()
        middlewares.use(LogMiddleware.self)
        middlewares.use(ErrorMiddleware.self)
        services.register(middlewares)
        
        var databases = DatabasesConfig()
        databases.add(database: try SQLiteDatabase(storage: .file(path: "db.sqlite")), as: .sqlite)
        services.register(databases)
        
        var migrations = MigrationConfig()
        migrations.add(model: SQLiteModelWrapper<Installation>.self, database: .sqlite)
        services.register(migrations)
        
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
    
    func handleMessage(_ handler: @escaping (AuthorizedBot, Message) -> Void) {
        eventsAPI.handleMessage { request, client, team, message in
            // TODO: log error
            _ = self.installation(of: team, request: request).do { installation in
                guard let installation = installation,
                      installation.app != message.user
                else { return }
                
                let authorized = AuthorizedBot(
                    installation: installation,
                    client: client
                )
                
                handler(authorized, message)
            }
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
    func saveInstallation(_ installation: Installation, request: Request) {
        // TODO: log error properly
        SQLiteModelWrapper(installation).save(on: request).catch { error in
            print(error)
        }
    }
    
    func installation(of team: ID<Team>, request: Request) -> Future<Installation?> {
        return SQLiteModelWrapper<Installation>.query(on: request)
            .filter(\Installation.team == team).first()
            .map { $0?.model }
    }
    
    func setUpOAuth() {
        let state = UUID().uuidString
        
        router.get("oauth") { [oauth] request -> Future<HTTPResponseStatus> in
            let code = try request.query.get(String.self, at: "code")
            let responseState = try request.query.get(String.self, at: "state")
            
            guard responseState == state else { throw Abort(.badRequest) }
            
            let response = try request.make(Client.self).get("""
                https://slack.com/api/oauth.access?\
                code=\(code)&\
                redirect_uri=https://\(try request.requireHost())/oauth
                """,
                headers: oauth.headers
            )

            return response
                .flatMap { try $0.content.decode(Installation.self) }
                .do { self.saveInstallation($0, request: request) }
                .transform(to: .ok)
        }
        
        router.get("install") { [oauth] request -> Response in
            return request.redirect(to:
                """
                https://slack.com/oauth/authorize?\
                client_id=\(oauth.clientID)&\
                scope=\(oauth.scope)&\
                redirect_uri=https://\(try request.requireHost())/oauth&\
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
