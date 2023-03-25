import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

public enum NetworkError: Error {

    /// Could not cast `URLResponse` as `HTTPURLResponse`
    case badURLResponse

    /// Status code between the request and response do not match
    case mismatchingStatusCodes(expected: Int, actual: Int)

    /// Data received in the response body is not decodable
    case notDecodableData(model: Decodable.Type, json: String?)

    /// Headers were not parseable in the response
    case notParseableHeaders

    /// Data passed in the request body failed to be encoded
    case notEncodableData

    /// The response body failed to be decoded into the requested type
    case mismatchingRequestedResponseType

    /// Error thrown by `URLSession`
    case urlSession(error: Error)

    /// ⚠️ Error that should not be returned to the client ⚠️
    ///
    /// In case that the `fullResponseResult` method of `NetworkClient` cannot cast `Error` to `NetworkError`, that
    /// method will gently return `.failure(._unknown)` to avoid force casting the error and causing possible crashes.
    ///
    /// Note that this should not happen because the `NetworkRequestExecutor` entity catches every error thrown
    /// by `URLSession` and throws the `.urlSession(error:)` case.
    case _unknown
}

public struct NetworkResponse<Body> {
    public let headers: [String : String]
    public let body: Body?
}

public protocol Request: Encodable { }

public protocol Response: Decodable { }

public protocol DTO: Request & Response { }

public struct EmptyModel: DTO { }
