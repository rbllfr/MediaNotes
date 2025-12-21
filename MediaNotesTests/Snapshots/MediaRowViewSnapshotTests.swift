import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class MediaRowViewSnapshotTests: XCTestCase {
    
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }
    
    // MARK: - MediaRowView Tests
    
    func testMediaRowView_Movie() {
        let mediaItem = MediaItem(
            title: "Inception",
            kind: .movie,
            subtitle: "Christopher Nolan"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_TVSeries() {
        let mediaItem = MediaItem(
            title: "Breaking Bad",
            kind: .tvSeries,
            subtitle: "Vince Gilligan"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_Book() {
        let mediaItem = MediaItem(
            title: "The Great Gatsby",
            kind: .book,
            subtitle: "F. Scott Fitzgerald"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_Album() {
        let mediaItem = MediaItem(
            title: "Abbey Road",
            kind: .album,
            subtitle: "The Beatles"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_LiveEvent() {
        let mediaItem = MediaItem(
            title: "Hamilton",
            kind: .liveEvent,
            subtitle: "Broadway"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_LongTitle() {
        let mediaItem = MediaItem(
            title: "The Lord of the Rings: The Fellowship of the Ring",
            kind: .movie,
            subtitle: "Peter Jackson"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_NoSubtitle() {
        let mediaItem = MediaItem(
            title: "Unknown Media",
            kind: .other
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_WithChildren() {
        let series = MediaItem(
            title: "Game of Thrones",
            kind: .tvSeries,
            subtitle: "HBO"
        )
        let ep1 = MediaItem(title: "Winter Is Coming", kind: .episode, parent: series)
        let ep2 = MediaItem(title: "The Kingsroad", kind: .episode, parent: series)
        series.addChild(ep1)
        series.addChild(ep2)
        
        let view = MediaRowView(mediaItem: series)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - MediaRowCompactView Tests
    
    func testMediaRowCompactView_Movie() {
        let mediaItem = MediaItem(
            title: "The Matrix",
            kind: .movie,
            subtitle: "Wachowskis"
        )
        
        let view = MediaRowCompactView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowCompactView_Book() {
        let mediaItem = MediaItem(
            title: "1984",
            kind: .book,
            subtitle: "George Orwell"
        )
        
        let view = MediaRowCompactView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowCompactView_WithoutNoteCount() {
        let mediaItem = MediaItem(
            title: "Blade Runner",
            kind: .movie,
            subtitle: "Ridley Scott"
        )
        
        let view = MediaRowCompactView(mediaItem: mediaItem, showNoteCount: false)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowCompactView_NoSubtitle() {
        let mediaItem = MediaItem(
            title: "Unknown Album",
            kind: .album
        )
        
        let view = MediaRowCompactView(mediaItem: mediaItem)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - All Media Kinds
    
    func testMediaRowView_AllKinds() {
        let view = VStack(spacing: Theme.spacingSM) {
            ForEach(MediaKind.allCases.prefix(5)) { kind in
                MediaRowView(mediaItem: MediaItem(
                    title: kind.displayName,
                    kind: kind,
                    subtitle: "Test Subtitle"
                ))
            }
        }
        .padding()
        .frame(width: 375)
        .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Different Sizes
    
    func testMediaRowView_SmallDevice() {
        let mediaItem = MediaItem(
            title: "The Godfather",
            kind: .movie,
            subtitle: "Francis Ford Coppola"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 320)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_LargeDevice() {
        let mediaItem = MediaItem(
            title: "Pulp Fiction",
            kind: .movie,
            subtitle: "Quentin Tarantino"
        )
        
        let view = MediaRowView(mediaItem: mediaItem)
            .padding()
            .frame(width: 428)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Episode View
    
    func testMediaRowView_Episode() {
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let episode = MediaItem(
            title: "Ozymandias",
            kind: .episode,
            sortKey: "S05E14",
            parent: series
        )
        
        let view = MediaRowView(mediaItem: episode)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_Track() {
        let album = MediaItem(title: "Dark Side of the Moon", kind: .album)
        let track = MediaItem(
            title: "Time",
            kind: .track,
            sortKey: "04",
            parent: album
        )
        
        let view = MediaRowView(mediaItem: track)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_Chapter() {
        let book = MediaItem(title: "Harry Potter", kind: .book)
        let chapter = MediaItem(
            title: "The Boy Who Lived",
            kind: .chapter,
            sortKey: "01",
            parent: book
        )
        
        let view = MediaRowView(mediaItem: chapter)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaRowView_Performance() {
        let event = MediaItem(title: "Coachella 2024", kind: .liveEvent)
        let performance = MediaItem(
            title: "Headline Performance",
            kind: .performance,
            parent: event
        )
        
        let view = MediaRowView(mediaItem: performance)
            .padding()
            .frame(width: 375)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
}
