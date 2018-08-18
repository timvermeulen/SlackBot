import Vapor
import Crypto
import Newtype

public struct SigningSecret: Newtype, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

private extension HTTPHeaderName {
    static let slackTimestamp = HTTPHeaderName("X-Slack-Request-Timestamp")
    static let slackSignature = HTTPHeaderName("X-Slack-Signature")
}

extension Request {
    func verifySigningSecret(_ signingSecret: SigningSecret) throws {
        guard let timestamp = http.headers.firstValue(name: .slackTimestamp),
              let signature = http.headers.firstValue(name: .slackSignature)
        else { throw Abort(.forbidden) }
        
        // TODO: Slack recommends verifying that the timestamp is recent (e.g. within the last 5
        // minutes) in order to prevent a replay attack
        
        let digest = try HMAC.SHA256.authenticate(
            "v0:\(timestamp):\(http.body)",
            key: signingSecret.rawValue
        )
        
        if "v0=\(digest.hexEncodedString())" != signature {
            throw Abort(.forbidden)
        }
    }
}
