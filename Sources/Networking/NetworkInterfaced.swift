import Foundation

/// Entity providing an interface to the network.
public protocol NetworkInterfaced {

    /// Sends the given `HTTPRequest` and gives back a `HTTPResponse`.
    /// The live implementation of this protocol wraps the `upload(for:from:)` method of `URLSession`.
    ///
    /// - Parameter request: The HTTP request to send
    ///
    /// - Returns: A `HTTPResponse` entity
    ///
    /// - Throws: Every error thrown by the `upload(for:from:)` method of `URLSession`.
    func send(request: HTTPRequest) async throws -> HTTPResponse
}

extension URLSession: NetworkInterfaced {
    public func send(request: HTTPRequest) async throws -> HTTPResponse {
        do {
            let (data, response) = try await upload(for: request.urlRequest, from: request.body ?? .init())
            return .init(body: data, urlResponse: response)
        } catch {
            throw NetworkError.urlSession(description: error.localizedDescription)
        }
    }
}

extension HTTPRequest {
    fileprivate var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        return urlRequest
    }
}
