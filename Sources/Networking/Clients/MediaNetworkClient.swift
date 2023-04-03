import Foundation
import SwiftUI

public struct MediaNetworkClient<M: Media>: NetworkClient {
    public let networkInterfaced: NetworkInterfaced
    public let baseURL: URL
    public let baseHeaders: [String : String]
    public let decode: (Data) throws -> M

    public init(
        networkInterfaced: NetworkInterfaced,
        baseURL: URL,
        baseHeaders: [String : String],
        decode: ((Data) throws -> R)? = nil
    ) {
        self.networkInterfaced = networkInterfaced
        self.baseURL = baseURL
        self.baseHeaders = baseHeaders
        self.decode = decode ?? { try R.decode(from: $0) }
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

        guard let decoded = try? decode(response.body)
        else { throw NetworkError.notDecodableData(response.body) }
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
        .init(networkInterfaced: URLSession.shared, baseURL: baseURL, baseHeaders: baseHeaders)
    }
}

public enum DecodingStrategy {
    case json
    case media
}
