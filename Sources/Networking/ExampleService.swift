struct ExampleService {
    let networkService: NetworkClientProtocol = NetworkClient(host: .init(string: "https://example.com")!, baseHeaders: [:])

    func someServiceMethod() async throws -> ExampleResponse {
        let response = try await networkService.performRequest(
            to: "/someServiceMethod",
            with: [],
            body: nil,
            method: .post,
            additionalHeaders: [:],
            expect: 201,
            decodeTo: ExampleResponse.self
        )
        return response.body!
    }
}

struct ExampleResponse: Decodable {

}
