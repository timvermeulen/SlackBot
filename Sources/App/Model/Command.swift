public enum Command: String {
    case channel
    case here
    case everyone
    // TODO: subteam
}

extension Command {
    enum ParseError: Error {
        case invalid(String)
    }
    
    init(parsing raw: String) throws {
        guard let command = Command(rawValue: raw) else { throw ParseError.invalid(raw) }
        self = command
    }
}
