import Foundation
import SwiftUI

public protocol Media: Equatable {
    static func decode(from data: Data) -> Self?
}

extension Image: Media {
    public static func decode(from data: Data) -> Self? {
        #if canImport(UIKit)
            return UIImage(data: data).map(Image.init(uiImage:))
        #elseif canImport(AppKit)
            return NSImage(data: data).map(Image.init(nsImage:))
        #else
            return nil
        #endif
    }
}
