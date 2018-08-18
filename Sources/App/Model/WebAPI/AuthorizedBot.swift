import Vapor

struct AnyEncodable: Encodable {
    let base: Encodable
    
    init(_ base: Encodable) {
        self.base = base
    }
    
    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}

// TODO: add caching for users, channels, etc

private let baseURL = "https://slack.com/api"

public final class AuthorizedBot {
    public let team: ID<Team>
    private let client: Client
    private let headers: HTTPHeaders
    
    init(installation: Installation, client: Client) {
        self.team = installation.team
        self.client = client
        self.headers = ["Authorization": "Bearer \(installation.accessToken)"]
    }
}

extension AuthorizedBot {
    func send(
        _ method: HTTPMethod,
        endpoint: String,
        query: Encodable? = nil,
        content: Encodable? = nil
    ) -> Future<Response> {
        return client.send(method, headers: headers, to: "\(baseURL)/\(endpoint)") { request in
            if let query = query {
                try request.query.encode(AnyEncodable(query))
            }
            
            if let content = content {
                try request.content.encode(json: AnyEncodable(content))
            }
        }.map { response in
            if try response.content.syncGet(Bool.self, at: "ok") {
                return response
            } else {
                throw try response.content.syncDecode(SlackError.self)
            }
        }
    }
    
    func get(from endpoint: String, query: Encodable? = nil) -> Future<Response> {
        return send(.GET, endpoint: endpoint, query: query)
    }
    
    func post(_ content: Encodable, to endpoint: String) -> Future<Response> {
        return send(.POST, endpoint: endpoint, content: content)
    }
}

public extension AuthorizedBot {
    func respond(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment]? = nil,
        style: ResponseStyle = .inline
    ) -> Future<Response> {
        return post(
            ResponseMessage(
                style: message.isThreaded ? .threaded : style,
                contents: contents,
                attachments: attachments,
                target: message.target
            ),
            to: "chat.postMessage"
        )
    }
    
    func respondEphemerally(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment]? = nil
    ) -> Future<Response> {
        return post(
            EphemeralMessage(
                contents: contents,
                attachments: attachments,
                target: message.target
            ),
            to: "chat.postEphemeral"
        )
    }
    
    // TODO: investigate possible API bug, I received no_permission rather than missing_scope when I
    // tried to react to a message without adding the reactions:write scope
    func react(to message: Message, with emoji: EmojiRepresentable) -> Future<Response> {
        return post(Reaction(target: message.target, emoji: emoji), to: "reactions.add")
    }
    
    func get(_ user: ID<User>) -> Future<User> {
        return get(from: "users.info", query: ["user": user])
            .flatMap { $0.content.get(User.self, at: "user") }
    }
    
    func get(_ channel: ID<Channel>) -> Future<Channel> {
        return get(from: "channels.info", query: ["channel": channel])
            .flatMap { $0.content.get(Channel.self, at: "channel") }
    }
    
    func getTeam() -> Future<Team> {
        return get(from: "team.info").flatMap { $0.content.get(Team.self, at: "team") }
    }
}
