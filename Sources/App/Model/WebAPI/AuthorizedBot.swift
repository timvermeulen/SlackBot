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

struct Installation: Decodable {
    let app: ID<User>
    let team: ID<Team>
    let accessToken: OAuth.AccessToken

    enum CodingKeys: String, CodingKey {
        case app = "app_user_id"
        case team = "team_id"
        case accessToken = "access_token"
    }
}

public final class AuthorizedBot {
    public let team: ID<Team>
    let client: Client
    let headers: HTTPHeaders
    
    init(installation: Installation, request: Request) throws {
        team = installation.team
        client = try request.make(Client.self)
        headers = ["Authorization": "Bearer \(installation.accessToken)"]
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
            if try response.content.syncGet(at: "ok") == false {
                throw try response.content.syncDecode(SlackError.self)
            } else {
                return response
            }
        }
    }
    
    func get<T: Decodable>(
        _: T.Type,
        from endpoint: String,
        key: String,
        query: Encodable? = nil
    ) -> Future<T> {
        return send(.GET, endpoint: endpoint, query: query)
            .flatMap { $0.content.get(at: key) }
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
    ) throws -> Future<Response> {
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
    ) throws -> Future<Response> {
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
    func react(to message: Message, with emoji: EmojiRepresentable) throws -> Future<Response> {
        return post(Reaction(target: message.target, emoji: emoji), to: "reactions.add")
    }
    
    func get(_ user: ID<User>) throws -> Future<User> {
        return get(User.self, from: "users.info", key: "user", query: ["user": user])
    }
    
    func get(_ channel: ID<Channel>) throws -> Future<Channel> {
        return get(Channel.self, from: "channels.info", key: "channel", query: ["channel": channel])
    }
    
    func getTeam() throws -> Future<Team> {
        return get(Team.self, from: "team.info", key: "team")
    }
}
