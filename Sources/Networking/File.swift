import Foundation

protocol ExampleHTTPServiceProtocol {
    var networkService: NetworkServiceProtocol { get }
    var host: URL { get }

    init(host: URL)
}

struct ExampleHTTPService: ExampleHTTPServiceProtocol {
    let networkService: NetworkServiceProtocol = NetworkService()

    var host: URL

    init(host: URL) {
        self.host = host
    }

    func performRequest<Response: Decodable>(
        to endpoint: String,
        body: (any Encodable)?,
        method: HTTPMethod,
        headers: [String: String],
        expect statusCode: Int,
        decodeTo type: Response.Type?
    ) async throws -> Response? {
        let url = host.appen

        return try await networkService.performRequest(
            to: url,
            body: body,
            method: method,
            headers: headers,
            expect: statusCode,
            decodeTo: type
        )
    }
}
