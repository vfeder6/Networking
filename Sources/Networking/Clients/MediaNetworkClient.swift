import Foundation
import SwiftUI

public struct MediaNetworkClient: NetworkClientProtocol {
    public let networkInterfaced: NetworkInterfaced
    public let host: URL
    public let baseHeaders: [String : String]

    public func performRequest(
        to endpoint: String,
        queryItems: [URLQueryItem],
        body: (any Request)?,
        method: HTTPMethod,
        additionalHeaders: [String : String],
        expectedStatusCode: Int
    ) async throws -> NetworkResponse<Image> {
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
    ) throws -> NetworkResponse<Image> {
        guard let urlResponse = response.urlResponse as? HTTPURLResponse
        else { throw NetworkError.badURLResponse }

        guard urlResponse.statusCode == expectedStatusCode
        else { throw NetworkError.mismatchingStatusCodes(expected: expectedStatusCode, actual: urlResponse.statusCode) }

        guard let headers = urlResponse.allHeaderFields as? [String : String]
        else { throw NetworkError.notParseableHeaders }

        guard let decoded = Image(from: response.body)
        else { throw NetworkError.notDecodableImage }
        return .init(headers: headers, body: decoded, url: urlResponse.url)
    }
}

extension Image {
    public init?(from data: Data) {
        #if canImport(UIKit)
            guard let uiImage = UIImage(data: data)
            else { return nil}
            self.init(uiImage: uiImage)
        #elseif canImport(AppKit)
            guard let nsImage = NSImage(data: data)
            else { return nil }
            self.init(nsImage: nsImage)
        #else
            return nil
        #endif
    }
}
