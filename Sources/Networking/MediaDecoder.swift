import Foundation
import SwiftUI

struct MediaDecoder {

    /// Method used to decode a `Media` from its data.
    ///
    /// - Parameter data: `Data` to decode the `Media` from.
    ///
    /// - Returns: An instance of `T`.
    func decode<T: Media>(_ type: T.Type, from data: Data) throws -> T {
        #warning("Fix error")

        switch type {
        case is Image.Type:
            return try decodeImage(data) as! T

        default:
            throw MediaDecodingError.notDecodable
        }
    }

    private func decodeImage(_ data: Data) throws -> Image {
        #if canImport(UIKit)
            guard let image = UIImage(data: data).map(Image.init(uiImage:))
            else { throw MediaDecodingError.notDecodable }
            return image

        #elseif canImport(AppKit)
            guard let image = NSImage(data: data).map(Image.init(nsImage:))
            else { throw MediaDecodingError.notDecodable }
            return image

        #else
            throw MediaDecodingError.notDecodable

        #endif
    }
}
