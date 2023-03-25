import Foundation

/// Entity responsible of making a single request and expecting a response.
public protocol Service {

    /// The response model used to decode the response body.
    associatedtype Response: Decodable

    /// The client that will perform the network requests
    var networkClient: NetworkClient<Response> { get }

    /// Live implementation of the service.
    static var live: Self { get }
}

extension Service {

    /// Implementation to use with SwiftUI previews.
    ///
    /// This implementation defaults to the mocked one.
    public static var preview: Self {
        mock
    }
}
