import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

public enum NetworkError: Error, Equatable {

    /// Could not cast `URLResponse` as `HTTPURLResponse`
    case badURLResponse

    case wrongHTTPResponseType

    /// Status code between the request and response do not match
    case mismatchingStatusCodes(expected: Int, actual: Int)

    /// Data received in the response body is not decodable
    case notDecodableData(Data)

    /// Headers were not parseable in the response
    case notParseableHeaders

    /// Data passed in the request body failed to be encoded
    case notEncodableData

    /// The response body failed to be decoded into the requested type
    case mismatchingRequestedResponseType

    /// Error thrown by `URLSession`
    case urlSession(description: String)

    /// ⚠️ Error that should not be returned to the client ⚠️
    ///
    /// In case that the `fullResponseResult` method of `NetworkClient` cannot cast `Error` to `NetworkError`, that
    /// method will gently return `.failure(._unknown)` to avoid force casting the error and causing possible crashes.
    ///
    /// Note that this should not happen because the `NetworkRequestExecutor` entity catches every error thrown
    /// by `URLSession` and throws the `.urlSession(error:)` case.
    case _unknown
}

public struct NetworkResponse<Body: Equatable>: Equatable {
    public let headers: [String : String]
    public let body: Body?
    let url: URL?
}

/// A convenience `protocol` for `Encodable` entities used for network requests
public protocol Request: Encodable, Equatable { }

/// A convenience `protocol` for `Decodable` entities used for network responses
public protocol Response: Decodable, Equatable { }

/// A convenience `protocol` for Data Transfer Objects (both `Encodable` and `Decodable`) used both for network
/// requests and responses
public protocol DTO: Request & Response { }

/// An empty `DTO`, used to ignore the body decoding
public struct EmptyDTO: DTO { }
