import Foundation

/// A processor of input and output data for network requests.
struct NetworkDataProcessor {
    private let requestExecutor: NetworkRequestExecutorProtocol
    private let host: URL
    private let baseHeaders: [String : String]

    /// Initializes an instance with a base URL and base headers.
    ///
    /// - Parameter requestExecutor: The entity responsible of performing the network request.
    /// - Parameter baseURL: The starting base URL
    /// - Parameter baseHeaders: The starting base headers
    init(requestExecutor: NetworkRequestExecutorProtocol, baseURL: URL, baseHeaders: [String : String]) {
        self.requestExecutor = requestExecutor
        self.host = baseURL
        self.baseHeaders = baseHeaders
    }

    /// Performs a network request.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Encodable` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    /// - Parameter type: The `Decodable` type expected in the response body
    ///
    /// - Returns: A `NetworkResponse` entity.
    ///
    /// - Throws: A `NetworkError` case.
    func performRequest<Response: Decodable>(
        to endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: Encodable?,
        method: HTTPMethod,
        additionalHeaders: [String: String] = [:],
        expectedStatusCode: Int,
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
        return try process(response: response, expectedStatusCode: expectedStatusCode, responseType: type)
    }
}

extension NetworkDataProcessor {
    private func process<Response: Decodable>(
        response: HTTPResponse,
        expectedStatusCode: Int,
        responseType type: Response.Type?
    ) throws -> NetworkResponse<Response> {
        guard let urlResponse = response.urlResponse as? HTTPURLResponse
        else { throw NetworkError.badURLResponse }

        guard urlResponse.statusCode == expectedStatusCode
        else { throw NetworkError.mismatchingStatusCodes(expected: expectedStatusCode, actual: urlResponse.statusCode) }

        guard let headers = urlResponse.allHeaderFields as? [String: String]
        else { throw NetworkError.notParseableHeaders }

        guard let type = type
        else { return .init(headers: headers, body: nil) }

        guard let decoded = try? JSONDecoder().decode(type, from: response.body) else {
            throw NetworkError.notDecodableData(
                model: type,
                json: response.body.prettyPrintedJSON
            )
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
        let endpointURL = host.appending(path: endpoint)
        return queryItems.isEmpty ? endpointURL : endpointURL.appending(queryItems: queryItems)
    }
}

extension Data {
    var prettyPrintedJSON: String? {
        guard
            let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        else { return nil }
        return String(decoding: jsonData, as: UTF8.self)
    }
}
