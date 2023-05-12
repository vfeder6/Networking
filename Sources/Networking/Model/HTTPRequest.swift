import Foundation

/// A raw HTTP request.
struct HTTPRequest {

    let url: URL
    let method: HTTPMethod
    let headers: Headers
    let body: Data?
}
