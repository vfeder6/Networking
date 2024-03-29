public extension Microservice {

    /// The mocked implementation of the service.
    ///
    /// This implementation defaults to the live one, so remember to declare it in the Test target.
    static var mock: Self {
        live
    }
}
