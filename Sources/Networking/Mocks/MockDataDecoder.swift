import Foundation

struct MockDataDecoder: DataDecoder {
    let model: Any

    #warning("Throw correct error")
    func decode<T>(_ type: T.Type, from data: Data) throws -> T {
        model as! T
    }
}
