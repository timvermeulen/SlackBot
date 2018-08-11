import Vapor

final class SlashCommandService {
    private let router: Router
    
    init(router: Router) {
        self.router = router
    }
}

extension SlashCommandService {
    func addSlashCommand(
        at path: PathComponentsRepresentable...,
        makeResponse: @escaping (Request) throws -> Future<SlashCommandResponse>
    ) {
        router.post(path) { request -> Future<SlashCommandResponse> in
            let data = try request.content.decode(SlashCommandData.self)
            
            return data.map { data in
                SlashCommandResponse(contents: ["hullo ", data.text], type: .ephemeral)
            }
        }
    }
}

public struct SlashCommandData: Decodable {
    let responseURL: String
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case responseURL = "response_url"
        case text
    }
}

public struct SlashCommandResponse: Content {
    let contents: MessageContents?
    let type: ResponseType?
    
    public init(contents: MessageContents? = nil, type: ResponseType? = nil) {
        self.contents = contents
        self.type = type
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "response_type"
        case contents = "text"
    }
    
    public enum ResponseType: String, Codable {
        case inChannel = "in_channel"
        case ephemeral
    }
}

extension SlashCommandResponse: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(contents: [value])
    }
}
