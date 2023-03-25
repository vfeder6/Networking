import Foundation

/// A client that processes input and output data for network requests.
public struct NetworkClient<Response: Decodable> {
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
}

// MARK: - Public API, main method

extension NetworkClient {

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
    public func performRequest(
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

// MARK: - Public API, auxiliary methods

extension NetworkClient {

    /// Performs a network request, safely returning the full response from the server.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Encodable` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    /// - Parameter type: The `Decodable` type expected in the response body
    ///
    /// - Returns: A `Result` containing a `NetworkResponse` entity or `NetworkError`.
    public func fullResponseResult(
        from endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expectedStatusCode: Int = 200,
        decode type: Response.Type
    ) async -> Result<NetworkResponse<Response>, NetworkError> {
        do {
            return .success(try await performRequest(
                to: endpoint.prependingSlashIfNotPresent,
                queryItems: queryItems,
                body: body,
                method: method,
                additionalHeaders: additionalHeaders,
                expectedStatusCode: expectedStatusCode,
                decode: type
            ))
        } catch {
            return .failure(error as? NetworkError ?? .unknown)
        }
    }

    /// Performs a network request, safely returning the response body from the server.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Encodable` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    /// - Parameter type: The `Decodable` type expected in the response body
    ///
    /// - Returns: A `Result` containing the `Response` entity or `NetworkError`.
    public func responseResult(
        from endpoint: String,
        queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expectedStatusCode: Int = 200,
        decode type: Response.Type
    ) async -> Result<Response, NetworkError> {
        let result = await fullResponseResult(
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

    /// Performs a network request, safely returning the error if present.
    /// The body decoding is ignored.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Encodable` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    ///
    /// - Returns: A `Result` containing `Void` or `NetworkError`.
    public func result(
        to endpoint: String,
        with queryItems: [URLQueryItem] = [],
        body: Encodable? = nil,
        method: HTTPMethod = .get,
        additionalHeaders: [String: String] = [:],
        expectedStatusCode: Int = 200
    ) async -> Result<Void, NetworkError> {
        let result = await fullResponseResult(
            from: endpoint.prependingSlashIfNotPresent,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expectedStatusCode: expectedStatusCode,
            decode: Empty.self as! Response.Type
        )

        switch result {
        case .success:
            return .success(())
        case .failure(let networkError):
            return .failure(networkError)
        }
    }
}

private extension String {
    var prependingSlashIfNotPresent: Self {
        starts(with: "/") ? self : "/\(self)"
    }
}

// MARK: - Data processing

extension NetworkClient {
    private func process(
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
