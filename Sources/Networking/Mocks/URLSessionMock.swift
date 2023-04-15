import Foundation

/// Entity that simulates the `URLSession` behavior.
struct URLSessionMock: NetworkInterfaced {

    private let response: Result<Void, NetworkError>
    private let expectedStatusCode: Int
    private var sleepDuration: Duration

    /// Initializer allowing to mock the response that `URLSession` gives back.
    ///
    /// - Parameter response: The expected result of the operation
    /// - Parameter expectedStatusCode: The expected status code to give to `HTTPURLResponse`
    /// - Parameter sleepDuration: The delay in which the `send(request:)` method will return
    init(
        response: Result<Void, NetworkError>,
        expectedStatusCode: Int,
        respondsAfter sleepDuration: Duration
    ) {
        self.response = response
        self.expectedStatusCode = expectedStatusCode
        self.sleepDuration = sleepDuration
    }

    /// This method returns an `HTTPResponse` or throws error based on what `response` has been passed to the `init`.
    ///
    /// Before actually returning or throwing error, this method will hang on the current Task for the duration
    /// specified in the initializer.
    /// The returned `HTTPResponse` contains an empty body `Data` to ignore decoding during tests.
    func send(request: HTTPRequest) async throws -> HTTPResponse {
        try await Task.sleep(for: sleepDuration)

        switch response {
        case .success:
            return .init(body: .init(), urlResponse: HTTPURLResponse(
                url: request.url,
                statusCode: expectedStatusCode,
                httpVersion: nil,
                headerFields: nil
            )!)

        case .failure(let error):
            throw error
        }
    }
}
