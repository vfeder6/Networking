struct ExampleRequest: Encodable {

}

struct ExampleResponse: Decodable {

}

enum DisplayableError: Error {
    case server
    case client
    case unexpected
    case unknown

    var title: String {
        switch self {
        case .server:
            return "Server error"

        case .client:
            return "App error"

        case .unexpected:
            return "Error"

        case .unknown:
            return "Unknown error"
        }
    }

    var info: String {
        switch self {
        case .server:
            return "An error has been returned from server. Please, try again later."

        case .client:
            return "Oops! The app encountered an error."

        case .unexpected:
            return "Oops! The app encountered an unexpected error and we are analyzing it."

        case .unknown:
            return "We are currently not able to process some information"
        }
    }
}

extension DisplayableError {
    static func from(_ error: NetworkError) -> Self {
        switch error {
        case .notEncodableData, .mismatchingRequestedResponseType:
            return .client

        case .notParseableHeaders, .notDecodableData, .badURLResponse, .mismatchingStatusCodes:
            return .server

        case .unknown:
            return .unknown
        }
    }
}
