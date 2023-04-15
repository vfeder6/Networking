import Foundation

/// Raw HTTP request
public struct HTTPRequest {

    let url: URL
    let method: HTTPMethod
    let headers: [String : String]
    let body: Data?
}
