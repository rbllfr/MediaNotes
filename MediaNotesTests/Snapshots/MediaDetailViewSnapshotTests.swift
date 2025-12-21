import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class MediaDetailViewSnapshotTests: XCTestCase {
    
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
    
    // MARK: - Basic Views
    
    func testMediaDetailView_Movie() {
        let movie = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        let viewModel = MockMediaDetailViewModel(mediaItem: movie, viewState: .ready([]))
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaDetailView_MovieWithNotes() {
        let movie = MediaItem(title: "The Matrix", kind: .movie, subtitle: "Wachowskis")
        let note1 = createNote(text: "Revolutionary visual effects and storytelling.", mediaItem: movie)
        let note2 = createNote(
            text: "The red pill/blue pill scene is iconic.",
            mediaItem: movie,
            quote: "What is real?"
        )
        movie.notes = [note1, note2]
        
        let viewModel = MockMediaDetailViewModel(mediaItem: movie, viewState: .ready([note1, note2]))
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - TV Series with Episodes
    
    func testMediaDetailView_TVSeriesWithEpisodes() {
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
        
        let ep1 = MediaItem(title: "Pilot", kind: .episode, sortKey: "S01E01", parent: series)
        let ep2 = MediaItem(title: "Ozymandias", kind: .episode, sortKey: "S05E14", parent: series)
        
        series.addChild(ep1)
        series.addChild(ep2)
        
        let note1 = createNote(text: "Great pilot episode", mediaItem: ep1)
        ep1.notes = [note1]
        
        let viewModel = MockMediaDetailViewModel(mediaItem: series, viewState: .ready([note1]))
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Book with Chapters
    
    func testMediaDetailView_BookWithChapters() {
        let book = MediaItem(title: "The Great Gatsby", kind: .book, subtitle: "F. Scott Fitzgerald")
        
        let ch1 = MediaItem(title: "Chapter 1", kind: .chapter, sortKey: "01", parent: book)
        let ch2 = MediaItem(title: "Chapter 2", kind: .chapter, sortKey: "02", parent: book)
        
        book.addChild(ch1)
        book.addChild(ch2)
        
        let note1 = createNote(text: "Great introduction to the characters.", mediaItem: ch1)
        ch1.notes = [note1]
        
        let viewModel = MockMediaDetailViewModel(mediaItem: book, viewState: .ready([note1]))
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Empty States
    
    func testMediaDetailView_NoNotes() {
        let movie = MediaItem(title: "Pulp Fiction", kind: .movie, subtitle: "Quentin Tarantino")
        let viewModel = MockMediaDetailViewModel(mediaItem: movie, viewState: .ready([]))
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Loading State
    
    func testMediaDetailView_LoadingState() {
        let movie = MediaItem(title: "The Godfather", kind: .movie)
        let viewModel = MockMediaDetailViewModel(mediaItem: movie, viewState: .loading)
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Error State
    
    func testMediaDetailView_ErrorState() {
        let movie = MediaItem(title: "Fight Club", kind: .movie)
        let viewModel = MockMediaDetailViewModel(
            mediaItem: movie,
            viewState: .error("Failed to load notes")
        )
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Album with Tracks
    
    func testMediaDetailView_AlbumWithTracks() {
        let album = MediaItem(title: "Dark Side of the Moon", kind: .album, subtitle: "Pink Floyd")
        
        let track1 = MediaItem(title: "Time", kind: .track, sortKey: "04", parent: album)
        let track2 = MediaItem(title: "Money", kind: .track, sortKey: "06", parent: album)
        
        album.addChild(track1)
        album.addChild(track2)
        
        let note1 = createNote(text: "Timeless classic", mediaItem: track1)
        track1.notes = [note1]
        
        let viewModel = MockMediaDetailViewModel(mediaItem: album, viewState: .ready([note1]))
        
        let view = MediaDetailView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
}
