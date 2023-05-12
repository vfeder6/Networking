import Foundation
import SwiftUI

struct MediaDecoder {

    /// Method used to decode a `Media` from its data.
    ///
    /// - Parameter data: `Data` to decode the `Media` from.
    ///
    /// - Returns: An instance of `T`.
    func decode<T: Media>(_ type: T.Type, from data: Data) throws -> T {
        try type.from(data: data)
    }
}
