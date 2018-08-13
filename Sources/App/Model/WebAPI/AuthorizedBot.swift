import Vapor

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

public extension AuthorizedBot {
    func respond(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment]? = nil,
        style: ResponseStyle = .inline
    ) throws {
        _ = client.post("\(baseURL)/chat.postMessage", headers: headers) { request in
            try request.content.encode(json: ResponseMessage(
                style: message.isThreaded ? .threaded : style,
                contents: contents,
                attachments: attachments,
                target: message.target
            ))
        }
    }
    
    func respondEphemerally(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment]? = nil
    ) throws {
        _ = client.post("\(baseURL)/chat.postEphemeral", headers: headers) { request in
            try request.content.encode(json: EphemeralMessage(
                contents: contents,
                attachments: attachments,
                target: message.target
            ))
        }
    }
    
    // TODO: investigate possible API bug, I received no_permission rather than missing_scope when I
    // tried to react to a message without adding the reactions:write scope
    func react(to message: Message, with emoji: EmojiRepresentable) throws {
        _ = client.post("\(baseURL)/reactions.add", headers: headers) { request in
            try request.content.encode(json: Reaction(target: message.target, emoji: emoji))
        }.do { response in
            print(response)
        }
    }
    
    func get(_ user: ID<User>) throws -> Future<User> {
        return client.get("\(baseURL)/users.info", headers: headers) { request in
            try request.query.encode(["user": user])
        }.flatMap { response in
            response.content.get(User.self, at: "user")
        }
    }
    
    func get(_ channel: ID<Channel>) throws -> Future<Channel> {
        return client.get("\(baseURL)/channels.info", headers: headers) { request in
            try request.query.encode(["channel": channel])
        }.flatMap { response in
            response.content.get(Channel.self, at: "channel")
        }
    }
    
    func get(_ team: ID<Team>) throws -> Future<Team> {
        return client.get("\(baseURL)/team.info", headers: headers).flatMap { response in
            response.content.get(Team.self, at: "team")
        }
    }
}
