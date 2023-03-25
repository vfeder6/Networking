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
    public static func mock<Response: DTO>(
        returning result: Result<Response, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Duration = .zero
    ) throws -> Self {
        let url = URL(string: "https://example.com")!

        return .init(networkInterfaced: URLSessionMock(
            response: result.successData,
            responseURL: url,
            expectedStatusCode: statusCode,
            respondsAfter: sleepDuration
        ), baseURL: url, baseHeaders: [:])
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
