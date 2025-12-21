import XCTest
import SwiftData
@testable import MediaNotes

@MainActor
final class MediaListViewModelTests: XCTestCase {
    
    var sut: MediaListViewModel!
    var mockRepository: MockMediaRepository!
    
    override func setUp() async throws {
        mockRepository = MockMediaRepository()
        sut = MediaListViewModel(mediaRepository: mockRepository)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_initialize_startsWithEmptyState() async {
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertNil(sut.selectedFilter)
        XCTAssertEqual(sut.sortOrder, .recentlyAdded)
        XCTAssertEqual(sut.itemCount, 0)
    }
    
    func test_initialize_loadsAllMediaItems() async {
        // Given
        let book = MediaItem(title: "Test Book", kind: .book)
        let movie = MediaItem(title: "Test Movie", kind: .movie)
        mockRepository.addTestItem(book)
        mockRepository.addTestItem(movie)
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
        XCTAssertEqual(sut.filteredItems.count, 2)
    }
    
    func test_initialize_onlyLoadsOnce() async {
        // Given
        let book = MediaItem(title: "Test Book", kind: .book)
        mockRepository.addTestItem(book)
        
        // When
        await sut.initialize()
        await sut.initialize()
        
        // Then
        let fetchRootItemsCount = mockRepository.invocations.filter { 
            if case .fetchRootItems = $0 { return true }
            return false
        }.count
        XCTAssertEqual(fetchRootItemsCount, 1)
    }
    
    func test_initialize_handlesError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isError)
    }
    
    // MARK: - Refresh Tests
    
    func test_refresh_reloadsData() async {
        // Given
        let book = MediaItem(title: "Test Book", kind: .book)
        mockRepository.addTestItem(book)
        await sut.initialize()
        
        let movie = MediaItem(title: "Test Movie", kind: .movie)
        mockRepository.addTestItem(movie)
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 2)
    }
    
    func test_refresh_doesNotRefreshWhenNotReady() async {
        // Given - state is empty
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertFalse(mockRepository.invocations.contains(.fetchRootItems))
    }
    
    // MARK: - Filter Tests
    
    func test_setFilter_filtersMediaByKind() async {
        // Given
        let book = MediaItem(title: "Test Book", kind: .book)
        let movie = MediaItem(title: "Test Movie", kind: .movie)
        mockRepository.addTestItem(book)
        mockRepository.addTestItem(movie)
        await sut.initialize()
        
        // When
        sut.setFilter(.book)
        
        // Then
        XCTAssertEqual(sut.filteredItems.count, 1)
        XCTAssertEqual(sut.filteredItems.first?.kind, .book)
    }
    
    func test_toggleFilter_togglesFilterOnAndOff() async {
        // Given
        let book = MediaItem(title: "Test Book", kind: .book)
        mockRepository.addTestItem(book)
        await sut.initialize()
        
        // When - toggle on
        sut.toggleFilter(.book)
        
        // Then
        XCTAssertEqual(sut.selectedFilter, .book)
        
        // When - toggle off
        sut.toggleFilter(.book)
        
        // Then
        XCTAssertNil(sut.selectedFilter)
    }
    
    func test_activeMediaKinds_returnsUniqueKinds() async {
        // Given
        let book1 = MediaItem(title: "Book 1", kind: .book)
        let book2 = MediaItem(title: "Book 2", kind: .book)
        let movie = MediaItem(title: "Movie", kind: .movie)
        mockRepository.addTestItem(book1)
        mockRepository.addTestItem(book2)
        mockRepository.addTestItem(movie)
        await sut.initialize()
        
        // When
        let kinds = sut.activeMediaKinds
        
        // Then
        XCTAssertEqual(kinds.count, 2)
        XCTAssertTrue(kinds.contains(.book))
        XCTAssertTrue(kinds.contains(.movie))
    }
    
    // MARK: - Sort Tests
    
    func test_setSortOrder_recentlyAdded_sortsCorrectly() async {
        // Given
        let book = MediaItem(title: "B Book", kind: .book)
        let movie = MediaItem(title: "A Movie", kind: .movie)
        // Ensure different creation dates
        await Task.yield()
        mockRepository.addTestItem(book)
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        mockRepository.addTestItem(movie)
        await sut.initialize()
        
        // When
        sut.setSortOrder(.recentlyAdded)
        
        // Then
        let sorted = sut.filteredItems
        XCTAssertEqual(sorted.first?.title, "A Movie")
    }
    
    func test_setSortOrder_alphabetical_sortsCorrectly() async {
        // Given
        let book = MediaItem(title: "Z Book", kind: .book)
        let movie = MediaItem(title: "A Movie", kind: .movie)
        mockRepository.addTestItem(book)
        mockRepository.addTestItem(movie)
        await sut.initialize()
        
        // When
        sut.setSortOrder(.alphabetical)
        
        // Then
        let sorted = sut.filteredItems
        XCTAssertEqual(sorted.first?.title, "A Movie")
        XCTAssertEqual(sorted.last?.title, "Z Book")
    }
    
    func test_setSortOrder_noteCount_sortsCorrectly() async {
        // Given - Create items with different note counts
        let bookWithNotes = MediaItem(title: "Book", kind: .book)
        let movieWithoutNotes = MediaItem(title: "Movie", kind: .movie)
        
        mockRepository.addTestItem(bookWithNotes)
        mockRepository.addTestItem(movieWithoutNotes)
        await sut.initialize()
        
        // When
        sut.setSortOrder(.noteCount)
        
        // Then - items should be sorted by note count
        let sorted = sut.filteredItems
        XCTAssertEqual(sorted.count, 2)
    }
    
    // MARK: - Computed Properties Tests
    
    func test_itemCount_returnsFilteredCount() async {
        // Given
        let book = MediaItem(title: "Test Book", kind: .book)
        let movie = MediaItem(title: "Test Movie", kind: .movie)
        mockRepository.addTestItem(book)
        mockRepository.addTestItem(movie)
        await sut.initialize()
        
        // When - no filter
        let totalCount = sut.itemCount
        
        // Then
        XCTAssertEqual(totalCount, 2)
        
        // When - with filter
        sut.setFilter(.book)
        let filteredCount = sut.itemCount
        
        // Then
        XCTAssertEqual(filteredCount, 1)
    }
}

