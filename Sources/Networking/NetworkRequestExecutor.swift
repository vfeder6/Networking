import Foundation

public protocol NetworkRequestExecutorProtocol {
    var networkInterfaced: NetworkInterfaced { get }

    func perform(request: HTTPRequest) async throws -> HTTPResponse
}

final class NetworkRequestExecutor: NetworkRequestExecutorProtocol {
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
