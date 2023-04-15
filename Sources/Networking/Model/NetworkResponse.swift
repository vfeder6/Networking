import Foundation

/// The response from the network request
public struct NetworkResponse<Body: Equatable>: Equatable {

    public let headers: [String : String]
    public let body: Body?
    let url: URL?
}
