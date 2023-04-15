import SwiftUI

/// Protocol representing a media file that can be decoded.
public protocol Media: Equatable {

    /// Decodes the data into this type.
    ///
    /// - Parameter data: `Data` to be decoded
    ///
    /// - Returns: An instance of `Self`
    static func from(data: Data) throws -> Self
}

extension Image: Media {

    public static func from(data: Data) throws -> Self {
        #if canImport(UIKit)

        guard let image = UIImage(data: data).map(Image.init(uiImage:))
        else { throw DataDecodingError.notDecodableMedia }
        return image

        #elseif canImport(AppKit)

        guard let image = NSImage(data: data).map(Image.init(nsImage:))
        else { throw DataDecodingError.notDecodableMedia }
        return image

        #else

        throw MediaDecodingError.notDecodable

        #endif
    }
}
