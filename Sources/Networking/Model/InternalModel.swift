import Foundation

public struct HTTPRequest {
    let url: URL
    let method: HTTPMethod
    let headers: [String : String]
    let body: Data?
}

public struct HTTPResponse: HTTPResponseProtocol {
    public let body: Data
    public let urlResponse: URLResponse
}

public struct HTTPResponseMock: HTTPResponseProtocol {
    public let body: any Equatable
    public let urlResponse: URLResponse
}

public protocol HTTPResponseProtocol {
    associatedtype RawResponseType

    var body: RawResponseType { get }
    var urlResponse: URLResponse { get }
}
