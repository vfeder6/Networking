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
    @available(macOS 13.0, iOS 16.0, *)
    static func mock<Response: DTO>(
        returning result: Result<Response, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Duration = .zero
    ) -> Self {
        .init(
            networkInterfaced: URLSessionMock(
                response: result.discarded,
                expectedStatusCode: statusCode,
                respondsAfter: sleepDuration
            ),
            baseURL: .init(string: "https://example.com")!,
            baseHeaders: [:],
            decoder: MockDataDecoder(model: result.discarded),
            logger: Logger()
        )
    }

    /// Creates a mocked instance of a `NetworkClient` type.
    ///
    /// - Parameter result: The desired response
    /// - Parameter statusCode: The desired status code
    /// - Parameter sleepDuration: The amount of time the current `Task` has to sleep before returning the mocked data,
    /// simulating a delay from the server
    ///
    /// - Returns: The mocked `NetworkClient` instance.
    @available(iOS, deprecated: 16.0, renamed: "mock")
    @available(macOS, deprecated: 13.0, renamed: "mock")
    static func legacyMock<Response: DTO>(
        returning result: Result<Response, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Double = .zero
    ) throws -> Self {
        .init(networkInterfaced: LegacyURLSessionMock(
            response: result.discarded,
            expectedStatusCode: statusCode,
            respondsAfter: sleepDuration
        ), baseURL: .init(string: "https://example.com")!, baseHeaders: [:])
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
