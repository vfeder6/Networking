import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

struct HTTPRequest {
    let url: URL
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
}

struct HTTPResponse {
    let body: Data
    let urlResponse: URLResponse
}

enum NetworkError: Error {
    case badURLResponse
    case mismatchingStatusCodes(expected: Int, actual: Int)
    case notDecodableData
    case notParseableHeaders
    case notEncodableData
    case mismatchingRequestedResponseType
}

struct NetworkResponse<Body: Decodable> {
    let headers: [String : String]
    let body: Body?
}
