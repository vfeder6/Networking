import Foundation

/// Entity responsible of making a single request and expecting a response.
public protocol Service {

    /// The response model used to decode the response body.
    associatedtype Response: Decodable

    /// The client that will perform the network requests.
    var networkClient: NetworkClient<Response> { get }

    /// Live implementation of the service.
    static var live: Self { get }

    /// Performs a request to the network, using the provided `NetworkClient`.
    ///
    /// - Parameter body: The encodable model to pass as the request's body.
    /// - Parameter queryItems: The query items to append to the URL.
    ///
    /// - Returns: The response `Decodable` model.
    func perform(body: Encodable?, queryItems: [URLQueryItem]) async -> Result<Response, NetworkError>
}

extension Service {

    /// Useful implementation to use with SwiftUI previews.
    ///
    /// This implementation default to the mocked one.
    public static var preview: Self {
        mock
    }
}
