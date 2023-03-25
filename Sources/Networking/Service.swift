import Foundation

public protocol Service {
    associatedtype Response: Decodable

    var networkClient: NetworkClient<Response> { get }

    static var live: Self { get }

    func perform(body: Encodable?, queryItems: [URLQueryItem]) async -> Response
}

extension Service {
    public static var preview: Self {
        live
    }

    public  static var mock: Self {
        live
    }
}
