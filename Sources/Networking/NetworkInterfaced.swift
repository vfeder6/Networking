import Foundation

public protocol NetworkInterfaced {
    func send(data: Data?, urlRequest: URLRequest) async throws -> HTTPResponse
}

extension URLSession: NetworkInterfaced {
    public func send(data: Data?, urlRequest: URLRequest) async throws -> HTTPResponse {
        let (data, response) = try await upload(for: urlRequest, from: data ?? .init())
        return .init(body: data, urlResponse: response)
    }
}

public final class URLSessionMock: NetworkInterfaced {
    private let response: Result<Data, NetworkError>
    private let responseURL: URL
    private let expectedStatusCode: Int

    init(
        response: Result<Data, NetworkError>,
        responseURL: URL,
        expectedStatusCode: Int
    ) {
        self.response = response
        self.responseURL = responseURL
        self.expectedStatusCode = expectedStatusCode
    }

    public func send(data: Data?, urlRequest: URLRequest) async throws -> HTTPResponse {
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
