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
    public enum Scope: String, Decodable {
        case channelsHistory = "channels:history"
        case chatWrite = "chat:write"
        case reactionsWrite = "reactions:write"
        case usersRead = "users:read"
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
