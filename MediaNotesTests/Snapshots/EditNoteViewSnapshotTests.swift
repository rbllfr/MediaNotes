import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class EditNoteViewSnapshotTests: XCTestCase {
    
    // Fixed date for consistent snapshots (Nov 15, 2023 at 2:00 PM)
    private let fixedDate = Date(timeIntervalSince1970: 1700064000)
    
    override func setUp() {
        super.setUp()
        // Use fixed time provider for consistent snapshots
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
    
    private func createNote(text: String, mediaItem: MediaItem, quote: String? = nil, edited: Bool = false) -> Note {
        // Create note with date far in the past for consistent display
        let createdDate = fixedDate.addingTimeInterval(-365 * 24 * 3600) // 1 year ago
        let note = Note(text: text, mediaItem: mediaItem, quote: quote, createdAt: createdDate)
        if edited {
            // Set edited date to 1 hour after creation
            note.editedAt = createdDate.addingTimeInterval(3600)
        }
        return note
    }
    
    // MARK: - Basic Editing
    
    func testEditNoteView_BasicNote() {
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let note = createNote(text: "This show has incredible storytelling.", mediaItem: mediaItem)
        let viewModel = MockEditNoteViewModel(note: note)
        
        let view = EditNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testEditNoteView_NoteWithQuote() {
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let note = createNote(
            text: "Walter White's transformation is compelling.",
            mediaItem: mediaItem,
            quote: "I am the one who knocks."
        )
        let viewModel = MockEditNoteViewModel(note: note)
        
        let view = EditNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Different Media Types
    
    func testEditNoteView_MovieNote() {
        let movie = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        let note = createNote(text: "The dream layers are brilliantly executed.", mediaItem: movie)
        let viewModel = MockEditNoteViewModel(note: note)
        
        let view = EditNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testEditNoteView_BookNote() {
        let book = MediaItem(title: "1984", kind: .book, subtitle: "George Orwell")
        let note = createNote(
            text: "The concept of Big Brother remains relevant today.",
            mediaItem: book,
            quote: "Big Brother is watching you."
        )
        let viewModel = MockEditNoteViewModel(note: note)
        
        let view = EditNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testEditNoteView_EditedNote() {
        let movie = MediaItem(title: "Fight Club", kind: .movie, subtitle: "David Fincher")
        let note = createNote(
            text: "The twist ending changes everything.",
            mediaItem: movie,
            edited: true
        )
        let viewModel = MockEditNoteViewModel(note: note)
        
        let view = EditNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Form States
    
    func testEditNoteView_SavingState() {
        let mediaItem = MediaItem(title: "The Matrix", kind: .movie)
        let note = createNote(text: "Neo's journey is transformative.", mediaItem: mediaItem)
        let viewModel = MockEditNoteViewModel(note: note, formState: .saving)
        
        let view = EditNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testEditNoteView_ErrorState() {
        let mediaItem = MediaItem(title: "The Godfather", kind: .movie)
        let note = createNote(text: "A masterpiece of cinema.", mediaItem: mediaItem)
        let viewModel = MockEditNoteViewModel(
            note: note,
            formState: .error("Failed to update note. Please try again.")
        )
        
        let view = EditNoteView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
}
