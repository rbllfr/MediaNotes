import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class SelectMediaViewSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize DependencyProvider
        let mockContainer = MockDependencyContainer()
        DependencyProvider.shared.initialize(container: mockContainer)
    }
    
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }
    
    // MARK: - Initial State
    
    func testSelectMediaView_EmptyLibrary() {
        let viewModel = MockSelectMediaViewModel(allItems: [])
        let view = SelectMediaView(viewModel: viewModel, selectedMedia: .constant(nil))
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSelectMediaView_WithMediaItems() {
        let items = createSampleMediaItems()
        let viewModel = MockSelectMediaViewModel(allItems: items)
        
        let view = SelectMediaView(viewModel: viewModel, selectedMedia: .constant(nil))
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - With Selection
    
    func testSelectMediaView_WithSelectedMedia() {
        let items = createSampleMediaItems()
        let selectedItem = items.first!
        let viewModel = MockSelectMediaViewModel(allItems: items)
        
        let view = SelectMediaView(viewModel: viewModel, selectedMedia: .constant(selectedItem))
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - With Search
    
    func testSelectMediaView_WithSearchText() {
        let items = createSampleMediaItems()
        let viewModel = MockSelectMediaViewModel(allItems: items)
        viewModel.searchText = "Break"
        
        let view = SelectMediaView(viewModel: viewModel, selectedMedia: .constant(nil))
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - With Filters
    
    func testSelectMediaView_FilteredByMovie() {
        let items = createSampleMediaItems()
        let viewModel = MockSelectMediaViewModel(allItems: items)
        viewModel.selectedKind = .movie
        
        let view = SelectMediaView(viewModel: viewModel, selectedMedia: .constant(nil))
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSelectMediaView_FilteredByBook() {
        let items = createSampleMediaItems()
        let viewModel = MockSelectMediaViewModel(allItems: items)
        viewModel.selectedKind = .book
        
        let view = SelectMediaView(viewModel: viewModel, selectedMedia: .constant(nil))
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Helper Methods
    
    private func createSampleMediaItems() -> [MediaItem] {
        let movie1 = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        let movie2 = MediaItem(title: "The Matrix", kind: .movie, subtitle: "Wachowskis")
        
        let book = MediaItem(title: "1984", kind: .book, subtitle: "George Orwell")
        
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
        let ep1 = MediaItem(title: "Pilot", kind: .episode, sortKey: "S01E01", parent: series)
        series.addChild(ep1)
        
        let album = MediaItem(title: "Dark Side of the Moon", kind: .album, subtitle: "Pink Floyd")
        
        return [movie1, movie2, book, series, album]
    }
}
