import Foundation

/// Entity mocking the behavior of `NetworkRequestExecutor`.
struct NetworkRequestExecutorMock: NetworkRequestExecutorProtocol {
    private let sleepDuration: Duration
    let networkInterfaced: NetworkInterfaced

    /// Initializer that creates the mock instance of `NetworkInterfaced` and provides a sleeping mechanism.
    ///
    /// - Parameter response: The expected response
    /// - Parameter responseURL: Used to build the mock instance of `NetworkInterfaced`.
    /// - Parameter expectedStatusCode: The expected status code
    /// - Parameter respondsAfter: The sleeping amount of time the perform(request:) method will sleep before sending
    /// the request.
    init(response: Result<Data, NetworkError>, responseURL: URL, expectedStatusCode: Int, respondsAfter sleepDuration: Duration) {
        self.sleepDuration = sleepDuration
        networkInterfaced = URLSessionMock(
            response: response,
            responseURL: responseURL,
            expectedStatusCode: expectedStatusCode
        )
    }

    /// Performs a request after sleeping for the specified amount of time given to the `init`.
    ///
    /// - Parameter request: The request to send
    ///
    /// - Returns: The response given to the `init`
    ///
    /// - Throws: Every error thrown by the `send(data:urlRequest)` of `NetworkInterfaced`.
    func perform(request: HTTPRequest) async throws -> HTTPResponse {
        try await Task.sleep(for: sleepDuration)
        return try await networkInterfaced.send(data: request.body, urlRequest: .init(url: request.url))
    }
}
