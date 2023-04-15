public protocol Logger {

    var dateTime: String { get }

    func log(_ kind: LogKind, _ message: String, file: String, line: Int)

    func raiseRuntimeWarning(_ message: StaticString)
}

public enum LogKind {

    case debug
    case info
    case warning
    case error
    case critical

    var emoji: String {
        switch self {
        case .debug:
            return "🔵"

        case .info:
            return "🟢"

        case .warning:
            return "🟡"

        case .error:
            return "🔴"

        case .critical:
            return "🟣"
        }
    }
}
