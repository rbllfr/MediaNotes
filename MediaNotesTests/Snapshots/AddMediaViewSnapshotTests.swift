import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class AddMediaViewSnapshotTests: XCTestCase {
    
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
    
    func testAddMediaView_InitialState() {
        let viewModel = MockAddMediaViewModel()
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Different Media Types
    
    func testAddMediaView_MovieSelected() {
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .movie
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddMediaView_TVSeriesSelected() {
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .tvSeries
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddMediaView_BookSelected() {
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .book
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddMediaView_AlbumSelected() {
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .album
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - With Content
    
    func testAddMediaView_WithFilledData() {
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .movie
        viewModel.title = "Inception"
        viewModel.subtitle = "Christopher Nolan"
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddMediaView_BookWithData() {
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .book
        viewModel.title = "The Great Gatsby"
        viewModel.subtitle = "F. Scott Fitzgerald"
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - With Parent Selection
    
    func testAddMediaView_EpisodeWithParent() {
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .episode
        viewModel.title = "Ozymandias"
        viewModel.selectedParent = series
        viewModel.sortKey = "S05E14"
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddMediaView_ChapterWithParent() {
        let book = MediaItem(title: "1984", kind: .book)
        let viewModel = MockAddMediaViewModel()
        viewModel.selectedKind = .chapter
        viewModel.title = "Chapter 1"
        viewModel.selectedParent = book
        viewModel.sortKey = "01"
        
        let view = AddMediaView(viewModel: viewModel, onSave: nil)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
}
