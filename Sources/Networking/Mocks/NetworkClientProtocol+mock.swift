import Foundation

extension NetworkClient {

    /// Creates a mocked instance of a `NetworkClient` type.
    ///
    /// - Parameter result: The desired response
    /// - Parameter statusCode: The desired status code
    /// - Parameter sleepDuration: The amount of time the current `Task` has to sleep before returning the mocked data,
    /// simulating a delay from the server
    ///
    /// - Returns: The mocked `NetworkClient` instance.
    public static func mock(
        returning result: Result<R, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Duration = .zero
    ) -> Self {
        .init(
            networkInterfaced: URLSessionMock(
                response: result.map { _ in () },
                expectedStatusCode: statusCode,
                respondsAfter: sleepDuration
            ),
            baseURL: .init(string: "https://example.com")!,
            baseHeaders: [:],
            decoder: MockDataDecoder()
        )
    }
}

enum NetworkMockError: Error {
    case decodeExpression
}
