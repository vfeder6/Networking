import Foundation

extension NetworkClientProtocol {

    /// Creates a mocked instance of NetworkClient.
    ///
    /// - Parameter result: The desired response
    /// - Parameter statusCode: The desired status code
    /// - Parameter sleepDuration: The amount of time the current Task has to sleep before returning the mocked data,
    /// simulating a delay from the server
    ///
    /// - Returns: The mocked NetworkClient instance.
    ///
    /// - Throws: The error passed in `result`, if it's `.failure`.
    public static func mock(
        returning result: Result<R, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Duration = .zero
    ) throws -> Self {
        .init(networkInterfaced: URLSessionMock(
            response: result.map { _ in () },
            expectedStatusCode: statusCode,
            respondsAfter: sleepDuration
        ), baseURL: .init(string: "https://example.com")!, baseHeaders: [:]) { data in
            if case .success(let success) = result {
                return success
            } else {
                throw NetworkMockError.boh
            }
        }
    }
}

enum NetworkMockError: Error {
    case boh
}
