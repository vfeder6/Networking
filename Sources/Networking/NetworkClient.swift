import Foundation

protocol NetworkClientProtocol {
    var requestExecutor: NetworkRequestExecutorProtocol { get }
    var host: URL { get }
    var baseHeaders: [String: String] { get }

    func performRequest<Response: Decodable>(
        to endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Encodable)?,
        method: HTTPMethod,
        additionalHeaders: [String: String],
        expect statusCode: Int,
        decode type: Response.Type?
    ) async throws -> NetworkResponse<Response>
}

struct NetworkClient: NetworkClientProtocol {
    let requestExecutor: NetworkRequestExecutorProtocol = NetworkRequestExecutor()
    let host: URL
    let baseHeaders: [String : String]

    init(host: URL, baseHeaders: [String : String]) {
        self.host = host
        self.baseHeaders = baseHeaders
    }

    func performRequest<Response: Decodable>(
        to endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: (any Encodable)?,
        method: HTTPMethod,
        additionalHeaders: [String: String] = [:],
        expect statusCode: Int,
        decode type: Response.Type?
    ) async throws -> NetworkResponse<Response> {
        var bodyData: Data?

        if let body {
            guard let data = try? JSONEncoder().encode(body) else {
                throw NetworkError.notEncodableData
            }
            bodyData = data
        }

        let request = HTTPRequest(
            url: composeURL(endpoint, queryItems: queryItems),
            method: method,
            headers: composeHeaders(additionalHeaders),
            body: bodyData
        )
        let response = try await requestExecutor.perform(request: request)
        return try process(response: response, expecting: statusCode, responseType: type)
    }
}

extension NetworkClient {
    private func process<Response: Decodable>(
        response: HTTPResponse,
        expecting statusCode: Int,
        responseType type: Response.Type?
    ) throws -> NetworkResponse<Response> {
        guard let urlResponse = response.urlResponse as? HTTPURLResponse else {
            throw NetworkError.badURLResponse
        }
        guard urlResponse.statusCode == statusCode else {
            throw NetworkError.mismatchingStatusCodes(expected: statusCode, actual: urlResponse.statusCode)
        }
        guard let headers = urlResponse.allHeaderFields as? [String: String] else {
            throw NetworkError.notParseableHeaders
        }
        guard let type = type else {
            return .init(headers: headers, body: nil)
        }
        guard let decoded = try? JSONDecoder().decode(type, from: response.body) else {
            throw NetworkError.notDecodableData
        }
        return .init(headers: headers, body: decoded)
    }

    func composeHeaders(_ additionalHeaders: [String: String]?) -> [String: String] {
        var allHeaders = baseHeaders
        additionalHeaders.map { headers in
            headers.forEach { header in
                allHeaders[header.key] = header.value
            }
        }
        return allHeaders
    }

    func composeURL(_ endpoint: String, queryItems: [URLQueryItem]) -> URL {
        host.appendingPathExtension(endpoint).appending(queryItems: queryItems)
    }
}

extension Result where Failure == NetworkError {
    var displayable: Result<Success, DisplayableError> {
        switch self {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            return .failure(.from(failure))
        }
    }
}
