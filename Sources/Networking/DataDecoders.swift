import Foundation

protocol DataDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T
}

struct JSONDataDecoder: DataDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T {
        guard let responseType = type as? any Response.Type
        else { throw NetworkError._unknown }

        #warning("Fix error")
        guard
            let decoded = try? JSONDecoder().decode(responseType, from: data),
            let response = decoded as? T
        else { throw NetworkError._unknown }

        return response
    }
}

struct MediaDataDecoder: DataDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T {
        guard let responseType = type as? any Media.Type
        else { throw NetworkError._unknown }

        #warning("Fix error")
        guard
            let decoded = try? responseType.decode(from: data),
            let response = decoded as? T
        else { throw NetworkError._unknown }

        return response
    }
}
