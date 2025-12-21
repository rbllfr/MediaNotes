import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

// MARK: - Snapshot Test Helpers

/// Standard device configurations for snapshot testing
enum SnapshotDevice {
    case iPhoneSE
    case iPhone13
    case iPhone15Pro
    case iPhone15ProMax
    
    var config: ViewImageConfig {
        switch self {
        case .iPhoneSE:
            return .iPhoneSe
        case .iPhone13:
            return .iPhone13
        case .iPhone15Pro:
            return .iPhone13Pro
        case .iPhone15ProMax:
            return .iPhone13ProMax
        }
    }
}

/// Standard color schemes for snapshot testing
enum SnapshotColorScheme {
    case light
    case dark
    
    var scheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - View Extension for Snapshot Testing

extension View {
    /// Wrap view for snapshot testing with proper environment
    func snapshotTestable(
        colorScheme: SnapshotColorScheme = .dark,
        dependencies: MockDependencyContainer? = nil
    ) -> some View {
        self
            .preferredColorScheme(colorScheme.scheme)
            .environment(\.dependencies, dependencies ?? MockDependencyContainer())
    }
}

// MARK: - Environment Key for Dependencies

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue: MockDependencyContainer? = nil
}

extension EnvironmentValues {
    var dependencies: MockDependencyContainer? {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

// MARK: - Sample Data Factories

@MainActor
enum SampleDataFactory {
    /// Create sample media items for testing
    static func createMediaItems() -> [MediaItem] {
        let breakingBad = MediaItem(
            title: "Breaking Bad",
            kind: .tvSeries,
            subtitle: "Vince Gilligan"
        )
        
        let ozymandias = MediaItem(
            title: "Ozymandias",
            kind: .episode,
            sortKey: "S05E14",
            parent: breakingBad
        )
        breakingBad.addChild(ozymandias)
        
        let gatsby = MediaItem(
            title: "The Great Gatsby",
            kind: .book,
            subtitle: "F. Scott Fitzgerald"
        )
        
        let inception = MediaItem(
            title: "Inception",
            kind: .movie,
            subtitle: "Christopher Nolan"
        )
        
        return [breakingBad, gatsby, inception]
    }
    
    /// Create sample notes for testing
    static func createNotes(for mediaItem: MediaItem) -> [Note] {
        [
            Note(
                text: "This scene really demonstrates Walter's transformation from teacher to criminal mastermind.",
                mediaItem: mediaItem,
                quote: "I am the one who knocks."
            ),
            Note(
                text: "The cinematography in this episode is absolutely stunning. The use of color and light creates such a tense atmosphere.",
                mediaItem: mediaItem
            ),
            Note(
                text: "Character development at its finest.",
                mediaItem: mediaItem
            )
        ]
    }
    
    /// Create a single sample media item
    static func createSampleMovie() -> MediaItem {
        MediaItem(
            title: "The Shawshank Redemption",
            kind: .movie,
            subtitle: "Frank Darabont"
        )
    }
    
    /// Create a sample TV series with episodes
    static func createSampleTVSeries() -> MediaItem {
        let series = MediaItem(
            title: "Breaking Bad",
            kind: .tvSeries,
            subtitle: "Vince Gilligan"
        )
        
        let ep1 = MediaItem(title: "Pilot", kind: .episode, sortKey: "S01E01", parent: series)
        let ep2 = MediaItem(title: "Ozymandias", kind: .episode, sortKey: "S05E14", parent: series)
        
        series.addChild(ep1)
        series.addChild(ep2)
        
        return series
    }
}
