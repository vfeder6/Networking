import Foundation

/// Entity that processes input and output data for network requests, using JavaScript Object Notation (JSON) as data
/// encoding strategy.
public struct JSONNetworkClient<R: Response>: NetworkClient {
    public let networkInterfaced: NetworkInterfaced
    public let baseURL: URL
    public let baseHeaders: [String : String]
    public let decode: (Data) throws -> R

    public init(
        networkInterfaced: NetworkInterfaced,
        baseURL: URL,
        baseHeaders: [String : String],
        decode: ((Data) throws -> R)? = nil
    ) {
        self.networkInterfaced = networkInterfaced
        self.baseURL = baseURL
        self.baseHeaders = baseHeaders
        self.decode = decode ?? { try JSONDecoder().decode(R.self, from: $0) }
    }
}

// MARK: - Public API, auxiliary methods

extension JSONNetworkClient {

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

extension JSONNetworkClient {
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

        guard R.Type.self != EmptyDTO.self
        else { return .init(headers: headers, body: nil, url: urlResponse.url) }

        guard let decoded = try? decode(response.body)
        else { throw NetworkError.notDecodableData(response.body) }

        return .init(headers: headers, body: decoded, url: urlResponse.url)
    }
}

// MARK: - Instance

extension JSONNetworkClient {

    /// Creates a live instance of `JSONNetworkClient`.
    ///
    /// - Parameter baseURL: The base URL
    /// - Parameter baseHeaders: The base headers
    ///
    /// - Returns: The live instance of `JSONNetworkClient`.
    public static func live(baseURL: URL, baseHeaders: [String : String] = [:]) -> Self {
        .init(networkInterfaced: URLSession.shared, baseURL: baseURL, baseHeaders: baseHeaders)
    }
}
