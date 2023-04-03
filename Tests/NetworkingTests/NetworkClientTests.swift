import XCTest
@testable import Networking

final class NetworkClientTests: XCTestCase {
    private var uut: JSONNetworkClient<EmptyModel>!

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
        uut = .init(
            networkInterfaced: URLSessionMock(
                response: .success(()),
                expectedStatusCode: statusCode,
                respondsAfter: delay
            ),
            baseURL: url,
            baseHeaders: baseHeaders, decode: { _ in .init() }
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
