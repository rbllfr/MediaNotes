import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class NoteRowViewSnapshotTests: XCTestCase {
    
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
    
    // MARK: - Helpers
    
    private func createNote(text: String, mediaItem: MediaItem, quote: String? = nil) -> Note {
        // Create note with date far in the past for consistent display
        let createdDate = fixedDate.addingTimeInterval(-365 * 24 * 3600) // 1 year ago
        return Note(text: text, mediaItem: mediaItem, quote: quote, createdAt: createdDate)
    }
    
    // MARK: - Basic NoteRowView Tests
    
    func testNoteRowView_Basic() {
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let note = createNote(
            text: "This is a great show with excellent character development.",
            mediaItem: mediaItem
        )
        
        let view = NoteRowView(note: note)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_WithQuote() {
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let note = createNote(
            text: "Walter White's transformation is perfectly captured in this scene.",
            mediaItem: mediaItem,
            quote: "I am the one who knocks."
        )
        
        let view = NoteRowView(note: note)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_LongText() {
        let mediaItem = MediaItem(title: "The Great Gatsby", kind: .book)
        let note = createNote(
            text: "The symbolism in this chapter is extraordinary. Fitzgerald uses the green light as a metaphor for Gatsby's dreams and hopes. The way he describes the valley of ashes creates such a vivid contrast between wealth and poverty. This really shows the dark side of the American Dream.",
            mediaItem: mediaItem
        )
        
        let view = NoteRowView(note: note)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_WithMediaInfo() {
        let mediaItem = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        let note = createNote(
            text: "The ending is still debated. Does the top stop spinning?",
            mediaItem: mediaItem
        )
        
        let view = NoteRowView(note: note, showMediaInfo: true)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_WithActions() {
        let mediaItem = MediaItem(title: "The Matrix", kind: .movie)
        let note = createNote(
            text: "The red pill/blue pill scene is iconic cinema.",
            mediaItem: mediaItem
        )
        
        let view = NoteRowView(
            note: note,
            onEdit: {},
            onDelete: {}
        )
        .padding()
        .frame(width: 375)
        .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_EditedNote() {
        let mediaItem = MediaItem(title: "1984", kind: .book)
        let note = createNote(
            text: "Big Brother is always watching.",
            mediaItem: mediaItem
        )
        // Set editedAt to a fixed date (1 week after creation)
        note.editedAt = fixedDate.addingTimeInterval(-358 * 24 * 3600)
        
        let view = NoteRowView(note: note)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_ShortNote() {
        let mediaItem = MediaItem(title: "Dune", kind: .book)
        let note = createNote(
            text: "Spice must flow.",
            mediaItem: mediaItem
        )
        
        let view = NoteRowView(note: note)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - NoteRowCompactView Tests
    
    func testNoteRowCompactView_Basic() {
        let mediaItem = MediaItem(title: "The Godfather", kind: .movie)
        let note = createNote(
            text: "An offer you can't refuse. This movie defined the gangster genre.",
            mediaItem: mediaItem
        )
        
        let view = NoteRowCompactView(note: note)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowCompactView_WithMediaInfo() {
        let mediaItem = MediaItem(title: "Pulp Fiction", kind: .movie)
        let note = createNote(
            text: "Non-linear storytelling at its finest.",
            mediaItem: mediaItem
        )
        
        let view = NoteRowCompactView(note: note, showMediaInfo: true)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowCompactView_Edited() {
        let mediaItem = MediaItem(title: "Fight Club", kind: .movie)
        let note = createNote(
            text: "First rule of Fight Club...",
            mediaItem: mediaItem
        )
        // Set editedAt to a fixed date (1 week after creation)
        note.editedAt = fixedDate.addingTimeInterval(-358 * 24 * 3600)
        
        let view = NoteRowCompactView(note: note)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Different Media Types
    
    func testNoteRowView_TVSeriesNote() {
        let series = MediaItem(title: "The Sopranos", kind: .tvSeries)
        let note = createNote(
            text: "Tony Soprano is one of the most complex characters in television history.",
            mediaItem: series
        )
        
        let view = NoteRowView(note: note, showMediaInfo: true)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_BookNote() {
        let book = MediaItem(title: "To Kill a Mockingbird", kind: .book)
        let note = createNote(
            text: "Atticus Finch represents moral integrity and justice.",
            mediaItem: book,
            quote: "You never really understand a person until you consider things from his point of view."
        )
        
        let view = NoteRowView(note: note, showMediaInfo: true)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_AlbumNote() {
        let album = MediaItem(title: "The Dark Side of the Moon", kind: .album)
        let note = createNote(
            text: "This album is a masterpiece of progressive rock.",
            mediaItem: album
        )
        
        let view = NoteRowView(note: note, showMediaInfo: true)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testNoteRowView_EventNote() {
        let event = MediaItem(title: "Hamilton on Broadway", kind: .liveEvent)
        let note = createNote(
            text: "The energy and talent on stage was incredible. A once in a lifetime experience.",
            mediaItem: event
        )
        
        let view = NoteRowView(note: note, showMediaInfo: true)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
}
