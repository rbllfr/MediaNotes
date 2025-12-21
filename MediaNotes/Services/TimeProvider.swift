import Foundation

/// Protocol for providing the current time
/// Allows stubbing time in tests for consistent snapshots
protocol TimeProvider {
    var now: Date { get }
}

/// Production time provider - uses actual system time
struct SystemTimeProvider: TimeProvider {
    var now: Date {
        Date()
    }
}

