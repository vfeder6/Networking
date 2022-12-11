import Foundation

struct NetworkService {
    let client: NetworkClientProtocol

    func response<Response: Decodable>(
        from endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expect statusCode: Int = 200,
        decodeTo type: Response.Type
    ) async -> Result<NetworkResponse<Response>, NetworkError> {
        do {
            return .success(try await client.performRequest(
                to: endpoint,
                with: queryItems,
                body: body,
                method: method,
                additionalHeaders: additionalHeaders,
                expect: statusCode,
                decodeTo: type
            ))
        } catch {
            return .failure(.casted(from: error))
        }
    }

    func performRequest<Response: Decodable>(
        to endpoint: String,
        with queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expect statusCode: Int = 200,
        decodeTo type: Response.Type
    ) async -> Result<Response, NetworkError> {
        let result = await response(
            from: endpoint,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expect: statusCode,
            decodeTo: type
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

    func emptyResponse(
        from endpoint: String,
        with queryItems: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expect statusCode: Int = 200
    ) async -> Result<Void, NetworkError> {
        let result = await response(
            from: endpoint,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expect: statusCode,
            decodeTo: Empty.self
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

extension NetworkClient {
    static var shared: Self {
        .init(host: .init(string: "https://example.com")!, baseHeaders: [:])
    }
}

extension NetworkError {
    static func casted(from error: Error) -> Self {
        error as? Self ?? .unknown
    }
}
