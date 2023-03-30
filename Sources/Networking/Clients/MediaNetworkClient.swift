import Foundation
import SwiftUI

public struct MediaNetworkClient<R: Media>: NetworkClientProtocol {
    public let networkInterfaced: NetworkInterfaced
    public let baseURL: URL
    public let baseHeaders: [String : String]

    public init(networkInterfaced: NetworkInterfaced, baseURL: URL, baseHeaders: [String : String]) {
        self.networkInterfaced = networkInterfaced
        self.baseURL = baseURL
        self.baseHeaders = baseHeaders
    }

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

extension MediaNetworkClient {
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

        guard let decoded = R.generate(from: response.body)
        else { throw NetworkError.notDecodableMedia }
        return .init(headers: headers, body: decoded, url: urlResponse.url)
    }
}
