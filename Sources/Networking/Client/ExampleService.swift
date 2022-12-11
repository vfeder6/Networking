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
            if response.headers["SomeHeaderKey"] == "SomeHeaderValue" {
                return .success(response.body!)
            }
            return .failure(.server)

        case .failure(let error):
            return .failure(error)
        }
    }
}



extension Result where Failure == NetworkError {
    var displayable: Result<Success, DisplayableError> {
        switch self {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            return .failure(.from(failure))
        }
    }
}

//extension Result where Success == NetworkResponse, Failure == DisplayableError {
//    func expectHeaders(_ headers: [String: String], else: DisplayableError) -> Self {
//        switch self {
//        case .success(let success):
//            <#code#>
//
//        case .failure(let failure):
//            <#code#>
//        }
//    }
//}
//
//struct AnyDecodable: Decodable {
//    let decodeFunction: () -> Decodable
//
//    init(_ decodable: Decodable) {
//        decodeFunction = { decodable }
//    }
//
//    init(from decoder: Decoder) throws {
//        self = .init(<#T##decodable: Decodable##Decodable#>)
//    }
//}
