import Foundation

/// Entity that processes input and output data for network requests.
public struct NetworkClient<ResponseType: Equatable> {

    private let networkInterfaced: NetworkInterfaced
    private let baseURL: URL
    private let baseHeaders: Headers
    private let decoder: DataDecoder
    private let logger: Logger?

    /// Initializes an instance with a base URL and base headers.
    ///
    /// - Parameter networkInterfaced: Entity responsible of performing the network request.
    /// - Parameter baseURL: The starting base URL
    /// - Parameter baseHeaders: The starting base headers
    /// - Parameter decoder: Entity used to decode the response received from the server
    /// - Parameter logger: The logger to use
    init(
        networkInterfaced: NetworkInterfaced,
        baseURL: URL,
        baseHeaders: Headers,
        decoder: DataDecoder,
        logger: Logger? = nil
    ) {
        self.networkInterfaced = networkInterfaced
        self.baseURL = baseURL
        self.baseHeaders = baseHeaders
        self.decoder = decoder
        self.logger = logger
    }
}

// MARK: - Public API, main method

public extension NetworkClient {

    /// Performs a network request.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Request` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    ///
    /// - Returns: A `NetworkResponse` entity.
    ///
    /// - Throws: A `NetworkError`.
    func performRequest(
        to endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: Headers,
        expectedStatusCode: Int
    ) async throws -> NetworkResponse<ResponseType> {
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

// MARK: - Public API, auxiliary methods

public extension NetworkClient {

    /// Performs a network request, safely returning the full response from the server.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Request` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    ///
    /// - Returns: A `Result` containing a `NetworkResponse` entity or `NetworkError`.
    func fullResponseResult(
        from endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: Headers,
        expectedStatusCode: Int
    ) async -> Result<NetworkResponse<ResponseType>, NetworkError> {
        do {
            return .success(try await performRequest(
                to: endpoint,
                queryItems: queryItems,
                body: body,
                method: method,
                additionalHeaders: additionalHeaders,
                expectedStatusCode: expectedStatusCode
            ))
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            logger?.raiseRuntimeWarning(
                """
                Error returned from the server is not a `NetworkError`.
                Please, raise an issue here: https://github.com/vfeder6/Networking/issues
                containing all the possible needed information to reproduce this bug.
                """
            )
            return .failure(._unknown)
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
    ///
    /// - Returns: A `Result` containing the `Response` entity or `NetworkError`.
    func responseResult(
        from endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: Headers,
        expectedStatusCode: Int
    ) async -> Result<ResponseType, NetworkError> {
        let result = await fullResponseResult(
            from: endpoint,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expectedStatusCode: expectedStatusCode
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

    /// Performs a network request, returning the error if present.
    ///
    /// The body decoding is ignored only if the declared `ResponseType` is of type `EmptyModel`.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Encodable` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    ///
    /// - Returns: A `Result` containing `Void` if success, or `NetworkError`.
    func emptyResult(
        to endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: Headers,
        expectedStatusCode: Int
    ) async -> Result<Void, NetworkError> {
        let result = await fullResponseResult(
            from: endpoint,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expectedStatusCode: expectedStatusCode
        )

        switch result {
        case .success:
            return .success(())
        case .failure(let networkError):
            return .failure(networkError)
        }
    }
}

// MARK: - Request data processing

private extension NetworkClient {

    /// Creates the new headers adding to `baseHeaders` some additional ones.
    ///
    /// - Parameter additionalHeaders: Headers to add to `baseHeaders`
    ///
    /// - Returns: The new headers.
    func composeHeaders(_ additionalHeaders: Headers) -> Headers {
        baseHeaders + additionalHeaders
    }

    /// Composes the url, starting from the `baseURL` and concatenating the `endpoint` and the `queryItems`
    ///
    /// - Parameter endpoint: The endpoint to add
    /// - Parameter queryItesms: Query items to append at the end of the `URL`
    ///
    /// - Returns: The new `URL`
    func composeURL(_ endpoint: String, queryItems: [URLQueryItem]) -> URL {
        let endpointURL: URL

        if endpoint == "" {
            endpointURL = baseURL
        } else {
            if endpoint.contains("?") {
                logger?.raiseRuntimeWarning(
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

    /// Encodes the body using JavaScript Object Notation as encoding strategy.
    ///
    /// - Parameter request: The `Encodable` model to encode
    ///
    /// - Returns: The encoded `Data`
    ///
    /// - Throws: A `NetworkError` type
    func encodeBody(_ request: (any Request)?) throws -> Data? {
        try request.map { body in
            guard let data = try? JSONEncoder().encode(body)
            else { throw NetworkError.notEncodableData }
            return data
        }
    }
}

// MARK: - Response data processing

private extension NetworkClient {

    /// Processes the raw response obtained from the server.
    ///
    /// - Parameter response: The raw response
    /// - Parameter expectedStatusCode: The expected status code from the server.
    ///
    /// - Returns: A `NetworkResponse` type
    ///
    /// - Throws: A `NetworkError` type
    func process(
        response: HTTPResponse,
        expectedStatusCode: Int
    ) throws -> NetworkResponse<ResponseType> {
        guard let urlResponse = response.urlResponse as? HTTPURLResponse
        else { throw NetworkError.badURLResponse }

        guard urlResponse.statusCode == expectedStatusCode
        else { throw NetworkError.mismatchingStatusCodes(expected: expectedStatusCode, actual: urlResponse.statusCode) }

        guard let headers = urlResponse.allHeaderFields as? Headers
        else { throw NetworkError.notParseableHeaders }

        guard ResponseType.Type.self != EmptyDTO.self
        else { return .init(headers: headers, body: nil, url: urlResponse.url) }

        guard let decoded = try? decoder.decode(ResponseType.self, from: response.body)
        else { throw NetworkError.notDecodableData(response.body) }

        return .init(headers: headers, body: decoded, url: urlResponse.url)
    }
}

// MARK: - Instances

public extension NetworkClient {

    /// Creates a live instance of `NetworkClient` using JavaScript Object Notation as the body decoding strategy.
    ///
    /// - Parameter baseURL: The base URL
    /// - Parameter baseHeaders: The base headers
    ///
    /// - Returns: A live instance of `NetworkClient`.
    static func json(baseURL: URL, baseHeaders: Headers = [:]) -> Self {
        .init(networkInterfaced: URLSession.shared, baseURL: baseURL, baseHeaders: baseHeaders, decoder: JSONDataDecoder())
    }

    /// Creates a live instance of `NetworkClient` assuming that the body is a `Media`-compatible type.
    ///
    /// - Parameter baseURL: The base URL
    /// - Parameter baseHeaders: The base headers
    ///
    /// - Returns: A live instance of `NetworkClient`.
    static func media(baseURL: URL, baseHeaders: Headers = [:]) -> Self {
        .init(networkInterfaced: URLSession.shared, baseURL: baseURL, baseHeaders: baseHeaders, decoder: MediaDataDecoder())
    }
}
