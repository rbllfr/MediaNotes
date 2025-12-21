import Foundation
@testable import MediaNotes

/// Test time provider - uses a fixed date for consistent snapshots
struct FixedTimeProvider: TimeProvider {
    let now: Date
    
    /// Initialize with a fixed date
    /// Default: Nov 15, 2023 at 2:00 PM UTC (1700064000)
    init(now: Date = Date(timeIntervalSince1970: 1700064000)) {
        self.now = now
    }
}

