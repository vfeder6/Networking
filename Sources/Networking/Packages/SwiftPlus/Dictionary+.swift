public extension Dictionary {

    /// Sums the content of two dictionaries, replacing duplicate elements.
    ///
    /// - Parameter lhs: The first dictionary
    /// - Parameter rhs: The second dictionary
    ///
    /// - Returns: A new dictionary with all the items
    static func +(lhs: Self, rhs: Self) -> Self {
        var dictionary = lhs

        for (key, value) in rhs {
            dictionary[key] = value
        }

        return dictionary
    }
}
