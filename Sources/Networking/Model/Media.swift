import Foundation
import SwiftUI

public protocol Media: Equatable {
    static func generate(from data: Data) -> Self?
}

extension Image: Media {
    public static func generate(from data: Data) -> Image? {
        #if canImport(UIKit)
            guard let uiImage = UIImage(data: data)
            else { return nil}
            return .init(uiImage: uiImage)
        #elseif canImport(AppKit)
            guard let nsImage = NSImage(data: data)
            else { return nil }
            return .init(nsImage: nsImage)
        #else
            return nil
        #endif
    }
}
