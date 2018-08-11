import Vapor

protocol WebServiceSendable: Encodable {
    static var endpoint: String { get }
}

final class WebService {
    private let accessToken: String
    private let client: Client
    
    init(accessToken: String, client: Client) {
        self.accessToken = accessToken
        self.client = client
    }
}

extension WebService {
    func send<T: WebServiceSendable>(_ object: T) throws {
        let url = "https://slack.com/api/\(T.endpoint)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        
        _ = client.post(url, headers: headers) { request in
            try request.content.encode(json: object)
            print(request.content)
        }
    }
}
