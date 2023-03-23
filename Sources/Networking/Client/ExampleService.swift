import Foundation

protocol ExampleServiceProtocol {
    var networkService: NetworkClient { get }

    func returnsAModel() async -> Result<ExampleResponse, DisplayableError>
    func returnsAnEmptyResponse() async -> Result<Void, DisplayableError>
    func checkOnResponseHeaders() async -> Result<ExampleResponse, DisplayableError>
    func requestWithBody(_ body: ExampleRequest) async -> Result<ExampleResponse, DisplayableError>
    func parameterizedEndpoint(_ parameter: ParameterizedEndpoint) async -> Result<Void, DisplayableError>
    func variableBody(_ parameter: VariableBodyParameter) async -> Result<Void, DisplayableError>
}

struct ExampleService: ExampleServiceProtocol {
    let networkService: NetworkClient = .live(host: .init(string: "https://example.com")!)

    func returnsAModel() async -> Result<ExampleResponse, DisplayableError> {
        await networkService.body(
            from: "/returnsAModel",
            method: .post,
            expect: 201,
            decodeTo: ExampleResponse.self
        ).displayable
    }

    func returnsAnEmptyResponse() async -> Result<Void, DisplayableError> {
        await networkService.emptyBody(
            from: "/returnsAnEmptyResponse",
            method: .get,
            expect: 200
        ).displayable
    }

    func checkOnResponseHeaders() async -> Result<ExampleResponse, DisplayableError> {
        let result = await networkService.response(
            from: "checkOnResponseHeaders",
            method: .get,
            expect: 200,
            decode: ExampleResponse.self
        ).displayable

        switch result {
        case .success(let response):
            if response.headers["SomeHeaderKey"] == "SomeHeaderValue", let body = response.body {
                return .success(body)
            }
            return .failure(.server)

        case .failure(let error):
            return .failure(error)
        }
    }

    func requestWithBody(_ body: ExampleRequest) async -> Result<ExampleResponse, DisplayableError> {
        await networkService.body(
            from: "requestWithBody",
            body: body,
            decodeTo: ExampleResponse.self
        ).displayable
    }

    func parameterizedEndpoint(_ parameter: ParameterizedEndpoint) async -> Result<Void, DisplayableError> {
        await networkService.emptyBody(
            from: "parameterizedEndpoint/\(parameter.rawValue)",
            method: .get,
            expect: 200
        ).displayable
    }

    func variableBody(_ parameter: VariableBodyParameter) async -> Result<Void, DisplayableError> {
        await networkService.emptyBody(
            from: "variableBody/\(parameter.rawValue)",
            body: VariableBody(parameter: parameter),
            method: .post,
            expect: 200
        ).displayable
    }
}

enum ParameterizedEndpoint: String {
    case first
    case second
}

struct VariableBody: Encodable {
    let parameter: VariableBodyParameter
}

enum VariableBodyParameter: String, Encodable {
    case first
    case second
}
