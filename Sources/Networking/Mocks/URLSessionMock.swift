import Foundation

/// Entity used to simulate the `URLSession` behavior.
struct URLSessionMock: NetworkInterfaced {
    private let response: Result<Data, NetworkError>
    private let responseURL: URL
    private let expectedStatusCode: Int

    /// Initializer allowing to mock the response that `URLSession` gives back.
    ///
    /// - Parameter response: The expected response
    /// - Parameter responseURL: Used only to build the mandatory HTTPURLResponse object coming from the
    /// method `upload(for:from:)` of `URLSession`
    /// - Parameter expectedStatusCode: The expected status code to give to `HTTPURLResponse`
    init(
        response: Result<Data, NetworkError>,
        responseURL: URL,
        expectedStatusCode: Int
    ) {
        self.response = response
        self.responseURL = responseURL
        self.expectedStatusCode = expectedStatusCode
    }

    /// This method ignores its input parameters and returns an `HTTPResponse` or throws error based on
    /// what `response` has been passed to the `init`.
    func send(data: Data?, urlRequest: URLRequest) async throws -> HTTPResponse {
        switch response {
        case .success(let responseData):
            return .init(body: responseData, urlResponse: HTTPURLResponse(
                url: responseURL,
                statusCode: expectedStatusCode,
                httpVersion: nil,
                headerFields: nil
            )!)

        case .failure(let error):
            throw error
        }
    }
}
