import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class AddNoteViewSnapshotTests: XCTestCase {
    
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
    
    func testAddNoteView_InitialState() {
        let viewModel = MockAddNoteViewModel.idle()
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddNoteView_WithPreselectedMedia() {
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
        let viewModel = MockAddNoteViewModel.idle(preselectedMedia: mediaItem)
        
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - With Content
    
    func testAddNoteView_WithNoteText() {
        let mediaItem = MediaItem(title: "The Matrix", kind: .movie)
        let viewModel = MockAddNoteViewModel(
            noteText: "This is a fascinating exploration of reality and consciousness.",
            selectedMedia: mediaItem
        )
        
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddNoteView_WithQuote() {
        let mediaItem = MediaItem(title: "The Matrix", kind: .movie)
        let viewModel = MockAddNoteViewModel(
            noteText: "Neo discovers the truth about reality.",
            selectedMedia: mediaItem,
            quote: "There is no spoon.",
            showQuoteField: true
        )
        
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Different Media Types
    
    func testAddNoteView_BookNote() {
        let book = MediaItem(title: "1984", kind: .book, subtitle: "George Orwell")
        let viewModel = MockAddNoteViewModel(
            noteText: "The concept of doublethink is particularly relevant today.",
            selectedMedia: book,
            quote: "War is peace. Freedom is slavery. Ignorance is strength.",
            showQuoteField: true
        )
        
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddNoteView_AlbumNote() {
        let album = MediaItem(title: "Dark Side of the Moon", kind: .album, subtitle: "Pink Floyd")
        let viewModel = MockAddNoteViewModel(
            noteText: "A masterpiece of progressive rock.",
            selectedMedia: album
        )
        
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Form States
    
    func testAddNoteView_SavingState() {
        let mediaItem = MediaItem(title: "Inception", kind: .movie)
        let viewModel = MockAddNoteViewModel(
            noteText: "Mind-bending story",
            selectedMedia: mediaItem,
            formState: .saving
        )
        
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testAddNoteView_ErrorState() {
        let mediaItem = MediaItem(title: "The Godfather", kind: .movie)
        let viewModel = MockAddNoteViewModel(
            noteText: "Classic mafia film",
            selectedMedia: mediaItem,
            formState: .error("Failed to save note. Please try again.")
        )
        
        let view = AddNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
}
