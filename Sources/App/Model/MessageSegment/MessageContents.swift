public struct MessageContents {
    public let segments: [MessageSegment]
    
    public init(_ segments: [MessageSegment]) {
        self.segments = segments
    }
}

extension MessageContents: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MessageSegmentRepresentable...) {
        segments = elements.map { $0.messageSegment }
    }
}

extension MessageContents: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        segments = [value.messageSegment]
    }
}

extension MessageContents: Codable {
    public init(from decoder: Decoder) throws {
        let text = try String(from: decoder)
        
        var remainder = text[...]
        var segments: [MessageSegment] = []
        
        while let first = remainder.first {
            if first == "<" {
                guard let closingIndex = remainder.firstIndex(of: ">") else {
                    throw MessageSegment.ParseError.missingClosingBracket(remainder)
                }
                
                let left: Substring
                let right: Substring?
                
                let bothParts = remainder[..<closingIndex].dropFirst()
                
                if let pipeIndex = bothParts.firstIndex(of: "|") {
                    left = bothParts[..<pipeIndex]
                    right = bothParts[pipeIndex...].dropFirst()
                } else {
                    left = bothParts
                    right = nil
                }
                
                let segment = try MessageSegment(parsing: left, right)
                    ?? .unknown(left: String(left), right: right.map { String($0) })
                
                segments.append(segment)
                remainder = remainder[closingIndex...].dropFirst()
            } else {
                let index = remainder.firstIndex(of: "<") ?? remainder.endIndex
                
                // see https://api.slack.com/docs/message-formatting
                let raw = remainder[..<index]
                    .replacingOccurrences(of: "&amp;", with: "&")
                    .replacingOccurrences(of: "&lt;",  with: "<")
                    .replacingOccurrences(of: "&gt;",  with: ">")
                
                segments.append(.raw(raw))
                remainder = remainder[index...]
            }
        }
        
        self.segments = segments
    }
    
    public func encode(to encoder: Encoder) throws {
        try segments.lazy.map { $0.rawValue }.joined().encode(to: encoder)
    }
}
