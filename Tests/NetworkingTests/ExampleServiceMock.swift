@testable import Networking

struct ExampleServiceMock: ExampleServiceProtocol {
    let networkService: NetworkClient = try! .mock(returning: .success(ExampleRequest()), expecting: 200, after: .seconds(0.5))

    private let returnsAModelBehavior: ReturnsAModelBehavior
    private let returnsAnEmptyResponseBehavior: ReturnsAnEmptyResponseBehavior
    private let checkOnResponseHeadersBehavior: CheckOnResponseHeadersBehavior
    private let requestWithBodyBehavior: RequestWithBodyBehavior
    private let parameterizedEndpointBehavior: ParameterizedEndpointBehavior
    private let variableBodyBehavior: VariableBodyBehavior

    init(
        returnsAModelBehavior: ReturnsAModelBehavior = .success,
        returnsAnEmptyResponseBehavior: ReturnsAnEmptyResponseBehavior = .success,
        checkOnResponseHeadersBehavior: CheckOnResponseHeadersBehavior = .success,
        requestWithBodyBehavior: RequestWithBodyBehavior = .success,
        parameterizedEndpointBehavior: ParameterizedEndpointBehavior = .success,
        variableBodyBehavior: VariableBodyBehavior = .success
    ) {
        self.returnsAModelBehavior = returnsAModelBehavior
        self.returnsAnEmptyResponseBehavior = returnsAnEmptyResponseBehavior
        self.checkOnResponseHeadersBehavior = checkOnResponseHeadersBehavior
        self.requestWithBodyBehavior = requestWithBodyBehavior
        self.parameterizedEndpointBehavior = parameterizedEndpointBehavior
        self.variableBodyBehavior = variableBodyBehavior
    }

    func returnsAModel() async -> Result<ExampleResponse, DisplayableError> {
        switch returnsAModelBehavior {
        case .success:
            return .success(ExampleResponse())

        case .failure(let error):
            return .failure(error)
        }
    }

    func returnsAnEmptyResponse() async -> Result<Void, DisplayableError> {
        switch returnsAModelBehavior {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    func checkOnResponseHeaders() async -> Result<ExampleResponse, DisplayableError> {
        switch returnsAModelBehavior {
        case .success:
            return .success(ExampleResponse())

        case .failure(let error):
            return .failure(error)
        }
    }

    func requestWithBody(_ body: ExampleRequest) async -> Result<ExampleResponse, DisplayableError> {
        switch returnsAModelBehavior {
        case .success:
            return .success(ExampleResponse())

        case .failure(let error):
            return .failure(error)
        }
    }

    func parameterizedEndpoint(_ parameter: ParameterizedEndpoint) async -> Result<Void, DisplayableError> {
        switch returnsAModelBehavior {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }

    func variableBody(_ parameter: VariableBodyParameter) async -> Result<Void, DisplayableError> {
        switch returnsAModelBehavior {
        case .success:
            return .success(())

        case .failure(let error):
            return .failure(error)
        }
    }
}

enum ReturnsAModelBehavior {
    case success
    case failure(DisplayableError)
}

enum ReturnsAnEmptyResponseBehavior {
    case success
    case failure(DisplayableError)
}

enum CheckOnResponseHeadersBehavior {
    case success
    case failure(DisplayableError)
}

enum RequestWithBodyBehavior {
    case success
    case failure(DisplayableError)
}

enum ParameterizedEndpointBehavior {
    case success
    case failure(DisplayableError)
}

enum VariableBodyBehavior {
    case success
    case failure(DisplayableError)
}
