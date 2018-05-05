import Vapor

struct Model {
    let price: Double
}

extension Model: Decodable {
    init(from decoder: Decoder) throws {
        let dictionary = try [String: Double](from: decoder)
        price = dictionary["USD"]!
    }
}

final class SlashCommandService {
    private let router: Router
    private let client: Client
    
    init(router: Router, client: Client) {
        self.router = router
        self.client = client
    }
}

// taken from Router+Method.swift
private extension Router {
    func post<T: ResponseEncodable>(_ path: [PathComponentsRepresentable], use closure: @escaping (Request) throws -> T) {
        let responder = BasicResponder { try closure($0).encode(for: $0) }
        let route = Route<Responder>(path: [.constant(HTTPMethod.POST.string)] + path.convertToPathComponents(), output: responder)
        register(route: route)
    }
}

extension SlashCommandService {
    func addSlashCommand(at path: [PathComponentsRepresentable], makeResponse: @escaping (Request) throws -> Future<SlashCommandResponse>) {
        router.post(path) { request -> Future<HTTPStatus> in
            let data = try request.content.decode(SlashCommandData.self)

            return data.map { data in
                let symbol = data.text

                let model = self.client
                    .get("https://min-api.cryptocompare.com/data/price?fsym=\(symbol)&tsyms=USD")
                    .flatMap(to: Model.self) { try $0.content.decode(Model.self) }

                model.do { model in
                    let response = SlashCommandResponse(contents: ["1 \(symbol) = \(model.price) USD"])
                    
                    _ = self.client.post(data.responseURL) { request in
                        try request.content.encode(response)
                    }
                }.catch { error in
                    print(error)
                }

                return .ok
            }
        }
    }
}

public struct SlashCommandData: Codable {
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
