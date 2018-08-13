import Foundation

private class EmptyTestClass {}

private extension Bundle {
    static var test: Bundle {
        return Bundle(for: EmptyTestClass.self)
    }
}
