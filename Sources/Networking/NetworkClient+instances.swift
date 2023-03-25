import Foundation

extension NetworkClient {
    public static func live(host: URL, baseHeaders: [String: String] = [:]) -> NetworkClient {
        .init(requestExecutor: NetworkRequestExecutor(), baseURL: host, baseHeaders: baseHeaders)
    }

    public static func mock<Response: Codable>(
        returning result: Result<Response, NetworkError>,
        expecting statusCode: Int,
        after sleepDuration: Duration = .zero
    ) throws -> NetworkClient {
        let url = URL(string: "https://example.com")!

        return .init(requestExecutor: NetworkRequestExecutorMock(
            response: result.successData,
            responseURL: url,
            expectedStatusCode: statusCode,
            respondsAfter: sleepDuration
        ), baseURL: url, baseHeaders: [:])
    }
}

private extension Result where Success: Codable {
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
