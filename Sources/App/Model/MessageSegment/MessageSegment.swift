public enum MessageSegment {
    case raw(String)
    case command(Command)
    case user(ID<User>)
    case channel(ID<Channel>)
    case unknown(left: String, right: String?)
}

extension MessageSegment {
    var rawValue: String {
        switch self {
        case .raw(let string):
            // see https://api.slack.com/docs/message-formatting
            return string
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            
        case .command(let command):
            return "<!\(command.rawValue)>"
            
        case .user(let user):
            return "<@\(user.rawValue)>"
            
        case .channel(let channel):
            return "<#\(channel.rawValue)>"
            
        case let .unknown(left, right):
            return "<\(left)\(right.map { "|\($0)" } ?? "")>"
        }
    }
}

extension MessageSegment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .raw(let string):
            return string
        default:
            return rawValue
        }
    }
}
