import Foundation
import SwiftUI

// MARK: - Protocol

/// Protocol defining the contract for dependency containers
/// Only exposes view factory methods - complete encapsulation
@MainActor
protocol DependencyContaining {
    // MARK: - Services
    
    /// Provides the current time (can be stubbed for tests)
    var timeProvider: TimeProvider { get }
    
    // MARK: - View Factories
    
    /// Creates a fully configured LibraryView
    func makeLibraryView() -> LibraryView
    
    /// Creates a fully configured MediaListView
    func makeMediaListView() -> MediaListView
    
    /// Creates a fully configured SearchView
    func makeSearchView() -> SearchView
    
    /// Creates a fully configured InsightsView
    /// - Parameter mediaItem: Optional media item to generate insights for (nil means all notes)
    func makeInsightsView(mediaItem: MediaItem?) -> InsightsView
    
    /// Creates a fully configured AddNoteView
    func makeAddNoteView(preselectedMedia: MediaItem?) -> AddNoteView
    
    /// Creates a fully configured MediaDetailView
    func makeMediaDetailView(mediaItem: MediaItem) -> MediaDetailView
    
    /// Creates a fully configured EditNoteView
    func makeEditNoteView(note: Note) -> EditNoteView
    
    /// Creates a fully configured SelectMediaView
    func makeSelectMediaView(selectedMedia: Binding<MediaItem?>) -> SelectMediaView
    
    /// Creates a fully configured AddMediaView
    func makeAddMediaView(onSave: ((MediaItem) -> Void)?) -> AddMediaView
}

// MARK: - Singleton Provider

/// Global dependency provider singleton
/// Initialize once at app startup, use throughout the app
@MainActor
final class DependencyProvider {
    static let shared = DependencyProvider()
    
    private var container: DependencyContaining!
    
    private init() {}
    
    /// Initialize the provider with a container
    /// Call this once at app startup
    func initialize(container: DependencyContaining) {
        self.container = container
    }
    
    /// Access the dependencies container
    /// Will crash if not initialized - this is intentional to catch setup errors early
    var dependencies: DependencyContaining {
        guard let container else {
            fatalError("DependencyProvider not initialized. Call initialize(container:) at app startup.")
        }
        return container
    }
}

