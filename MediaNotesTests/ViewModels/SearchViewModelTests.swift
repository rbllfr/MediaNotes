import XCTest
@testable import MediaNotes

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    var sut: SearchViewModel!
    var mockMediaRepository: MockMediaRepository!
    var mockNoteRepository: MockNoteRepository!
    
    override func setUp() async throws {
        mockMediaRepository = MockMediaRepository()
        mockNoteRepository = MockNoteRepository()
        sut = SearchViewModel(
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
    
    private var searchResults: SearchResults {
        sut.viewState.data ?? .empty
    }
    
    // MARK: - Search Tests
    
    func test_search_withEmptyQuery_clearsResults() async {
        // Given
        sut.searchText = ""
        
        // When
        await sut.search()
        
        // Then
        XCTAssertTrue(searchResults.isEmpty)
        XCTAssertTrue(sut.viewState.isReady)
    }
    
    func test_search_withWhitespaceOnly_clearsResults() async {
        // Given
        sut.searchText = "   "
        
        // When
        await sut.search()
        
        // Then
        XCTAssertTrue(searchResults.isEmpty)
    }
    
    func test_search_findsMatchingMedia() async {
        // Given
        let movie = MediaItem(title: "Inception", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        sut.searchText = "Inception"
        
        // When
        await sut.search()
        
        // Then
        XCTAssertEqual(searchResults.mediaItems.count, 1)
        XCTAssertEqual(searchResults.mediaItems.first?.title, "Inception")
        XCTAssertTrue(mockMediaRepository.invocations.contains(.fetchItemsMatching(searchText: "Inception")))
    }
    
    func test_search_findsMatchingNotes() async {
        // Given
        let media = MediaItem(title: "Movie", kind: .movie)
        let note = Note(text: "This movie is amazing!", mediaItem: media)
        mockNoteRepository.addTestNote(note)
        sut.searchText = "amazing"
        
        // When
        await sut.search()
        
        // Then
        XCTAssertEqual(searchResults.notes.count, 1)
        XCTAssertTrue(searchResults.notes.first?.text.contains("amazing") ?? false)
    }
    
    func test_search_caseInsensitive() async {
        // Given
        let movie = MediaItem(title: "INCEPTION", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        sut.searchText = "inception"
        
        // When
        await sut.search()
        
        // Then
        XCTAssertEqual(searchResults.mediaItems.count, 1)
    }
    
    // MARK: - Scope Tests
    
    func test_filteredMediaResults_respectsScope() async {
        // Given
        let movie = MediaItem(title: "Test", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        sut.searchText = "Test"
        await sut.search()
        
        // When - media only
        sut.setScope(.media)
        
        // Then
        XCTAssertEqual(sut.filteredMediaResults.count, 1)
        
        // When - notes only
        sut.setScope(.notes)
        
        // Then
        XCTAssertTrue(sut.filteredMediaResults.isEmpty)
    }
    
    func test_filteredNoteResults_respectsScope() async {
        // Given
        let media = MediaItem(title: "Movie", kind: .movie)
        let note = Note(text: "Test note", mediaItem: media)
        mockNoteRepository.addTestNote(note)
        sut.searchText = "Test"
        await sut.search()
        
        // When - notes only
        sut.setScope(.notes)
        
        // Then
        XCTAssertEqual(sut.filteredNoteResults.count, 1)
        
        // When - media only
        sut.setScope(.media)
        
        // Then
        XCTAssertTrue(sut.filteredNoteResults.isEmpty)
    }
    
    func test_allScope_showsBothResults() async {
        // Given
        let movie = MediaItem(title: "Test Movie", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        
        let note = Note(text: "Test note", mediaItem: movie)
        mockNoteRepository.addTestNote(note)
        
        sut.searchText = "Test"
        sut.setScope(.all)
        
        // When
        await sut.search()
        
        // Then
        XCTAssertEqual(sut.filteredMediaResults.count, 1)
        XCTAssertEqual(sut.filteredNoteResults.count, 1)
    }
    
    // MARK: - Computed Properties Tests
    
    func test_hasResults_trueWhenMediaFound() async {
        // Given
        let movie = MediaItem(title: "Test", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        sut.searchText = "Test"
        
        // When
        await sut.search()
        
        // Then
        XCTAssertTrue(sut.hasResults)
    }
    
    func test_hasResults_falseWhenNoResults() async {
        // Given
        sut.searchText = "NonexistentQuery"
        
        // When
        await sut.search()
        
        // Then
        XCTAssertFalse(sut.hasResults)
    }
    
    // MARK: - Clear Tests
    
    func test_clearSearch_resetsEverything() async {
        // Given
        let movie = MediaItem(title: "Test", kind: .movie)
        mockMediaRepository.addTestItem(movie)
        sut.searchText = "Test"
        await sut.search()
        
        // When
        sut.clearSearch()
        
        // Then
        XCTAssertEqual(sut.searchText, "")
        XCTAssertTrue(searchResults.isEmpty)
    }
    
    // MARK: - Result Count Tests
    
    func test_mediaResultCount_returnsCorrectCount() async {
        // Given
        mockMediaRepository.addTestItem(MediaItem(title: "Test 1", kind: .movie))
        mockMediaRepository.addTestItem(MediaItem(title: "Test 2", kind: .movie))
        sut.searchText = "Test"
        sut.setScope(.all)
        
        // When
        await sut.search()
        
        // Then
        XCTAssertEqual(sut.mediaResultCount, 2)
    }
    
    // MARK: - Highlight Tests
    
    func test_highlightedText_highlightsMatch() {
        // Given
        sut.searchText = "great"
        
        // When
        let highlighted = sut.highlightedText("This is a great movie")
        
        // Then - attributed string contains the text
        XCTAssertTrue(String(highlighted.characters).contains("great"))
    }
    
    // MARK: - ViewState Tests
    
    func test_viewState_startsReady() {
        XCTAssertTrue(sut.viewState.isReady)
    }
    
    func test_viewState_isReadyAfterSearch() async {
        // Given
        sut.searchText = "Test"
        
        // When
        await sut.search()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
    }
}
