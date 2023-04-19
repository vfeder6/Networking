public extension String {

    /// An empty string.
    static var empty: Self {
        ""
    }

    func repeating(times: Int) -> Self {
        var copy: String = ""

        for _ in 0 ..< times {
            copy += self
        }

        return copy
    }
}
