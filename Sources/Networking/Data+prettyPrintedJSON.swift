import Foundation

extension Data {
    var prettyPrintedJSON: String? {
        guard
            let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        else { return nil }
        return String(decoding: jsonData, as: UTF8.self)
    }
}
