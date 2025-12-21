import XCTest
@testable import MediaNotes

@MainActor
final class MediaDetailViewModelTests: XCTestCase {
    
    var sut: MediaDetailViewModel!
    var mockMediaRepository: MockMediaRepository!
    var mockNoteRepository: MockNoteRepository!
    var testMediaItem: MediaItem!
    
    override func setUp() async throws {
        mockMediaRepository = MockMediaRepository()
        mockNoteRepository = MockNoteRepository()
        testMediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
        sut = MediaDetailViewModel(
            mediaItem: testMediaItem,
            mediaRepository: mockMediaRepository,
            noteRepository: mockNoteRepository
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockMediaRepository = nil
        mockNoteRepository = nil
        testMediaItem = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_init_setsMediaItem() {
        // Then
        XCTAssertEqual(sut.mediaItem.title, "Breaking Bad")
        XCTAssertEqual(sut.mediaItem.kind, .tvSeries)
    }
    
    func test_init_startsWithEmptyViewState() {
        // Then
        XCTAssertTrue(sut.viewState.isEmpty)
    }
    
    func test_init_showChildrenDefaultsToTrue() {
        // Then
        XCTAssertTrue(sut.showChildren)
    }
    
    // MARK: - Computed Properties Tests
    
    func test_accentColor_returnsCorrectColor() {
        // Given
        let movieItem = MediaItem(title: "Inception", kind: .movie)
        let movieSut = MediaDetailViewModel(
            mediaItem: movieItem,
            mediaRepository: mockMediaRepository,
            noteRepository: mockNoteRepository
        )
        
        // Then
        XCTAssertEqual(movieSut.accentColor, Theme.color(for: .movie))
    }
    
    func test_hasChildren_returnsFalseWhenNoChildren() {
        // Then
        XCTAssertFalse(sut.hasChildren)
    }
    
    func test_hasChildren_returnsTrueWhenHasChildren() {
        // Given
        let episode = MediaItem(title: "Pilot", kind: .episode)
        testMediaItem.addChild(episode)
        
        // Then
        XCTAssertTrue(sut.hasChildren)
    }
    
    func test_childKindName_returnsCorrectName() {
        // Then
        XCTAssertEqual(sut.childKindName, "Episode")
    }
    
    // MARK: - Initialize Tests
    
    func test_initialize_doesNotLoadWhenAlreadyLoaded() async {
        // Given
        sut = MediaDetailViewModel(
            mediaItem: testMediaItem,
            mediaRepository: mockMediaRepository,
            noteRepository: mockNoteRepository
        )
        mockNoteRepository.setFetchNotesResult(.success([]))
        await sut.initialize()
        mockNoteRepository.reset()
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertEqual(mockNoteRepository.invocations.count, 0)
    }
    
    func test_initialize_loadsNotesSuccessfully() async {
        // Given
        let note1 = Note(text: "Great show!", mediaItem: testMediaItem)
        let note2 = Note(text: "Amazing!", mediaItem: testMediaItem)
        mockNoteRepository.setFetchNotesResult(.success([note1, note2]))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
        let notes = sut.viewState.data ?? []
        XCTAssertEqual(notes.count, 2)
    }
    
    func test_initialize_setsErrorOnFailure() async {
        // Given
        mockNoteRepository.setFetchNotesResult(.failure(NSError(domain: "test", code: 1)))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.viewState.isError)
    }
    
    // MARK: - Refresh Tests
    
    func test_refresh_reloadsNotes() async {
        // Given
        let note = Note(text: "Great!", mediaItem: testMediaItem)
        mockNoteRepository.setFetchNotesResult(.success([note]))
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertTrue(mockNoteRepository.invocations.contains(.fetchNotesForMedia(mediaItem: testMediaItem)))
        XCTAssertTrue(sut.viewState.isReady)
    }
    
    // MARK: - Delete Note Tests
    
    func test_deleteNote_removesNoteFromState() async {
        // Given
        let note1 = Note(text: "Note 1", mediaItem: testMediaItem)
        let note2 = Note(text: "Note 2", mediaItem: testMediaItem)
        mockNoteRepository.setFetchNotesResult(.success([note1, note2]))
        await sut.initialize()
        mockNoteRepository.setDeleteResult(.success(()))
        
        // When
        await sut.deleteNote(note1)
        
        // Then
        XCTAssertTrue(mockNoteRepository.invocations.contains(.delete(note: note1)))
        let remainingNotes = sut.viewState.data ?? []
        XCTAssertEqual(remainingNotes.count, 1)
        XCTAssertEqual(remainingNotes.first?.text, "Note 2")
    }
    
    func test_deleteNote_setsErrorOnFailure() async {
        // Given
        let note = Note(text: "Note", mediaItem: testMediaItem)
        mockNoteRepository.setFetchNotesResult(.success([note]))
        await sut.initialize()
        mockNoteRepository.setDeleteResult(.failure(NSError(domain: "test", code: 1)))
        
        // When
        await sut.deleteNote(note)
        
        // Then
        XCTAssertTrue(sut.viewState.isError)
    }
    
    // MARK: - Child Selection Tests
    
    func test_selectChild_setsSelectedChild() {
        // Given
        let episode = MediaItem(title: "Pilot", kind: .episode)
        
        // When
        sut.selectChild(episode)
        
        // Then
        XCTAssertEqual(sut.selectedChild?.title, "Pilot")
    }
    
    func test_selectChild_togglesOffWhenSelectingSameChild() {
        // Given
        let episode = MediaItem(title: "Pilot", kind: .episode)
        sut.selectChild(episode)
        
        // When
        sut.selectChild(episode)
        
        // Then
        XCTAssertNil(sut.selectedChild)
    }
    
    func test_clearChildFilter_clearsSelection() {
        // Given
        let episode = MediaItem(title: "Pilot", kind: .episode)
        sut.selectChild(episode)
        
        // When
        sut.clearChildFilter()
        
        // Then
        XCTAssertNil(sut.selectedChild)
    }
    
    // MARK: - Children Visibility Tests
    
    func test_toggleChildrenVisibility_togglesShowChildren() {
        // Given
        let initialState = sut.showChildren
        
        // When
        sut.toggleChildrenVisibility()
        
        // Then
        XCTAssertEqual(sut.showChildren, !initialState)
    }
    
    // MARK: - Add Child Tests
    
    func test_addChild_createsChildSuccessfully() async {
        // Given
        mockMediaRepository.setAddChildResult(.success(MediaItem(title: "Pilot", kind: .episode)))
        
        // When
        let child = await sut.addChild(title: "Pilot", sortKey: "S01E01")
        
        // Then
        XCTAssertNotNil(child)
        XCTAssertEqual(child?.title, "Pilot")
        XCTAssertTrue(mockMediaRepository.invocations.contains(.addChild(parent: testMediaItem, title: "Pilot", sortKey: "S01E01")))
    }
    
    func test_addChild_setsErrorOnFailure() async {
        // Given
        mockMediaRepository.setAddChildResult(.failure(NSError(domain: "test", code: 1)))
        
        // When
        let child = await sut.addChild(title: "Pilot", sortKey: "S01E01")
        
        // Then
        XCTAssertNil(child)
        XCTAssertTrue(sut.viewState.isError)
    }
    
    // MARK: - Update Title Tests
    
    func test_updateTitle_updatesMediaItemTitle() async throws {
        // Given
        let newTitle = "Breaking Bad: The Complete Series"
        XCTAssertEqual(testMediaItem.title, "Breaking Bad")
        
        // When
        try await sut.updateTitle(newTitle)
        
        // Then
        XCTAssertEqual(testMediaItem.title, newTitle)
        XCTAssertTrue(mockMediaRepository.invocations.contains(.update(item: testMediaItem)))
    }
    
    func test_updateTitle_throwsErrorOnFailure() async {
        // Given
        let newTitle = "New Title"
        mockMediaRepository.setShouldThrowError(true)
        
        // When/Then
        do {
            try await sut.updateTitle(newTitle)
            XCTFail("Expected error to be thrown")
        } catch {
            // Error should be thrown
            XCTAssertNotNil(error)
        }
    }
    
    func test_updateTitle_updatesTimestamp() async throws {
        // Given
        let originalUpdatedAt = testMediaItem.updatedAt
        let newTitle = "New Title"
        
        // Small delay to ensure timestamp difference
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // When
        try await sut.updateTitle(newTitle)
        
        // Then
        XCTAssertGreaterThan(testMediaItem.updatedAt, originalUpdatedAt)
    }
    
    // MARK: - Delete Media Item Tests
    
    func test_deleteMediaItem_callsRepositoryDelete() async throws {
        // Given
        mockMediaRepository.setDeleteResult(.success(()))
        
        // When
        try await sut.deleteMediaItem()
        
        // Then
        XCTAssertTrue(mockMediaRepository.invocations.contains(.delete(item: testMediaItem)))
    }
    
    func test_deleteMediaItem_throwsErrorOnFailure() async {
        // Given
        let expectedError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Delete failed"])
        mockMediaRepository.setDeleteResult(.failure(expectedError))
        
        // When/Then
        do {
            try await sut.deleteMediaItem()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).domain, "test")
        }
    }
}

