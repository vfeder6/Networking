import Foundation

public protocol DataDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T
}

public struct JSONDataDecoder: DataDecoder {
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T {
        guard let responseType = type as? Decodable.Type
        else { throw NetworkError._unknown }

        #warning("Fix error")
        guard
            let decoded = try? JSONDecoder().decode(responseType, from: data),
            let response = decoded as? T
        else { throw NetworkError._unknown }

        return response
    }
}

public struct MediaDataDecoder: DataDecoder {
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T {
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

public struct MockDataDecoder: DataDecoder {
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T {
        #warning("To be implemented")
        guard let responseType = type as? EmptyMockModel.Type
        else { throw NetworkError._unknown }

        guard let response = EmptyMockModel() as? T
        else { throw NetworkError._unknown }

        return response
    }
}

struct EmptyMockModel: Response { }
