import Foundation

public protocol Service {

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

/// Entity responsible of making a single request and expecting a response.
public protocol Microservice: Service {

    /// The response model used to decode the response body.
    associatedtype R: Response

    /// The client that will perform the network requests.
    var networkClient: JSONNetworkClient<R> { get }

    /// The defualt initializer that stores the injected `NetworkClient` instance.
    init(networkClient: JSONNetworkClient<R>)
}

public protocol MediaService: Service {

    associatedtype R: Media

    var networkClient: MediaNetworkClient<R> { get }

    init(networkClient: MediaNetworkClient<R>)
}
