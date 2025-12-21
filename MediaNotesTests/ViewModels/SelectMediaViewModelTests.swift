import XCTest
@testable import MediaNotes

@MainActor
final class SelectMediaViewModelTests: XCTestCase {
    
    var sut: SelectMediaViewModel!
    var mockMediaRepository: MockMediaRepository!
    
    override func setUp() async throws {
        mockMediaRepository = MockMediaRepository()
        sut = SelectMediaViewModel(mediaRepository: mockMediaRepository)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockMediaRepository = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_init_startsWithEmptyViewState() {
        // Then
        XCTAssertTrue(sut.viewState.isEmpty)
    }
    
    func test_init_startsWithEmptySearchText() {
        // Then
        XCTAssertTrue(sut.searchText.isEmpty)
    }
    
    func test_init_startsWithNoKindFilter() {
        // Then
        XCTAssertNil(sut.selectedKind)
    }
    
    // MARK: - Initialize Tests
    
    func test_initialize_loadsMediaItems() async {
        // Given
        let item1 = MediaItem(title: "Movie 1", kind: .movie)
        let item2 = MediaItem(title: "Series 1", kind: .tvSeries)
        mockMediaRepository.setFetchAllResult(.success([item1, item2]))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
        let items = sut.viewState.data ?? []
        XCTAssertEqual(items.count, 2)
    }
    
    func test_initialize_doesNotLoadWhenAlreadyLoaded() async {
        // Given
        mockMediaRepository.setFetchAllResult(.success([]))
        await sut.initialize()
        mockMediaRepository.reset()
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertEqual(mockMediaRepository.invocations.count, 0)
    }
    
    func test_initialize_setsErrorOnFailure() async {
        // Given
        mockMediaRepository.setFetchAllResult(.failure(NSError(domain: "test", code: 1)))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isError)
    }
    
    // MARK: - Refresh Tests
    
    func test_refresh_reloadsMediaItems() async {
        // Given
        let item = MediaItem(title: "Movie", kind: .movie)
        mockMediaRepository.setFetchAllResult(.success([item]))
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertTrue(mockMediaRepository.invocations.contains(.fetchAll))
        XCTAssertTrue(sut.viewState.isReady)
    }
    
    // MARK: - Filtered Items Tests
    
    func test_filteredItems_returnsAllItemsWhenNoFilters() async {
        // Given
        let item1 = MediaItem(title: "Movie", kind: .movie)
        let item2 = MediaItem(title: "Series", kind: .tvSeries)
        mockMediaRepository.setFetchAllResult(.success([item1, item2]))
        await sut.initialize()
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 2)
    }
    
    func test_filteredItems_filtersByKind() async {
        // Given
        let movie = MediaItem(title: "Movie", kind: .movie)
        let series = MediaItem(title: "Series", kind: .tvSeries)
        mockMediaRepository.setFetchAllResult(.success([movie, series]))
        await sut.initialize()
        
        // When
        sut.selectedKind = .movie
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 1)
        XCTAssertEqual(sut.filteredItems.first?.kind, .movie)
    }
    
    func test_filteredItems_filtersBySearchText() async {
        // Given
        let movie1 = MediaItem(title: "Inception", kind: .movie)
        let movie2 = MediaItem(title: "Interstellar", kind: .movie)
        let movie3 = MediaItem(title: "The Matrix", kind: .movie)
        mockMediaRepository.setFetchAllResult(.success([movie1, movie2, movie3]))
        await sut.initialize()
        
        // When
        sut.searchText = "inter"
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 1)
        XCTAssertEqual(sut.filteredItems.first?.title, "Interstellar")
    }
    
    func test_filteredItems_searchIsCaseInsensitive() async {
        // Given
        let movie = MediaItem(title: "Inception", kind: .movie)
        mockMediaRepository.setFetchAllResult(.success([movie]))
        await sut.initialize()
        
        // When
        sut.searchText = "INCEPTION"
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 1)
    }
    
    func test_filteredItems_searchesSubtitle() async {
        // Given
        let movie = MediaItem(title: "Inception", kind: .movie, subtitle: "Christopher Nolan")
        mockMediaRepository.setFetchAllResult(.success([movie]))
        await sut.initialize()
        
        // When
        sut.searchText = "Nolan"
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 1)
    }
    
    func test_filteredItems_combinesFilters() async {
        // Given
        let movie = MediaItem(title: "Inception", kind: .movie)
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        mockMediaRepository.setFetchAllResult(.success([movie, series]))
        await sut.initialize()
        
        // When
        sut.selectedKind = .movie
        sut.searchText = "Incep"
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 1)
        XCTAssertEqual(sut.filteredItems.first?.title, "Inception")
    }
    
    // MARK: - Parent Items Tests
    
    func test_parentItems_returnsOnlyRootItems() async {
        // Given
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        let episode = MediaItem(title: "Pilot", kind: .episode)
        episode.parent = series
        series.addChild(episode)
        mockMediaRepository.setFetchAllResult(.success([series, episode]))
        await sut.initialize()
        
        // Then
        XCTAssertEqual(sut.parentItems.count, 1)
        XCTAssertEqual(sut.parentItems.first?.title, "Breaking Bad")
    }
    
    // MARK: - Recently Used Tests
    
    func test_recentlyUsed_returnsUpToFiveItems() async {
        // Given
        let items = (1...10).map { MediaItem(title: "Item \($0)", kind: .movie) }
        mockMediaRepository.setFetchAllResult(.success(items))
        await sut.initialize()
        
        // Then
        XCTAssertEqual(sut.recentlyUsed.count, 5)
    }
    
    func test_recentlyUsed_returnsAllWhenLessThanFive() async {
        // Given
        let item1 = MediaItem(title: "Movie 1", kind: .movie)
        let item2 = MediaItem(title: "Movie 2", kind: .movie)
        mockMediaRepository.setFetchAllResult(.success([item1, item2]))
        await sut.initialize()
        
        // Then
        XCTAssertEqual(sut.recentlyUsed.count, 2)
    }
    
    // MARK: - Clear Search Tests
    
    func test_clearSearch_clearsSearchText() {
        // Given
        sut.searchText = "test"
        
        // When
        sut.clearSearch()
        
        // Then
        XCTAssertTrue(sut.searchText.isEmpty)
    }
}

