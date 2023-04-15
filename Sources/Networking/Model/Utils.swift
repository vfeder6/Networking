import SwiftUI

/// A convenience `protocol` for `Encodable` entities used for network requests.
public protocol Request: Encodable, Equatable { }

/// A convenience `protocol` for `Decodable` entities used for network responses.
public protocol Response: Decodable, Equatable { }

/// A convenience `protocol` for Data Transfer Objects (both `Encodable` and `Decodable`) used both for network
/// requests and responses.
public protocol DTO: Request & Response { }

/// An empty `DTO`, used to ignore the body decoding.
public struct EmptyDTO: DTO { }

/// A typealias for headers.
public typealias Headers = [String : String]
