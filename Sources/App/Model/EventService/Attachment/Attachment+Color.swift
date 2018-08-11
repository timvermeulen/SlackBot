extension Attachment {
    public enum Color {
        case good
        case warning
        case danger
        case hex(String)
    }
}

extension Attachment.Color: Encodable {
    var rawValue: String {
        switch self {
        case .good:
            return "good"
        case .warning:
            return "warning"
        case .danger:
            return "danger"
        case .hex(let hex):
            return "#\(hex)"
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension Attachment.Color: Decodable {
    public init(from decoder: Decoder) throws {
        self = .good // TODO
    }
}
