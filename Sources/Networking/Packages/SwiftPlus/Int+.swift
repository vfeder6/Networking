import Foundation

public extension Int {

    func prependingZeros(upTo unit: NumberUnit) -> String {
        let maxValue = Int(truncating: NSDecimalNumber(decimal: pow(10, unit.rawValue)))
        guard self < maxValue
        else { return stringValue }

        let maxValueString = String(maxValue)
        guard let oneIndex = maxValueString.firstIndex(of: "1")
        else { return stringValue }

        let maxZerosCount: Int = String(maxValueString[maxValueString.index(oneIndex, offsetBy: 1)...]).count

        var attemptsCount: Int = -1
        var copy = Double(self)

        while Int(floor(copy)) != 0 {
            copy /= 10
            attemptsCount += 1
        }

        let zerosCount = maxZerosCount - attemptsCount

        return "\("0".repeating(times: self == 0 ? zerosCount - 1 : zerosCount))\(self)"
    }
}

public extension Int {

    var stringValue: String {
        .init(self)
    }
}
