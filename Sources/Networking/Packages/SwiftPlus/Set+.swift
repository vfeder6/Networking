public extension Set {

    static func +(lhs: Self, rhs: Self) -> Self {
        var sumSet: Self = lhs

        for element in rhs {
            sumSet.insert(element)
        }
        return sumSet
    }
}
