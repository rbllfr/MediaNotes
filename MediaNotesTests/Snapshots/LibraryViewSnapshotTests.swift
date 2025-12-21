import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class LibraryViewSnapshotTests: XCTestCase {
    
    // Fixed date for consistent snapshots (Nov 15, 2023 at 2:00 PM)
    private let fixedDate = Date(timeIntervalSince1970: 1700064000)
    
    override func setUp() {
        super.setUp()
        // Initialize DependencyProvider with fixed time provider
        let timeProvider = FixedTimeProvider(now: fixedDate)
        let mockContainer = MockDependencyContainer(timeProvider: timeProvider)
        DependencyProvider.shared.initialize(container: mockContainer)
    }
    
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }
    
    // MARK: - Empty State
    
    func testLibraryView_EmptyState() {
        let viewModel = MockLibraryViewModel(viewState: .ready([]))
        let view = LibraryView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Loading State
    
    func testLibraryView_LoadingState() {
        let viewModel = MockLibraryViewModel.loading()
        let view = LibraryView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Error State
    
    func testLibraryView_ErrorState() {
        let viewModel = MockLibraryViewModel.error("Failed to load media items")
        let view = LibraryView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Ready State with Content
    
    func testLibraryView_WithMediaItems() {
        let items = createSampleMediaItems()
        let viewModel = MockLibraryViewModel.ready(with: items)
        let view = LibraryView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testLibraryView_WithFilterChips() {
        let items = createSampleMediaItems()
        let viewModel = MockLibraryViewModel.ready(with: items)
        let view = LibraryView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testLibraryView_FilteredByMovie() {
        let items = createSampleMediaItems()
        let viewModel = MockLibraryViewModel.ready(with: items)
        viewModel.selectedFilter = .movie
        
        let view = LibraryView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testLibraryView_FilteredByBook() {
        let items = createSampleMediaItems()
        let viewModel = MockLibraryViewModel.ready(with: items)
        viewModel.selectedFilter = .book
        
        let view = LibraryView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Helper Methods
    
    private func createNote(text: String, mediaItem: MediaItem, quote: String? = nil) -> Note {
        // Create note with date far in the past for consistent display
        let createdDate = fixedDate.addingTimeInterval(-365 * 24 * 3600) // 1 year ago
        return Note(text: text, mediaItem: mediaItem, quote: quote, createdAt: createdDate)
    }
    
    private func createSampleMediaItems() -> [MediaItem] {
        let movie1 = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        let note1 = createNote(text: "Mind-bending masterpiece", mediaItem: movie1)
        movie1.notes = [note1]
        
        let movie2 = MediaItem(title: "The Matrix", kind: .movie, subtitle: "Wachowskis")
        let note2 = createNote(text: "Revolutionary visual effects", mediaItem: movie2)
        movie2.notes = [note2]
        
        let book = MediaItem(title: "1984", kind: .book, subtitle: "George Orwell")
        let note3 = createNote(text: "Dystopian classic", mediaItem: book)
        book.notes = [note3]
        
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
        let ep1 = MediaItem(title: "Pilot", kind: .episode, sortKey: "S01E01", parent: series)
        let note4 = createNote(text: "Great start", mediaItem: ep1)
        ep1.notes = [note4]
        series.addChild(ep1)
        
        let album = MediaItem(title: "Dark Side of the Moon", kind: .album, subtitle: "Pink Floyd")
        let note5 = createNote(text: "Timeless album", mediaItem: album)
        album.notes = [note5]
        
        return [movie1, movie2, book, series, album]
    }
}
