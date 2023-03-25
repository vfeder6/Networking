import Foundation

/// Entity providing a raw interface to the network.
protocol NetworkInterfaced {

    /// Sends the given `Data` (if not `nil`) for a request.
    /// The live implementation of this protocol wraps the `upload(for:from:)` method of `URLSession`.
    ///
    /// - Parameter data: The body data to send
    /// - Parameter urlRequest: The request to be uploaded.
    ///
    /// - Returns: An `HTTPResponse` entity.
    ///
    /// This method is called by `NetworkRequestExecutor` to build a `URLRequest` from a `HTTPRequest`.
    ///
    /// - Throws: Every error thrown by the `upload(for:from:)` method of `URLSession`.
    func send(data: Data?, urlRequest: URLRequest) async throws -> HTTPResponse
}

extension URLSession: NetworkInterfaced {
    func send(data: Data?, urlRequest: URLRequest) async throws -> HTTPResponse {
        let (data, response) = try await upload(for: urlRequest, from: data ?? .init())
        return .init(body: data, urlResponse: response)
    }
}
