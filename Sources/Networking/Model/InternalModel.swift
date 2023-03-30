import Foundation

public struct HTTPRequest {
    let url: URL
    let method: HTTPMethod
    let headers: [String : String]
    let body: Data?
}

public struct HTTPResponse {
    let body: Data
    let urlResponse: URLResponse
}
