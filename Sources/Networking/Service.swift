import Foundation

/// Entity responsible of making a single request and expecting a response.
public protocol Service {

    /// The response model used to decode the response body.
    associatedtype Response: Decodable

    /// The client that will perform the network requests
    var networkClient: NetworkClient<Response> { get }

    /// The encodable model to pass as the request's body
    var endpoint: String { get }

    /// The query items to append to the URL
    var queryItems: [URLQueryItem] { get }

    /// The body to use
    var body: Encodable? { get }

    /// The method used to perform the network call
    var method: HTTPMethod { get }

    /// Any necessary additional header
    var additionalHeaders: [String : String] { get }

    /// The expected status code from the server
    var expectedStatusCode: Int { get }

    /// Live implementation of the service.
    static var live: Self { get }
}

extension Service {

    /// Performs a request to the network, using the provided `NetworkClient`.
    ///
    /// - Returns: The entire response from the server.
    public func performAndGetFullResponse() async -> Result<NetworkResponse<Response>, NetworkError> {
        await networkClient.fullResponseResult(
            from: endpoint,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expectedStatusCode: expectedStatusCode
        )
    }

    /// Performs a request to the network, using the provided `NetworkClient`.
    ///
    /// - Returns: The `Decodable` entity from the server.
    public func perform() async -> Result<Response, NetworkError> {
        await networkClient.responseResult(
            from: endpoint,
            queryItems: queryItems,
            body: body,
            method: method,
            additionalHeaders: additionalHeaders,
            expectedStatusCode: expectedStatusCode
        )
    }
}

extension Service {

    /// Implementation to use with SwiftUI previews.
    ///
    /// This implementation defaults to the mocked one.
    public static var preview: Self {
        mock
    }
}
