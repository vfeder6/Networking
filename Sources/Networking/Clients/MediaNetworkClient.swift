import Foundation
import SwiftUI

public struct MediaNetworkClient<M: Media>: NetworkClientProtocol {
    public let networkInterfaced: NetworkInterfaced
    public let baseURL: URL
    public let baseHeaders: [String : String]
    public let decodeExpression: (Data) throws -> M

    public init(
        networkInterfaced: NetworkInterfaced,
        baseURL: URL,
        baseHeaders: [String : String],
        decodeExpression: @escaping (Data) throws -> M
    ) {
        self.networkInterfaced = networkInterfaced
        self.baseURL = baseURL
        self.baseHeaders = baseHeaders
        self.decodeExpression = decodeExpression
    }

    public func performRequest(
        to endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: [String : String],
        expectedStatusCode: Int
    ) async throws -> NetworkResponse<M> {
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

extension MediaNetworkClient {
    public func process(
        response: HTTPResponse,
        expectedStatusCode: Int
    ) throws -> NetworkResponse<M> {
        guard let urlResponse = response.urlResponse as? HTTPURLResponse
        else { throw NetworkError.badURLResponse }

        guard urlResponse.statusCode == expectedStatusCode
        else { throw NetworkError.mismatchingStatusCodes(expected: expectedStatusCode, actual: urlResponse.statusCode) }

        guard let headers = urlResponse.allHeaderFields as? [String : String]
        else { throw NetworkError.notParseableHeaders }

        guard let decoded = try? decodeExpression(response.body)
        else { throw NetworkError.notDecodableMedia }
        return .init(headers: headers, body: decoded, url: urlResponse.url)
    }
}

// MARK: - Instance

extension MediaNetworkClient {

    /// Creates a live instance of `NetworkClient`.
    ///
    /// - Parameter baseURL: The base URL
    /// - Parameter baseHeaders: The base headers
    ///
    /// - Returns: The live instance of `NetworkClient`.
    public static func live(baseURL: URL, baseHeaders: [String : String] = [:]) -> Self {
        .init(networkInterfaced: URLSession.shared, baseURL: baseURL, baseHeaders: baseHeaders) { data in
            try M.decode(from: data)
        }
    }
}
