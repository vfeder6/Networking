import Foundation

public extension NetworkClient {

    /// Creates a mocked instance of a `NetworkClient` type.
    ///
    /// - Parameter result: The desired response
    /// - Parameter statusCode: The desired status code
    /// - Parameter sleepDuration: The amount of time the current `Task` has to sleep before returning the mocked data,
    /// simulating a delay from the server
    ///
    /// - Returns: The mocked `NetworkClient` instance.
    static func mock(
        returning result: Result<ResponseType, NetworkError>,
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
            decoder: MockDataDecoder(model: result.discarded),
            logger: Logger()
        )
    }
}

private extension Result {

    var discarded: Any {
        switch self {
        case .success(let success):
            return success
        case .failure(let failure):
            return failure
        }
    }
}
