import XCTest
@testable import Networking

final class NetworkClientTests: XCTestCase {
    private var uut: NetworkClient<EmptyModel>!

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
        if #available(macOS 13.0, iOS 16.0, *) {
            uut = .init(
                networkInterfaced: URLSessionMock(
                    response: .success(encodedModel),
                    expectedStatusCode: statusCode,
                    respondsAfter: delay
                ),
                baseURL: url,
                baseHeaders: baseHeaders
            )
        } else {
            uut = .init(
                networkInterfaced: LegacyURLSessionMock(
                    response: .success(encodedModel),
                    expectedStatusCode: statusCode,
                    respondsAfter: legacyDelay
                ),
                baseURL: url,
                baseHeaders: baseHeaders
            )
        }
    }
}

private extension NetworkClientTests {
    var model: EmptyModel {
        .init()
    }

    var encodedModel: Data {
        try! JSONEncoder().encode(model)
    }

    var url: URL {
        .init(string: "https://example.com")!
    }

    var statusCode: Int {
        200
    }

    var baseHeaders: [String : String] {
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

private struct EmptyModel: DTO { }
