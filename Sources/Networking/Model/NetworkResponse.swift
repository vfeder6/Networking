import Foundation

/// The response from the network request.
public struct NetworkResponse<Body: Equatable>: Equatable {

    /// The headers of the response.
    public let headers: Headers

    /// The body of the response.
    public let body: Body?

    /// The URL the response came from.
    let url: URL?
}
