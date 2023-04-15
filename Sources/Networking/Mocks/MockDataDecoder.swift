import Foundation

struct MockDataDecoder: DataDecoder {
    let model: Any

    func decode<T>(_ type: T.Type, from data: Data) throws -> T {
        guard let model = model as? T
        else { throw MockDataDecodingError.wrongTypeProvided }

        return model
    }
}

enum MockDataDecodingError: Error {

    /// The type provided in the initializer does not match the one provided in the `decode` method
    case wrongTypeProvided
}
