import Foundation

/// A client that processes input and output data for network requests.
public struct NetworkClient<R: Response>: NetworkClientProtocol {
    public let networkInterfaced: NetworkInterfaced
    public let host: URL
    public let baseHeaders: [String : String]

    /// Initializes an instance with a base URL and base headers.
    ///
    /// - Parameter networkInterfaced: The entity responsible of performing the network request.
    /// - Parameter baseURL: The starting base URL
    /// - Parameter baseHeaders: The starting base headers
    init(networkInterfaced: NetworkInterfaced, baseURL: URL, baseHeaders: [String : String]) {
        self.networkInterfaced = networkInterfaced
        self.host = baseURL
        self.baseHeaders = baseHeaders
    }
}

// MARK: - Public API, auxiliary methods

extension NetworkClient {

    /// Performs a network request, safely returning the full response from the server.
    ///
    /// - Parameter endpoint: The endpoint to append to `baseURL`
    /// - Parameter queryItems: The query items to append at the end of the URL
    /// - Parameter body: The `Request` entity used to generate a JSON body
    /// - Parameter method: The HTTP method to use
    /// - Parameter additionalHeaders: Headers to append to `baseHeaders`
    /// - Parameter expectedStatusCode: The expected response status code
    /// - Parameter type: The `Decodable` type expected in the response body
    ///
    /// - Returns: A `Result` containing a `NetworkResponse` entity or `NetworkError`.
    public func fullResponseResult(
        from endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: [String : String],
        expectedStatusCode: Int
    ) async -> Result<NetworkResponse<R>, NetworkError> {
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
            raiseRuntimeWarning(
                """
                Error returned from the server is not a `NetworkError`.
                Please, raise an issue here: https://github.com/vfeder6/Networking/issues
                containing all the possible needed information to reproduce this bug.
                """)
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
    /// - Parameter type: The `Decodable` type expected in the response body
    ///
    /// - Returns: A `Result` containing the `Response` entity or `NetworkError`.
    public func responseResult(
        from endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: [String : String],
        expectedStatusCode: Int
    ) async -> Result<R, NetworkError> {
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

    /// Performs a network request, safely returning the error if present.
    /// The body decoding is ignored only if `Response` is of type `EmptyModel`.
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
        with queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: [String : String],
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

// MARK: - Response data processing

extension NetworkClient {
    public func process(
        response: HTTPResponse,
        expectedStatusCode: Int
    ) throws -> NetworkResponse<R> {
        guard let urlResponse = response.urlResponse as? HTTPURLResponse
        else { throw NetworkError.badURLResponse }

        guard urlResponse.statusCode == expectedStatusCode
        else { throw NetworkError.mismatchingStatusCodes(expected: expectedStatusCode, actual: urlResponse.statusCode) }

        guard let headers = urlResponse.allHeaderFields as? [String : String]
        else { throw NetworkError.notParseableHeaders }

        if R.Type.self == EmptyDTO.self {
            return .init(headers: headers, body: nil, url: urlResponse.url)
        }

        guard let decoded = try? JSONDecoder().decode(R.self, from: response.body) else {
            throw NetworkError.notDecodableData(
                model: R.self,
                json: response.body.prettyPrintedJSON
            )
        }
        return .init(headers: headers, body: decoded, url: urlResponse.url)
    }
}

// MARK: - Instance

extension NetworkClient {

    /// Creates a live instance of `NetworkClient`.
    ///
    /// - Parameter baseURL: The base URL
    /// - Parameter baseHeaders: The base headers
    ///
    /// - Returns: The live instance of `NetworkClient`.
    public static func live(baseURL: URL, baseHeaders: [String : String] = [:]) -> NetworkClient {
        .init(networkInterfaced: URLSession.shared, baseURL: baseURL, baseHeaders: baseHeaders)
    }
}
