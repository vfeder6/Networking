import XCTest
@testable import Networking

final class NetworkClientTests: XCTestCase {
    private var uut: NetworkClient<EmptyModel>!

    func testSuccess() async throws {
        initialize()

        let response = await self.uut.fullResponseResult(
            from: "",
            queryItems: [],
            body: nil,
            method: .get,
            additionalHeaders: [:],
            expectedStatusCode: 200
        )

        XCTAssertEqual(response, .success(.init(headers: [:], body: model, url: url)))
    }

    func testFailure() async throws {
        initialize()

        let response = await self.uut.fullResponseResult(
            from: "",
            queryItems: [],
            body: nil,
            method: .get,
            additionalHeaders: [:],
            expectedStatusCode: 201
        )

        XCTAssertEqual(response, .failure(.mismatchingStatusCodes(expected: 201, actual: 200)))
    }

    private func initialize() {
        uut = .init(
            networkInterfaced: URLSessionMock(
                response: .success(encodedModel),
                expectedStatusCode: statusCode,
                respondsAfter: delay
            ),
            baseURL: url,
            baseHeaders: baseHeaders
        )
    }
}

extension NetworkClientTests {
    private var model: EmptyModel {
        .init()
    }

    private var encodedModel: Data {
        try! JSONEncoder().encode(model)
    }

    private var url: URL {
        .init(string: "https://example.com")!
    }

    private var statusCode: Int {
        200
    }

    private var delay: Duration {
        .zero
    }

    private var baseHeaders: [String : String] {
        [:]
    }
}

private struct EmptyModel: DTO { }
