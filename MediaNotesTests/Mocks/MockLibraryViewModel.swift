import Foundation
import SwiftUI
@testable import MediaNotes

@MainActor
@Observable
final class MockLibraryViewModel: LibraryViewModelProtocol {
    var viewState: ViewState<[MediaItem]>
    var selectedFilter: MediaKind?
    var sortOrder: LibrarySortOrder = .recentlyNoted
    
    private var mediaItems: [MediaItem] {
        viewState.data ?? []
    }
    
    var filteredItems: [MediaItem] {
        var items = mediaItems.filter { $0.totalNoteCount > 0 }
        if let filter = selectedFilter {
            items = items.filter { $0.kind == filter }
        }
        return items
    }
    
    var activeMediaKinds: [MediaKind] {
        let kinds = Set(mediaItems.filter { $0.totalNoteCount > 0 }.map { $0.kind })
        return MediaKind.allCases.filter { kinds.contains($0) }
    }
    
    var itemCount: Int {
        filteredItems.count
    }
    
    /// Create a mock with a specific state - perfect for snapshot testing
    init(viewState: ViewState<[MediaItem]> = .empty) {
        self.viewState = viewState
    }
    
    /// Convenience: create mock in ready state with items
    static func ready(with items: [MediaItem]) -> MockLibraryViewModel {
        MockLibraryViewModel(viewState: .ready(items))
    }
    
    /// Convenience: create mock in loading state
    static func loading() -> MockLibraryViewModel {
        MockLibraryViewModel(viewState: .loading)
    }
    
    /// Convenience: create mock in error state
    static func error(_ message: String) -> MockLibraryViewModel {
        MockLibraryViewModel(viewState: .error(message))
    }
    
    func initialize() async {
        // No-op for mock - state is pre-set
    }
    
    func refresh() async {
        // No-op for mock
    }
    
    func setFilter(_ kind: MediaKind?) {
        selectedFilter = kind
    }
    
    func toggleFilter(_ kind: MediaKind) {
        selectedFilter = selectedFilter == kind ? nil : kind
    }
    
    func setSortOrder(_ order: LibrarySortOrder) {
        sortOrder = order
    }
}

