import Foundation

/// Raw HTTP request
struct HTTPRequest {

    let url: URL
    let method: HTTPMethod
    let headers: [String : String]
    let body: Data?
}
