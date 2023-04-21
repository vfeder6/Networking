import Foundation

extension NetworkClient {

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
    @available(macOS 13.0, iOS 16.0, *)
    public static func mock<Response: DTO>(
        returning result: Result<Response, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Duration = .zero
    ) throws -> Self {
        .init(networkInterfaced: URLSessionMock(
            response: result.successData,
            expectedStatusCode: statusCode,
            respondsAfter: sleepDuration
        ), baseURL: .init(string: "https://example.com")!, baseHeaders: [:])
    }

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
    @available(iOS, deprecated: 16, renamed: "mock")
    @available(macOS, deprecated: 13, renamed: "mock")
    public static func legacyMock<Response: DTO>(
        returning result: Result<Response, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Double = .zero
    ) throws -> Self {
        .init(networkInterfaced: LegacyURLSessionMock(
            response: result.successData,
            expectedStatusCode: statusCode,
            respondsAfter: sleepDuration
        ), baseURL: .init(string: "https://example.com")!, baseHeaders: [:])
    }
}

private extension Result where Success: DTO {
    var successData: Result<Data, Failure> {
        switch self {
        case .success(let encodable):
            let successData = try! JSONEncoder().encode(encodable)
            return .success(successData)

        case .failure(let error):
            return .failure(error)
        }
    }
}
