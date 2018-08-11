import Vapor

protocol WebServiceSendable: Encodable {
    // TODO: use `Newtype`
    static var endpoint: String { get }
}

final class WebService {
    func send<T: WebServiceSendable>(_ object: T, client: Client, accessToken: OAuth.AccessToken) throws {
        let url = "https://slack.com/api/\(T.endpoint)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        
        _ = client.post(url, headers: headers) { request in
            try request.content.encode(json: object)
        }
    }
}
