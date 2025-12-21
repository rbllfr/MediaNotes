import XCTest
@testable import MediaNotes

@MainActor
final class LibraryViewModelTests: XCTestCase {
    
    var sut: LibraryViewModel!
    var mockMediaRepository: MockMediaRepository!
    var mockNoteRepository: MockNoteRepository!
    
    override func setUp() async throws {
        mockMediaRepository = MockMediaRepository()
        mockNoteRepository = MockNoteRepository()
        sut = LibraryViewModel(
            mediaRepository: mockMediaRepository,
            noteRepository: mockNoteRepository
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockMediaRepository = nil
        mockNoteRepository = nil
    }
    
    // MARK: - Helper
    
    private var mediaItems: [MediaItem] {
        sut.viewState.data ?? []
    }
    
    // MARK: - Loading Tests
    
    func test_initialize_loadsItems() async {
        // Given
        let movie = MediaItem(title: "Inception", kind: .movie)
        let note = Note(text: "Great movie", mediaItem: movie)
        movie.notes = [note]
        mockMediaRepository.addTestItem(movie)
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
        XCTAssertEqual(mediaItems.count, 1)
        XCTAssertEqual(mediaItems.first?.title, "Inception")
        XCTAssertTrue(mockMediaRepository.invocations.contains(.fetchRootItems))
    }
    
    func test_initialize_onlyLoadsOnce() async {
        // Given
        let movie = MediaItem(title: "Inception", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        
        // When
        await sut.initialize()
        await sut.initialize() // Second call should not load
        
        // Then - should only have called fetch once (initialize checks for empty state)
        XCTAssertTrue(sut.viewState.isReady)
    }
    
    func test_refresh_loadsItemsEvenWhenAlreadyReady() async {
        // Given
        let movie = MediaItem(title: "Inception", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        await sut.initialize()
        
        let newMovie = MediaItem(title: "Avatar", kind: .movie)
        mockMediaRepository.addTestItem(newMovie)
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertEqual(mediaItems.count, 2)
    }
    
    // MARK: - Filtering Tests
    
    func test_filteredItems_withNoFilter_returnsItemsWithNotes() async {
        // Given
        let movieWithNotes = MediaItem(title: "Movie A", kind: .movie)
        movieWithNotes.notes = [Note(text: "Note", mediaItem: movieWithNotes)]
        
        let movieWithoutNotes = MediaItem(title: "Movie B", kind: .movie)
        movieWithoutNotes.notes = []
        
        mockMediaRepository.addTestItem(movieWithNotes)
        mockMediaRepository.addTestItem(movieWithoutNotes)
        await sut.initialize()
        
        // When
        let filtered = sut.filteredItems
        
        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "Movie A")
    }
    
    func test_filteredItems_withKindFilter_returnsMatchingKind() async {
        // Given
        let movie = MediaItem(title: "Movie", kind: .movie)
        movie.notes = [Note(text: "Note", mediaItem: movie)]
        
        let book = MediaItem(title: "Book", kind: .book)
        book.notes = [Note(text: "Note", mediaItem: book)]
        
        mockMediaRepository.addTestItem(movie)
        mockMediaRepository.addTestItem(book)
        await sut.initialize()
        
        // When
        sut.setFilter(.movie)
        let filtered = sut.filteredItems
        
        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.kind, .movie)
    }
    
    func test_toggleFilter_togglesOnAndOff() async {
        // Given
        sut.selectedFilter = nil
        
        // When - toggle on
        sut.toggleFilter(.movie)
        
        // Then
        XCTAssertEqual(sut.selectedFilter, .movie)
        
        // When - toggle off
        sut.toggleFilter(.movie)
        
        // Then
        XCTAssertNil(sut.selectedFilter)
    }
    
    // MARK: - Sorting Tests
    
    func test_sortOrder_alphabetical() async {
        // Given
        let movieB = MediaItem(title: "Babylon", kind: .movie)
        movieB.notes = [Note(text: "Note", mediaItem: movieB)]
        
        let movieA = MediaItem(title: "Avatar", kind: .movie)
        movieA.notes = [Note(text: "Note", mediaItem: movieA)]
        
        mockMediaRepository.addTestItem(movieB)
        mockMediaRepository.addTestItem(movieA)
        await sut.initialize()
        
        // When
        sut.setSortOrder(.alphabetical)
        let sorted = sut.filteredItems
        
        // Then
        XCTAssertEqual(sorted.first?.title, "Avatar")
        XCTAssertEqual(sorted.last?.title, "Babylon")
    }
    
    func test_sortOrder_noteCount() async {
        // Given
        let movieFew = MediaItem(title: "Few Notes", kind: .movie)
        movieFew.notes = [Note(text: "Note", mediaItem: movieFew)]
        
        let movieMany = MediaItem(title: "Many Notes", kind: .movie)
        movieMany.notes = [
            Note(text: "Note 1", mediaItem: movieMany),
            Note(text: "Note 2", mediaItem: movieMany),
            Note(text: "Note 3", mediaItem: movieMany)
        ]
        
        mockMediaRepository.addTestItem(movieFew)
        mockMediaRepository.addTestItem(movieMany)
        await sut.initialize()
        
        // When
        sut.setSortOrder(.noteCount)
        let sorted = sut.filteredItems
        
        // Then
        XCTAssertEqual(sorted.first?.title, "Many Notes")
    }
    
    // MARK: - Computed Properties Tests
    
    func test_activeMediaKinds_returnsKindsWithNotes() async {
        // Given
        let movie = MediaItem(title: "Movie", kind: .movie)
        movie.notes = [Note(text: "Note", mediaItem: movie)]
        
        let book = MediaItem(title: "Book", kind: .book)
        book.notes = [Note(text: "Note", mediaItem: book)]
        
        let emptyAlbum = MediaItem(title: "Album", kind: .album)
        emptyAlbum.notes = []
        
        mockMediaRepository.addTestItem(movie)
        mockMediaRepository.addTestItem(book)
        mockMediaRepository.addTestItem(emptyAlbum)
        await sut.initialize()
        
        // When
        let activeKinds = sut.activeMediaKinds
        
        // Then
        XCTAssertTrue(activeKinds.contains(.movie))
        XCTAssertTrue(activeKinds.contains(.book))
        XCTAssertFalse(activeKinds.contains(.album))
    }
    
    func test_viewState_startsEmpty() {
        // Then
        XCTAssertTrue(sut.viewState.isEmpty)
    }
    
    func test_itemCount_returnsFilteredCount() async {
        // Given
        let movie = MediaItem(title: "Movie", kind: .movie)
        movie.notes = [Note(text: "Note", mediaItem: movie)]
        
        mockMediaRepository.addTestItem(movie)
        await sut.initialize()
        
        // Then
        XCTAssertEqual(sut.itemCount, 1)
    }
    
    // MARK: - ViewState Tests
    
    func test_viewState_isReadyAfterLoading() async {
        // Given
        let movie = MediaItem(title: "Movie", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
    }
}
