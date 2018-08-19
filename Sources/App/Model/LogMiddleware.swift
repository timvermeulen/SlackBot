import Vapor

final class LogMiddleware: Middleware {
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        let start = Date()
        
        return try next.respond(to: request).map { response in
            self.log(response, duration: -start.timeIntervalSinceNow, for: request)
            return response
        }
    }
    
    func log(_ response: Response, duration: TimeInterval, for req: Request) {
        let requestInfo = "\(req.http.method.string) \(req.http.url.path)"
        let responseInfo = "\(response.http.status.code) " + "\(response.http.status.reasonPhrase)"
        
        logger.info("\(requestInfo) -> \(responseInfo) [\(duration)]")
    }
}

extension LogMiddleware: ServiceType {
    static func makeService(for container: Container) throws -> LogMiddleware {
        return try .init(logger: container.make())
    }
}
