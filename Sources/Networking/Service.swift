import Foundation

public protocol Service {
    associatedtype Response

    var networkService: NetworkService { get }

    static var live: Self { get }
    static var preview: Self { get }
    static var mock: Self { get }

    func perform(body: (any Encodable)?, queryItems: [URLQueryItem]) async -> Response
}

extension Service {
    static var preview: Self {
        live
    }

    static var mock: Self {
        live
    }
}
