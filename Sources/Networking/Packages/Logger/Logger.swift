import Foundation
import os.log

public struct Logger {

    private let minimumLogLevel: Kind
    private let dateTimeConfiguration: DateTimeConfiguration
    private let prefixConfiguration: PrefixConfiguration
    private let showFileNameAndLine: Bool

    public init(
        minimumLogLevel: Kind = .debug,
        dateTimeConfiguration: DateTimeConfiguration = .time,
        prefixConfiguration: PrefixConfiguration = .emoji,
        showFileNameAndLine: Bool = true
    ) {
        self.minimumLogLevel = minimumLogLevel
        self.dateTimeConfiguration = dateTimeConfiguration
        self.prefixConfiguration = prefixConfiguration
        self.showFileNameAndLine = showFileNameAndLine
    }

    public func log(_ kind: Kind, _ message: String, file: String = #file, line: Int = #line) {
        guard kind >= minimumLogLevel
        else { return }
        print("\(prefixConfiguration.prefix(for: kind)) \(dateTimeConfiguration.currentDateAndTime)\(fileNameAndLine(from: file, line: line)) -> \(message)")
    }

    public func raiseRuntimeWarning(_ message: StaticString) {
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

private extension Logger {

    func fileNameAndLine(from file: String, line: Int) -> String {
        guard showFileNameAndLine
        else { return .empty }

        guard let lastSlashIndex = file.lastIndex(of: "/")
        else { return ", UNKNOWN FILE" }

        let fileNameBeginningIndex = file.index(lastSlashIndex, offsetBy: 1)
        let fileName = String(file[fileNameBeginningIndex...])
        return ", \(fileName):\(line)"
    }
}

public extension Logger {

    enum Kind: Int, Comparable, Equatable {

        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
        case critical = 5

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

public extension Logger {

    struct PrefixConfiguration {
        let debug: String
        let info: String
        let warning: String
        let error: String
        let critical: String

        public init(debug: String, info: String, warning: String, error: String, critical: String) {
            self.debug = debug
            self.info = info
            self.warning = warning
            self.error = error
            self.critical = critical
        }

        func prefix(for kind: Kind) -> String {
            switch kind {
            case .debug:
                return debug

            case .info:
                return info

            case .warning:
                return warning

            case .error:
                return error

            case .critical:
                return critical
            }
        }
    }
}

public extension Logger.PrefixConfiguration {

    static var emoji: Self {
        .init(debug: "🔵", info: "🟢", warning: "🟡", error: "🔴", critical: "🟣")
    }

    static var uppercased: Self {
        .init(debug: "DEBUG", info: "INFO", warning: "WARNING", error: "ERROR", critical: "CRITICAL")
    }
}

public extension Logger {
    enum DateTimeConfiguration {

        case dateAndTime
        case time

        var currentDateAndTime: String {
            let components = components
            let milliseconds = Int(round(Double(components.nanosecond! / 1_000_000))).prependingZeros(upTo: .hundreds)

            switch self {
            case .dateAndTime:
                return "\(components.year!)-\(components.month!.dateTimeString)-\(components.day!.dateTimeString)@\(components.hour!.dateTimeString):\(components.minute!.dateTimeString):\(components.second!.dateTimeString).\(milliseconds)"

            case .time:
                return "\(components.hour!.dateTimeString):\(components.minute!.dateTimeString):\(components.second!.dateTimeString).\(milliseconds)"
            }
        }

        private var components: DateComponents {
            let currentDate = Date()
            let sharedComponents: Set<Calendar.Component> = [.hour, .minute, .second, .nanosecond]

            switch self {
            case .dateAndTime:
                return Calendar.current.dateComponents(sharedComponents + [.year, .month, .day], from: currentDate)

            case .time:
                return Calendar.current.dateComponents(sharedComponents, from: currentDate)
            }
        }
    }
}

private extension Int {

    var dateTimeString: String {
        self.prependingZeros(upTo: .tens)
    }
}
