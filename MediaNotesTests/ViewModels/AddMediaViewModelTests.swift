import XCTest
@testable import MediaNotes

@MainActor
final class AddMediaViewModelTests: XCTestCase {
    
    var sut: AddMediaViewModel!
    var mockMediaRepository: MockMediaRepository!
    
    override func setUp() async throws {
        mockMediaRepository = MockMediaRepository()
        sut = AddMediaViewModel(mediaRepository: mockMediaRepository)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockMediaRepository = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_init_startsWithMovieKind() {
        // Then
        XCTAssertEqual(sut.selectedKind, .movie)
    }
    
    func test_init_startsWithEmptyFields() {
        // Then
        XCTAssertTrue(sut.title.isEmpty)
        XCTAssertTrue(sut.subtitle.isEmpty)
        XCTAssertTrue(sut.artworkURL.isEmpty)
        XCTAssertTrue(sut.sortKey.isEmpty)
    }
    
    func test_init_startsWithSuggestedAttributes() {
        // Then
        XCTAssertFalse(sut.attributes.isEmpty)
    }
    
    func test_init_startsNotSaving() {
        // Then
        XCTAssertFalse(sut.isSaving)
    }
    
    // MARK: - Can Save Tests
    
    func test_canSave_falseWhenTitleEmpty() {
        // Given
        sut.title = ""
        
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_falseWhenTitleOnlyWhitespace() {
        // Given
        sut.title = "   \n\t  "
        
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_trueWhenTitleValid() {
        // Given
        sut.title = "Inception"
        
        // Then
        XCTAssertTrue(sut.canSave)
    }
    
    // MARK: - Accent Color Tests
    
    func test_accentColor_returnsColorForSelectedKind() {
        // Given
        sut.selectedKind = .movie
        
        // Then
        XCTAssertEqual(sut.accentColor, Theme.color(for: .movie))
    }
    
    func test_accentColor_updatesWhenKindChanges() {
        // Given
        sut.selectedKind = .movie
        let movieColor = sut.accentColor
        
        // When
        sut.selectedKind = .tvSeries
        let seriesColor = sut.accentColor
        
        // Then
        XCTAssertNotEqual(movieColor, seriesColor)
    }
    
    // MARK: - Should Show Parent Selector Tests
    
    func test_shouldShowParentSelector_trueForEpisode() {
        // Given
        sut.selectedKind = .episode
        
        // Then
        XCTAssertTrue(sut.shouldShowParentSelector)
    }
    
    func test_shouldShowParentSelector_trueForChapter() {
        // Given
        sut.selectedKind = .chapter
        
        // Then
        XCTAssertTrue(sut.shouldShowParentSelector)
    }
    
    func test_shouldShowParentSelector_falseForMovie() {
        // Given
        sut.selectedKind = .movie
        
        // Then
        XCTAssertFalse(sut.shouldShowParentSelector)
    }
    
    // MARK: - Parent Kind Tests
    
    func test_parentKind_tvSeriesForEpisode() {
        // Given
        sut.selectedKind = .episode
        
        // Then
        XCTAssertEqual(sut.parentKind, .tvSeries)
    }
    
    func test_parentKind_bookForChapter() {
        // Given
        sut.selectedKind = .chapter
        
        // Then
        XCTAssertEqual(sut.parentKind, .book)
    }
    
    func test_parentKind_nilForMovie() {
        // Given
        sut.selectedKind = .movie
        
        // Then
        XCTAssertNil(sut.parentKind)
    }
    
    // MARK: - Subtitle Label Tests
    
    func test_subtitleLabel_directorForMovie() {
        // Given
        sut.selectedKind = .movie
        
        // Then
        XCTAssertEqual(sut.subtitleLabel, "Director")
    }
    
    func test_subtitleLabel_authorForBook() {
        // Given
        sut.selectedKind = .book
        
        // Then
        XCTAssertEqual(sut.subtitleLabel, "Author")
    }
    
    // MARK: - Select Kind Tests
    
    func test_selectKind_updatesSelectedKind() {
        // When
        sut.selectKind(.tvSeries)
        
        // Then
        XCTAssertEqual(sut.selectedKind, .tvSeries)
    }
    
    func test_selectKind_resetsAttributes() {
        // Given
        sut.selectedKind = .movie
        sut.addAttribute(key: .init(rawValue: "attribute"), value: "value")
        
        // When
        sut.selectKind(.book)
        
        // Then
        XCTAssertNotEqual(sut.attributes.last?.key.rawValue, "attribute")
    }
    
    func test_selectKind_clearsParentWhenNotHierarchical() {
        // Given
        sut.selectedKind = .episode
        sut.selectedParent = MediaItem(title: "Series", kind: .tvSeries)
        
        // When
        sut.selectKind(.movie)
        
        // Then
        XCTAssertNil(sut.selectedParent)
    }
    
    // MARK: - Attributes Tests
    
    func test_addAttribute_addsNewAttribute() {
        // Given
        let initialCount = sut.attributes.count
        
        // When
        sut.addAttribute(key: .genre, value: "Drama")
        
        // Then
        XCTAssertEqual(sut.attributes.count, initialCount + 1)
        XCTAssertTrue(sut.attributes.contains { $0.key == .genre })
    }
    
    func test_removeAttribute_removesAttribute() {
        // Given
        sut.addAttribute(key: .init(rawValue: "attribute"), value: "value")
        let attributeToRemove = sut.attributes.first { $0.key.rawValue == "attribute" }!
        
        // When
        sut.removeAttribute(id: attributeToRemove.id)
        
        // Then
        XCTAssertFalse(sut.attributes.contains { $0.key.rawValue == "attribute" })
    }
    
    // MARK: - Initialize Tests
    
    func test_initialize_loadsParentMediaItems() async {
        // Given
        let series = MediaItem(title: "Series", kind: .tvSeries)
        mockMediaRepository.setFetchAllResult(.success([series]))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertEqual(sut.parentMediaItems.count, 1)
    }
    
    func test_initialize_setsErrorOnFailure() async {
        // Given
        mockMediaRepository.setFetchAllResult(.failure(NSError(domain: "test", code: 1)))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertNotNil(sut.error)
    }
    
    // MARK: - Filtered Parents Tests
    
    func test_filteredParents_returnsOnlyMatchingKind() async {
        // Given
        let series = MediaItem(title: "Series", kind: .tvSeries)
        let movie = MediaItem(title: "Movie", kind: .movie)
        mockMediaRepository.setFetchAllResult(.success([series, movie]))
        await sut.initialize()
        sut.selectedKind = .episode
        
        // Then
        XCTAssertEqual(sut.filteredParents.count, 1)
        XCTAssertEqual(sut.filteredParents.first?.kind, .tvSeries)
    }
    
    // MARK: - Save Tests
    
    func test_save_successWithValidData() async {
        // Given
        sut.title = "Inception"
        sut.subtitle = "Christopher Nolan"
        sut.selectedKind = .movie
        mockMediaRepository.setSaveResult(.success(()))
        
        // When
        let savedItem = await sut.save()
        
        // Then
        XCTAssertNotNil(savedItem)
        XCTAssertEqual(savedItem?.title, "Inception")
        XCTAssertTrue(mockMediaRepository.invocations.contains(where: { 
            if case .save = $0 { return true }
            return false
        }))
    }
    
    func test_save_trimsWhitespace() async {
        // Given
        sut.title = "  Inception  "
        sut.subtitle = "  Christopher Nolan  "
        mockMediaRepository.setSaveResult(.success(()))
        
        // When
        let savedItem = await sut.save()
        
        // Then
        XCTAssertEqual(savedItem?.title, "Inception")
        XCTAssertEqual(savedItem?.subtitle, "Christopher Nolan")
    }
    
    func test_save_omitsEmptyOptionalFields() async {
        // Given
        sut.title = "Inception"
        sut.subtitle = "   "
        sut.artworkURL = "   "
        mockMediaRepository.setSaveResult(.success(()))
        
        // When
        let savedItem = await sut.save()
        
        // Then
        XCTAssertNil(savedItem?.subtitle)
        XCTAssertNil(savedItem?.artworkURL)
    }
    
    func test_save_includesNonEmptyAttributes() async {
        // Given
        sut.title = "Inception"
        sut.addAttribute(key: .genre, value: "Sci-Fi")
        mockMediaRepository.setSaveResult(.success(()))
        
        // When
        let savedItem = await sut.save()
        
        // Then
        XCTAssertNotNil(savedItem)
        let genreAttribute = savedItem?.attributes?.first { $0.attributeKey == .genre }
        XCTAssertEqual(genreAttribute?.value, "Sci-Fi")
    }
    
    func test_save_addsChildToParent() async {
        // Given
        sut.title = "Pilot"
        sut.selectedKind = .episode
        let series = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        sut.selectedParent = series
        mockMediaRepository.setSaveResult(.success(()))
        
        // When
        let savedItem = await sut.save()
        
        // Then
        XCTAssertNotNil(savedItem)
        XCTAssertEqual(savedItem?.parent?.title, "Breaking Bad")
    }
    
    func test_save_failsWhenTitleEmpty() async {
        // Given
        sut.title = "   "
        
        // When
        let savedItem = await sut.save()
        
        // Then
        XCTAssertNil(savedItem)
    }
    
    func test_save_setsErrorOnFailure() async {
        // Given
        sut.title = "Inception"
        mockMediaRepository.setSaveResult(.failure(NSError(domain: "test", code: 1)))
        
        // When
        let savedItem = await sut.save()
        
        // Then
        XCTAssertNil(savedItem)
        XCTAssertNotNil(sut.error)
    }
    
    // MARK: - Reset Tests
    
    func test_reset_clearsAllFields() {
        // Given
        sut.title = "Inception"
        sut.subtitle = "Christopher Nolan"
        sut.artworkURL = "http://example.com"
        sut.selectedKind = .tvSeries
        sut.sortKey = "S01E01"
        sut.selectedParent = MediaItem(title: "Series", kind: .tvSeries)
        
        // When
        sut.reset()
        
        // Then
        XCTAssertTrue(sut.title.isEmpty)
        XCTAssertTrue(sut.subtitle.isEmpty)
        XCTAssertTrue(sut.artworkURL.isEmpty)
        XCTAssertTrue(sut.sortKey.isEmpty)
        XCTAssertEqual(sut.selectedKind, .movie)
        XCTAssertNil(sut.selectedParent)
        XCTAssertNil(sut.savedItem)
        XCTAssertNil(sut.error)
    }
}

