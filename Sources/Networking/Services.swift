import Foundation

/// Entity responsible of making a single request and expecting a response.
public protocol Microservice {

    /// The response model used to decode the response body.
    associatedtype R: Response

    /// The client that will perform the network requests.
    var networkClient: NetworkClient<R> { get }

    /// Live implementation of the service.
    static var live: Self { get }

    /// The defualt initializer that stores the injected `NetworkClient` instance.
    init(networkClient: NetworkClient<R>)
}

extension Microservice {

    /// Implementation to use with SwiftUI previews.
    ///
    /// This implementation defaults to the mocked one.
    public static var preview: Self {
        mock
    }
}
