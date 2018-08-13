private struct AnyCodingKey: CodingKey {
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? {
        fatalError()
    }
    
    init?(intValue: Int) {
        fatalError()
    }
}

public enum SlackError: Error {
    case invalidAuth
    case missingScope(OAuth.Scope)
    case noPermission
    case notAuthed
    case unknownMethod(String)
    
    case unknown(String)
}

extension SlackError: Decodable {
    private enum ErrorType: String, Decodable {
        case invalidAuth = "invalid_auth"
        case missingScope = "missing_scope"
        case noPermission = "no_permission"
        case notAuthed = "not_authed"
        case unknownMethod = "unknown_method"
    }
    
    private enum CodingKeys: String, CodingKey {
        case error
        case needed
        case requestMethod = "req_method"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let errorType = try? container.decode(ErrorType.self, forKey: .error) else {
            self = .unknown(try container.decode(String.self, forKey: .error))
            return
        }
        
        switch errorType {
        case .invalidAuth:
            self = .invalidAuth
        case .missingScope:
            self = .missingScope(try container.decode(OAuth.Scope.self, forKey: .needed))
        case .noPermission:
            self = .noPermission
        case .notAuthed:
            self = .notAuthed
        case .unknownMethod:
            self = .unknownMethod(try container.decode(String.self, forKey: .requestMethod))
        }
    }
}
