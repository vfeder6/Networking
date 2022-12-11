import XCTest
@testable import Networking

final class SomeReducerOrViewModelTests: XCTestCase {
    var exampleService: ExampleServiceMock!
    var uut: ViewModel!

    func testSuccess() async throws {
        initialize()

        await uut.viewLoaded()
        XCTAssertEqual(uut.model, ExampleResponse())
        XCTAssertNil(uut.error)
    }

    func testFailure() async throws {
        initialize(returnsAModelBehavior: .failure(.server))

        await uut.viewLoaded()
        XCTAssertEqual(uut.error, DisplayableError.server)
        XCTAssertNil(uut.model)
    }
}

extension SomeReducerOrViewModelTests {
    func initialize(returnsAModelBehavior: ReturnsAModelBehavior = .success) {
        exampleService = .init(returnsAModelBehavior: returnsAModelBehavior)
        uut = .init(exampleService: exampleService)
    }
}

final class ViewModel: ObservableObject {
    var model: ExampleResponse? = nil
    var error: DisplayableError? = nil
    let exampleService: ExampleServiceProtocol

    init(exampleService: ExampleServiceProtocol) {
        self.exampleService = exampleService
    }

    @MainActor
    func viewLoaded() async {
        let result = await exampleService.returnsAModel()

        switch result {
        case .success(let success):
            model = success

        case .failure(let failure):
            error = failure
        }
    }
}
