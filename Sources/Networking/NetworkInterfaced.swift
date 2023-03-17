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
    private let mimeType: String?
    private let expectedContentLength: Int
    private let textEncodingName: String?

    init(
        response: Result<Data, NetworkError>,
        responseURL: URL,
        mimeType: String?,
        expectedContentLength: Int,
        textEncodingName: String?
    ) {
        self.response = response
        self.responseURL = responseURL
        self.mimeType = mimeType
        self.expectedContentLength = expectedContentLength
        self.textEncodingName = textEncodingName
    }

    public func send(data: Data?, urlRequest: URLRequest) async throws -> HTTPResponse {
        switch response {
        case .success(let responseData):
            return .init(body: responseData, urlResponse: .init(
                url: responseURL,
                mimeType: mimeType,
                expectedContentLength: expectedContentLength,
                textEncodingName: textEncodingName
            ))

        case .failure(let error):
            throw error
        }
    }
}
