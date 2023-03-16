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
