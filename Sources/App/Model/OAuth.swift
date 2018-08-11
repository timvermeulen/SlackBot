import Vapor

public struct OAuth {
    let clientID: ClientID
    let clientSecret: ClientSecret
    let scopes: [Scope]
    
    public init(clientID: ClientID, clientSecret: ClientSecret, scopes: [Scope]) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.scopes = scopes
    }
}

extension OAuth {
    public struct ClientID: Newtype, CustomStringConvertible, ExpressibleByStringLiteral {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public struct ClientSecret: Newtype, CustomStringConvertible, ExpressibleByStringLiteral {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    // see https://api.slack.com/scopes
    public enum Scope: String {
        case channelsHistory = "channels:history"
        case chatWrite = "chat:write"
        case commands
        case conversationsHistory = "conversations:history"
        case conversationsRead = "conversations:read"
        case conversationsWrite = "conversations:write"
        case dndRead = "dnd:read"
        case dndWriteUser = "dnd:write:user"
        case emojiRead = "emoji:read"
        case filesRead = "files:read"
        case filesWrite = "files:write"
        case identityAvatarReadUser = "identity.avatar:read:user"
        case dentityEmailReadUser = "identity.email:read:user"
        case identityTeamReadUser = "identity.team:read:user"
        case identityReadUser = "identity:read:user"
        case linksRead = "links:read"
        case linksWrite = "links:write"
        case pinsRead = "pins:read"
        case pinsWrite = "pins:write"
        case reactionsRead = "reactions:read"
        case reactionsWrite = "reactions:write"
        case remindersReadUser = "reminders:read:user"
        case remindersWriteUser = "reminders:write:user"
        case teamRead = "team:read"
        case usergroupsRead = "usergroups:read"
        case usergroupsWrite = "usergroups:write"
        case usersProfileRead = "users.profile:read"
        case usersProfileWriteUser = "users.profile:write:user"
        case usersRead = "users:read"
        case usersReadEmail = "users:read.email"
    }
    
    struct AccessToken: Newtype, Decodable, CustomStringConvertible {
        let rawValue: String
    }
    
    var headers: HTTPHeaders {
        return ["Authorization": "Basic \(Data("\(clientID):\(clientSecret)".utf8).base64EncodedString())"]
    }
    
    var scope: String {
        return scopes.lazy.map { $0.rawValue }.joined(separator: " ")
    }
}
