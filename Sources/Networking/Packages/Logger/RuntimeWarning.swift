import os.log

public protocol Logger {
    func raiseRuntimeWarning(_ message: StaticString)
}

struct NetworkLogger: Logger {

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
