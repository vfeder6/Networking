import XCTest
@testable import Networking

final class NetworkClientTests: XCTestCase {
    private var uut: NetworkClient<EmptyMockModel>!

    func test_urlComposition() async {
        initialize()

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

private extension NetworkClientTests {
    var model: EmptyMockModel {
        .init()
    }

    var url: URL {
        .init(string: "https://example.com")!
    }

    var statusCode: Int {
        200
    }

    var delay: Duration {
        .zero
    }

    var baseHeaders: Headers {
        [:]
    }
}

@available(macOS 13.0, iOS 16.0, *)
private extension NetworkClientTests {
    var delay: Duration {
        .zero
    }
}

@available(iOS, deprecated: 16.0, renamed: "delay")
@available(macOS, deprecated: 13.0, renamed: "delay")
private extension NetworkClientTests {
    var legacyDelay: Double {
        .zero
    }
}

private struct EmptyMockModel: DTO { }
