import Foundation
import SwiftUI

/// Protocol representing a media file that can be decoded from some `Data`.
public protocol Media: Equatable {

    /// Method used to decode a media from its data.
    ///
    /// - Parameter data: Data to decode the `Media` from.
    ///
    /// - Returns: An instance of `Self`.
    static func decode(from data: Data) throws -> Self
}

extension Image: Media {

    public static func decode(from data: Data) throws -> Self {
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
