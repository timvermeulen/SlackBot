import Vapor

public final class SlackBot {
    private let app: Application
    private let me: ID<User>
    private let client: Client
    
    private let eventService: EventService
    private let webService: WebService
    private let slashCommandService: SlashCommandService
    
    public init(accessToken: String, signingSecret: String, id: String) throws {
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
        
        me = ID(rawValue: id)
        client = try app.make(Client.self)
        
        eventService = EventService(signingSecret: signingSecret, router: router)
        webService = WebService(accessToken: accessToken, client: client)
        slashCommandService = SlashCommandService(router: router, client: client)
    }
    
    public func start() throws {
        try eventService.start()
        try app.run()
    }
}

public extension SlackBot {
    func handleMessage(_ handler: @escaping (Message) throws -> Void) {
        eventService.handleMessage { [me] message in
            guard message.user != me else { return }
            try handler(message)
        }
    }
    
    func addSlashCommand(
        at path: PathComponentsRepresentable...,
        makeResponse: @escaping (Request, Client) throws -> Future<SlashCommandResponse>
    ) {
        slashCommandService.addSlashCommand(at: path) { [client] request in
            try makeResponse(request, client)
        }
    }
    
    func respond(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment] = [],
        style: ResponseStyle = .inline
    ) throws {
        try webService.send(ResponseMessage(
            style: message.isThreaded ? .threaded : style,
            contents: contents,
            attachments: attachments,
            target: message.target
        ))
    }
    
    func respondEphemerally(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment] = []
    ) throws {
        try webService.send(EphemeralMessage(
            contents: contents,
            attachments: attachments,
            target: message.target
        ))
    }
    
    func react(to message: Message, with emoji: EmojiRepresentable) throws {
        try webService.send(Reaction(target: message.target, emoji: emoji))
    }
}
