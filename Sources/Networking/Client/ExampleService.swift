import Foundation

struct ExampleService {
    let networkService: NetworkService = NetworkService(client: NetworkClient.shared)

    func returnsAModel() async -> Result<ExampleResponse, DisplayableError> {
        return await networkService.performRequest(
            to: "/returnsAModel",
            method: .post,
            expect: 201,
            decodeTo: ExampleResponse.self
        ).displayable
    }

    func returnsAnEmptyResponse() async -> Result<Void, DisplayableError> {
        return await networkService.emptyResponse(
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
            decodeTo: ExampleResponse.self
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
        return await networkService.performRequest(
            to: "requestWithBody",
            body: body,
            decodeTo: ExampleResponse.self
        ).displayable
    }

    func parameterizedEndpoint(_ parameter: ParameterizedEndpoint) async -> Result<Void, DisplayableError> {
        return await networkService.emptyResponse(
            from: "parameterizedEndpoint/\(parameter.rawValue)",
            method: .get,
            expect: 200
        ).displayable
    }

    func variableBody(_ parameter: VariableBodyParameter) async -> Result<Void, DisplayableError> {
        return await networkService.emptyResponse(
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
