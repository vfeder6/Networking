import Foundation

public protocol NetworkClientProtocol {
    associatedtype R: Equatable

    var networkInterfaced: NetworkInterfaced { get }
    var baseURL: URL { get }
    var baseHeaders: [String : String] { get }

    init(networkInterfaced: NetworkInterfaced, baseURL: URL, baseHeaders: [String : String])

    func performRequest(
        to endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: [String : String],
        expectedStatusCode: Int
    ) async throws -> NetworkResponse<R>

    func process(
        response: HTTPResponse,
        expectedStatusCode: Int
    ) throws -> NetworkResponse<R>
}

extension NetworkClientProtocol {

    /// Performs a network request.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Request` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    /// - Parameter type: The `Decodable` type expected in the response body
    ///
    /// - Returns: A `NetworkResponse` entity.
    ///
    /// - Throws: A `NetworkError`.
    public func performRequest(
        to endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: [String : String],
        expectedStatusCode: Int
    ) async throws -> NetworkResponse<R> {
        let request = HTTPRequest(
            url: composeURL(endpoint, queryItems: queryItems),
            method: method,
            headers: composeHeaders(additionalHeaders),
            body: try encodeBody(body)
        )
        let response = try await networkInterfaced.send(request: request)
        return try process(response: response, expectedStatusCode: expectedStatusCode)
    }
}

// MARK: - Request data processing

extension NetworkClientProtocol {
    func composeHeaders(_ additionalHeaders: [String : String]?) -> [String : String] {
        var allHeaders = baseHeaders
        additionalHeaders.map { headers in
            headers.forEach { header in
                allHeaders[header.key] = header.value
            }
        }
        return allHeaders
    }

    func composeURL(_ endpoint: String, queryItems: [URLQueryItem]) -> URL {
        let endpointURL: URL

        if endpoint == "" {
            endpointURL = baseURL
        } else {
            if endpoint.contains("?") {
                raiseRuntimeWarning(
                    """
                    Are you passing an endpoint with already a query item?
                    The endpoint will be url encoded and characters like `?` will be encoded as well, possibly resulting
                    in a bad URL.
                    Please, use the `queryItems` parameter in each method available in `NetworkClient` to add query items at
                    the end of the URL.
                    """
                )
            }
            endpointURL = baseURL.appending(path: endpoint)
        }
        return queryItems.isEmpty ? endpointURL : endpointURL.appending(queryItems: queryItems)
    }

    func encodeBody(_ request: (any Request)?) throws -> Data? {
        try request.map { body in
            guard let data = try? JSONEncoder().encode(body)
            else { throw NetworkError.notEncodableData }
            return data
        }
    }
}
