enum DataDecodingError: Error {

    /// The data is not decodable to a JSON Object
    case notDecodableJSON

    /// The data is not decodable to a `Media` type
    case notDecodableMedia
}
