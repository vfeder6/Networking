import Foundation

public struct NetworkService {
    let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    public func response<Response: Decodable>(
        from endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expect statusCode: Int = 200,
        decode type: Response.Type
    ) async -> Result<NetworkResponse<Response>, NetworkError> {
        do {
            return .success(try await client.performRequest(
                to: endpoint.prependingSlashIfNotPresent,
                queryItems: queryItems,
                body: body,
                method: method,
                additionalHeaders: additionalHeaders,
                expect: statusCode,
                decode: type
            ))
        } catch {
            return .failure(.casted(from: error))
        }
    }

    public func body<Response: Decodable>(
        from endpoint: String,
        with queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expect statusCode: Int = 200,
        decodeTo type: Response.Type
    ) async -> Result<Response, NetworkError> {
        let result = await response(
            from: endpoint.prependingSlashIfNotPresent,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expect: statusCode,
            decode: type
        )

        switch result {
        case .success(let response):
            guard let body = response.body else {
                return .failure(.mismatchingRequestedResponseType)
            }
            return .success(body)
        case .failure(let networkError):
            return .failure(networkError)
        }
    }

    public func emptyBody(
        from endpoint: String,
        with queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expect statusCode: Int = 200
    ) async -> Result<Void, NetworkError> {
        let result = await response(
            from: endpoint.prependingSlashIfNotPresent,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expect: statusCode,
            decode: Empty.self
        )

        switch result {
        case .success:
            return .success(())
        case .failure(let networkError):
            return .failure(networkError)
        }
    }
}

private struct Empty: Decodable { }

private extension String {
    var prependingSlashIfNotPresent: Self {
        starts(with: "/") ? self : "/\(self)"
    }
}

extension NetworkService {
    public static func live(host: URL, baseHeaders: [String: String] = [:]) -> NetworkService {
        .init(client: NetworkClient(host: host, baseHeaders: baseHeaders))
    }

    public static var mock: NetworkService {
        .init(client: NetworkClient(host: .init(string: "https://mock-instance.com")!, baseHeaders: [:]))
    }
}

extension NetworkError {
    static func casted(from error: Error) -> Self {
        error as? Self ?? .unknown
    }
}