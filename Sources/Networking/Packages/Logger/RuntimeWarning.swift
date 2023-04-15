import Foundation
import os.log

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

struct NetworkLogger: Logger {

    var dateTime: String {
        let components = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: .init())
        return "\(components.hour!):\(components.minute!):\(components.second!).\(components.nanosecond!)"
    }

    func log(_ kind: LogKind, _ message: String, file: String = #file, line: Int = #line) {
        print("\(kind.emoji) \(dateTime), \(fileNameAndLine(from: file, line: line)) -> \(message)")
    }

    func fileNameAndLine(from file: String, line: Int) -> String {
        guard let lastSlashIndex = file.lastIndex(of: "/")
        else { return "UNKNOWN FILE" }

        let fileNameBeginningIndex = file.index(lastSlashIndex, offsetBy: 1)
        let fileName = String(file[fileNameBeginningIndex...])
        return "\(fileName):\(line)"
    }

    func raiseRuntimeWarning(_ message: StaticString) {
        #if DEBUG
        var info = Dl_info()
        dladdr(
            dlsym(
                dlopen(nil, RTLD_LAZY),
                "$s10Foundation15AttributeScopesO7SwiftUIE05swiftE0AcDE0D12UIAttributesVmvg"
            ),
            &info
        )

        if let dli_fbase = info.dli_fbase {
            os_log(
                .fault,
                dso: dli_fbase,
                log: OSLog(
                    subsystem: "com.apple.runtime-issues",
                    category: "Networking"
                ),
                message
            )
        }
        #endif
    }
}
