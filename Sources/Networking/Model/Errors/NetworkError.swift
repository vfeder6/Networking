import Foundation

/// An error occured while performing a network request.
public enum NetworkError: Error, Equatable {

    /// Cast from `URLResponse` to `HTTPURLResponse` had failed.
    case badURLResponse

    /// Status code between the request and response do not match.
    case mismatchingStatusCodes(expected: Int, actual: Int)

    /// Data received in the response body is not decodable.
    case notDecodableData(Data)

    /// Headers were not parseable in the response.
    case notParseableHeaders

    /// Data passed in the request body failed to be encoded.
    case notEncodableData

    /// The response body failed to be decoded into the requested type.
    case mismatchingRequestedResponseType

    case urlNotComposable

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
