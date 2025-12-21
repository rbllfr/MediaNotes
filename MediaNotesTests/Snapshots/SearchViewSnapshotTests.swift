import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class SearchViewSnapshotTests: XCTestCase {
    
    // Fixed date for consistent snapshots (Nov 15, 2023 at 2:00 PM)
    private let fixedDate = Date(timeIntervalSince1970: 1700064000)
    
    override func setUp() {
        super.setUp()
        // Initialize DependencyProvider with fixed time provider for consistent snapshots
        let timeProvider = FixedTimeProvider(now: fixedDate)
        let mockContainer = MockDependencyContainer(timeProvider: timeProvider)
        DependencyProvider.shared.initialize(container: mockContainer)
    }
    
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }
    
    // MARK: - Helpers
    
    private func createNote(text: String, mediaItem: MediaItem, quote: String? = nil) -> Note {
        // Create note with date far in the past for consistent display
        let createdDate = fixedDate.addingTimeInterval(-365 * 24 * 3600) // 1 year ago
        return Note(text: text, mediaItem: mediaItem, quote: quote, createdAt: createdDate)
    }
    
    // MARK: - Empty State
    
    func testSearchView_EmptyState() {
        let viewModel = MockSearchViewModel(viewState: .empty)
        let view = SearchView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - No Results
    
    func testSearchView_NoResults() {
        let viewModel = MockSearchViewModel(viewState: .ready(SearchResults(mediaItems: [], notes: [])))
        viewModel.searchText = "nonexistent"
        
        let view = SearchView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - With Results
    
    func testSearchView_WithMediaResults() {
        let movie = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        let book = MediaItem(title: "Inceptionism", kind: .book, subtitle: "Test Author")
        
        let results = SearchResults(mediaItems: [movie, book], notes: [])
        let viewModel = MockSearchViewModel(viewState: .ready(results))
        viewModel.searchText = "Incep"
        
        let view = SearchView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSearchView_WithNoteResults() {
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let note1 = createNote(text: "This show has incredible character development", mediaItem: mediaItem)
        let note2 = createNote(text: "The cinematography is stunning", mediaItem: mediaItem)
        
        let results = SearchResults(mediaItems: [], notes: [note1, note2])
        let viewModel = MockSearchViewModel(viewState: .ready(results))
        viewModel.searchText = "character"
        
        let view = SearchView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSearchView_MixedResults() {
        let movie = MediaItem(title: "The Matrix", kind: .movie)
        let note1 = createNote(text: "Matrix has revolutionary effects", mediaItem: movie)
        
        let results = SearchResults(mediaItems: [movie], notes: [note1])
        let viewModel = MockSearchViewModel(viewState: .ready(results))
        viewModel.searchText = "matrix"
        
        let view = SearchView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
}
