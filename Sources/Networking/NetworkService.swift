import Foundation

protocol NetworkServiceProtocol {
    var networkClient: NetworkClientProtocol { get }
    var host: URL { get }
    var baseHeaders: [String: String] { get }

    func performRequest<Response: Decodable>(
        to url: URL,
        body: (any Encodable)?,
        method: HTTPMethod,
        additionalHeaders: [String: String]?,
        expect statusCode: Int,
        decodeTo type: Response.Type?
    ) async throws -> FullHTTPResponse<Response>

    func performRequest<Response: Decodable>(
        to url: URL,
        body: (any Encodable)?,
        method: HTTPMethod,
        additionalHeaders: [String: String]?,
        expect statusCode: Int,
        decodeTo type: Response.Type?
    ) async throws -> Response?
}

struct NetworkService: NetworkServiceProtocol {
    let networkClient: NetworkClientProtocol = NetworkClient()
    let host: URL
    let baseHeaders: [String : String]

    init(host: URL, baseHeaders: [String : String]) {
        self.host = host
        self.baseHeaders = baseHeaders
    }

    func performRequest<Response: Decodable>(
        to url: URL,
        body: (any Encodable)?,
        method: HTTPMethod,
        additionalHeaders: [String: String]? = nil,
        expect statusCode: Int,
        decodeTo type: Response.Type?
    ) async throws -> Response? {
        let responseBody = try await performRequest(
            to: url,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expect: statusCode,
            decodeTo: type
        ).body

        if type == nil && responseBody != nil || type != nil && responseBody == nil {
            throw NewNetworkError.mismatchingRequestedResponseType
        }
        return responseBody
    }

    func performRequest<Response: Decodable>(
        to url: URL,
        body: (any Encodable)?,
        method: HTTPMethod,
        additionalHeaders: [String: String]? = nil,
        expect statusCode: Int,
        decodeTo type: Response.Type?
    ) async throws -> FullHTTPResponse<Response> {
        var data: Data?

        if let body {
            guard let bodyData = try? JSONEncoder().encode(body) else {
                throw NewNetworkError.notEncodableData
            }
            data = bodyData
        }

        let request = HTTPRequest(url: url, method: method, headers: composeHeaders(additionalHeaders), body: data)
        let response = try await networkClient.perform(request: request)
        return try process(response: response, expecting: statusCode, responseType: type)
    }
}

extension NetworkService {
    private func process<Response: Decodable>(
        response: HTTPResponse,
        expecting statusCode: Int,
        responseType type: Response.Type?
    ) throws -> FullHTTPResponse<Response> {
        guard let urlResponse = response.urlResponse as? HTTPURLResponse else {
            throw NewNetworkError.badURLResponse
        }
        guard urlResponse.statusCode == statusCode else {
            throw NewNetworkError.mismatchingStatusCodes(expected: statusCode, actual: urlResponse.statusCode)
        }
        guard let headers = urlResponse.allHeaderFields as? [String: String] else {
            throw NewNetworkError.notParseableHeaders
        }
        guard let type = type else {
            return .init(headers: headers, body: nil)
        }
        guard let decoded = try? JSONDecoder().decode(type, from: response.body) else {
            throw NewNetworkError.notDecodableData
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
}
