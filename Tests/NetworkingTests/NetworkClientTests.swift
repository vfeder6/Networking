import XCTest
@testable import Networking

final class NetworkClientTests: XCTestCase {
    private var uut: NetworkClient<EmptyMockModel>!

    func test_urlComposition() async {
        initialize()
        let logger = StandardLogger()

        logger.log(.info, "Test info")
        logger.log(.warning, "Test warning")
        logger.log(.error, "Test error")
        logger.log(.critical, "Test critical")

        let response = await uut.fullResponseResult(
            from: "endpoint",
            queryItems: [.init(name: "testKey", value: "testValue")],
            body: nil,
            method: .get,
            additionalHeaders: [:],
            expectedStatusCode: 200
        )

        XCTAssertEqual(response, .success(.init(
            headers: [:],
            body: model,
            url: .init(string: "https://example.com/endpoint?testKey=testValue")!
        )))
    }

    func test_urlComposition_urlAlreadyWithQueryItem() async {
        initialize()

        let response = await uut.fullResponseResult(
            from: "endpoint?first=second",
            queryItems: [.init(name: "testKey", value: "testValue")],
            body: nil,
            method: .get,
            additionalHeaders: [:],
            expectedStatusCode: 200
        )

        XCTAssertEqual(response, .success(.init(
            headers: [:],
            body: model,
            url: .init(string: "https://example.com/endpoint%3Ffirst=second?testKey=testValue")!
        )))
    }

    func testSuccess() async {
        initialize()

        let response = await uut.fullResponseResult(
            from: "",
            queryItems: [],
            body: nil,
            method: .get,
            additionalHeaders: [:],
            expectedStatusCode: 200
        )

        XCTAssertEqual(response, .success(.init(headers: [:], body: model, url: url)))
    }

    func test_failure_mismatchingStatusCodes() async {
        initialize()

        let response = await uut.fullResponseResult(
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
        uut = .mock(returning: .success(.init()), expecting: statusCode)
    }
}

extension NetworkClientTests {
    private var model: EmptyMockModel {
        .init()
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

    private var baseHeaders: Headers {
        [:]
    }
}

private struct EmptyMockModel: Response { }
