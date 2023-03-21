import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

public struct HTTPRequest {
    let url: URL
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
}

public struct HTTPResponse {
    let body: Data
    let urlResponse: URLResponse
}

public enum NetworkError: Error {
    case badURLResponse
    case mismatchingStatusCodes(expected: Int, actual: Int)
    case notDecodableData(model: Decodable.Type, json: String?)
    case notParseableHeaders
    case notEncodableData
    case mismatchingRequestedResponseType
    case unknown
}

public struct NetworkResponse<Body> {
    let headers: [String : String]
    let body: Body?
}
