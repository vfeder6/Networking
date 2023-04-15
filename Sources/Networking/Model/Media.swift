import Foundation
import SwiftUI

public protocol Media: Equatable {

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
