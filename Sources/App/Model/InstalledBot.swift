import Vapor

struct Installation: Decodable {
    let appID: ID<User>
    let teamID: String
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case appID = "app_user_id"
        case teamID = "team_id"
        case accessToken = "access_token"
    }
}

public final class InstalledBot {
    let webService: WebService
    let installation: Installation
    let client: Client
    
    init(webService: WebService, installation: Installation, client: Client) {
        self.webService = webService
        self.installation = installation
        self.client = client
    }
}

public extension InstalledBot {
    func respond(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment]? = nil,
        style: ResponseStyle = .inline
    ) throws {
        try webService.send(
            ResponseMessage(
                style: message.isThreaded ? .threaded : style,
                contents: contents,
                attachments: attachments,
                target: message.target
            ),
            client: client,
            accessToken: installation.accessToken
        )
    }
    
    func respondEphemerally(
        to message: Message,
        with contents: MessageContents,
        attachments: [Attachment]? = nil
    ) throws {
        try webService.send(
            EphemeralMessage(
                contents: contents,
                attachments: attachments,
                target: message.target
            ),
            client: client,
            accessToken: installation.accessToken
        )
    }
    
    func react(to message: Message, with emoji: EmojiRepresentable) throws {
        try webService.send(
            Reaction(target: message.target, emoji: emoji),
            client: client,
            accessToken: installation.accessToken
        )
    }
}
