import Foundation

/// An executor of an `HTTPRequest` that manipulates the input data to build a `URLRequest`.
protocol NetworkRequestExecutorProtocol {

    /// The interface to the network.
    var networkInterfaced: NetworkInterfaced { get }

    /// Sends the given `HTTPRequest` and gives back an `HTTPResponse`.
    ///
    /// - Parameter request: The request to be sent
    ///
    /// - Returns: The response from `NetworkInterfaced`
    ///
    /// - Throws: Every `Error` thrown by `URLSession` wrapped into a `NetworkError`.
    func perform(request: HTTPRequest) async throws -> HTTPResponse
}

struct NetworkRequestExecutor: NetworkRequestExecutorProtocol {
    let networkInterfaced: NetworkInterfaced = URLSession.shared

    func perform(request: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }

        do {
            return try await networkInterfaced.send(data: request.body, urlRequest: urlRequest)
        } catch {
            throw NetworkError.urlSession(error: error)
        }
    }
}
