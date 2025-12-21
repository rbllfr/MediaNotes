import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class MediaListViewSnapshotTests: XCTestCase {
    
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
    
    func testMediaListView_EmptyState() {
        let viewModel = MockMediaListViewModel(viewState: .ready([]))
        let view = MediaListView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Loading State
    
    func testMediaListView_LoadingState() {
        let viewModel = MockMediaListViewModel.loading()
        let view = MediaListView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Error State
    
    func testMediaListView_ErrorState() {
        let viewModel = MockMediaListViewModel.error("Failed to load media items")
        let view = MediaListView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Ready State with Content
    
    func testMediaListView_WithMediaItems() {
        let items = createSampleMediaItems()
        let viewModel = MockMediaListViewModel.ready(with: items)
        let view = MediaListView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaListView_WithFilterChips() {
        let items = createSampleMediaItems()
        let viewModel = MockMediaListViewModel.ready(with: items)
        let view = MediaListView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaListView_FilteredByMovie() {
        let items = createSampleMediaItems()
        let viewModel = MockMediaListViewModel.ready(with: items)
        viewModel.selectedFilter = .movie
        
        let view = MediaListView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaListView_FilteredByBook() {
        let items = createSampleMediaItems()
        let viewModel = MockMediaListViewModel.ready(with: items)
        viewModel.selectedFilter = .book
        
        let view = MediaListView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Helper Methods
    
    private func createSampleMediaItems() -> [MediaItem] {
        let movie1 = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        let movie2 = MediaItem(title: "The Matrix", kind: .movie, subtitle: "Wachowskis")
        let book = MediaItem(title: "1984", kind: .book, subtitle: "George Orwell")
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
        let album = MediaItem(title: "Dark Side of the Moon", kind: .album, subtitle: "Pink Floyd")
        
        return [movie1, movie2, book, series, album]
    }
}

