import Foundation

public struct NetworkClient {
    private let dataProcessor: NetworkDataProcessor

    private init(dataProcessor: NetworkDataProcessor) {
        self.dataProcessor = dataProcessor
    }

    public func fullResponse<Response: Decodable>(
        from endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expectedStatusCode: Int = 200,
        decode type: Response.Type
    ) async -> Result<NetworkResponse<Response>, NetworkError> {
        do {
            return .success(try await dataProcessor.performRequest(
                to: endpoint.prependingSlashIfNotPresent,
                queryItems: queryItems,
                body: body,
                method: method,
                additionalHeaders: additionalHeaders,
                expect: expectedStatusCode,
                decode: type
            ))
        } catch {
            return .failure(.casted(from: error))
        }
    }

    public func response<Response: Decodable>(
        from endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expectedStatusCode: Int = 200,
        decode type: Response.Type
    ) async -> Result<Response, NetworkError> {
        let result = await fullResponse(
            from: endpoint.prependingSlashIfNotPresent,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expectedStatusCode: expectedStatusCode,
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

    public func perform(
        to endpoint: String,
        with queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expectedStatusCode: Int = 200
    ) async -> Result<Void, NetworkError> {
        let result = await fullResponse(
            from: endpoint.prependingSlashIfNotPresent,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expectedStatusCode: expectedStatusCode,
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

struct Empty: Codable { }

private extension String {
    var prependingSlashIfNotPresent: Self {
        starts(with: "/") ? self : "/\(self)"
    }
}

extension NetworkClient {
    public static func live(host: URL, baseHeaders: [String: String] = [:]) -> NetworkClient {
        .init(dataProcessor: .init(requestExecutor: NetworkRequestExecutor(), host: host, baseHeaders: baseHeaders))
    }

    public static func mock<Response: Codable>(
        returning result: Result<Response, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Duration = .zero
    ) throws -> NetworkClient {
        let url = URL(string: "https://example.com")!

        return .init(dataProcessor: .init(requestExecutor: NetworkRequestExecutorMock(
            response: result.successData,
            responseURL: url,
            expectedStatusCode: statusCode,
            respondsAfter: sleepDuration
        ), host: url, baseHeaders: [:]))
    }
}

extension NetworkError {
    static func casted(from error: Error) -> Self {
        error as? Self ?? .unknown
    }
}

private extension Result where Success: Codable {
    var successData: Result<Data, Failure> {
        switch self {
        case .success(let encodable):
            let successData = try! JSONEncoder().encode(encodable)
            return .success(successData)

        case .failure(let error):
            return .failure(error)
        }
    }
}
