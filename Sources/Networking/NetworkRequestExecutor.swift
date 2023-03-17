import Foundation

public protocol NetworkRequestExecutorProtocol {
    var networkInterfaced: NetworkInterfaced { get }

    func perform(request: HTTPRequest) async throws -> HTTPResponse
}

struct NetworkRequestExecutor: NetworkRequestExecutorProtocol {
    let networkInterfaced: NetworkInterfaced = URLSession.shared

    func perform(request: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        request.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        return try await networkInterfaced.send(data: request.body, urlRequest: urlRequest)
    }
}

struct NetworkRequestExecutorMock: NetworkRequestExecutorProtocol {
    private let url: URL
    let networkInterfaced: NetworkInterfaced

    init(response: Result<Data, NetworkError>, responseURL: URL, mimeType: String?, expectedContentLenght: Int, textEncodingName: String?) {
        self.url = responseURL
        networkInterfaced = URLSessionMock(
            response: response,
            responseURL: responseURL,
            mimeType: mimeType,
            expectedContentLength: expectedContentLenght,
            textEncodingName: textEncodingName
        )
    }

    func perform(request: HTTPRequest) async throws -> HTTPResponse {
        try await networkInterfaced.send(data: request.body, urlRequest: .init(url: url))
    }
}
