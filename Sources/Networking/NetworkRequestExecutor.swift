import Foundation

protocol NetworkRequestExecutorProtocol {
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
    let sleepDuration: Duration

    init(response: Result<Data, NetworkError>, responseURL: URL, expectedStatusCode: Int, respondsAfter sleepDuration: Duration) {
        self.url = responseURL
        self.sleepDuration = sleepDuration
        networkInterfaced = URLSessionMock(
            response: response,
            responseURL: responseURL,
            expectedStatusCode: expectedStatusCode
        )
    }

    func perform(request: HTTPRequest) async throws -> HTTPResponse {
        try await Task.sleep(for: sleepDuration)
        return try await networkInterfaced.send(data: request.body, urlRequest: .init(url: url))
    }
}
