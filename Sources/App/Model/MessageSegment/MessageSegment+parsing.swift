extension MessageSegment {
    enum ParseError: Error {
        case missingClosingBracket(Substring)
        case emptyFirstPart
    }
    
    init?(parsing left: Substring, _ right: Substring?) throws {
        guard let token = left.first else { return nil }
        let leftString = String(left.dropFirst())
        
        switch token {
        case "@":
            self = .user(ID(rawValue: leftString))
            
        case "#":
            self = .channel(ID(rawValue: leftString))
            
        case "!":
            let command = try Command(parsing: leftString)
            self = .command(command)
            
        default:
            self = .unknown(left: String(left), right: right.map { String($0) })
        }
    }
}
