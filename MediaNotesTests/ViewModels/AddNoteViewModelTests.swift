import XCTest
@testable import MediaNotes

@MainActor
final class AddNoteViewModelTests: XCTestCase {
    
    var sut: AddNoteViewModel!
    var mockNoteRepository: MockNoteRepository!
    
    override func setUp() async throws {
        mockNoteRepository = MockNoteRepository()
        sut = AddNoteViewModel(noteRepository: mockNoteRepository)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockNoteRepository = nil
    }
    
    // MARK: - Validation Tests
    
    func test_canSave_falseWhenTextEmpty() {
        // Given
        sut.noteText = ""
        sut.selectedMedia = MediaItem(title: "Movie", kind: .movie)
        
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_falseWhenTextOnlyWhitespace() {
        // Given
        sut.noteText = "   \n\t  "
        sut.selectedMedia = MediaItem(title: "Movie", kind: .movie)
        
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_falseWhenNoMediaSelected() {
        // Given
        sut.noteText = "Great movie!"
        sut.selectedMedia = nil
        
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_trueWhenValid() {
        // Given
        sut.noteText = "Great movie!"
        sut.selectedMedia = MediaItem(title: "Movie", kind: .movie)
        
        // Then
        XCTAssertTrue(sut.canSave)
    }
    
    // MARK: - Character Count Tests
    
    func test_characterCount_returnsCorrectCount() {
        // Given
        sut.noteText = "Hello"
        
        // Then
        XCTAssertEqual(sut.characterCount, 5)
    }
    
    // MARK: - Trimmed Text Tests
    
    func test_trimmedText_removesWhitespace() {
        // Given
        sut.noteText = "  Hello World  "
        
        // Then
        XCTAssertEqual(sut.trimmedText, "Hello World")
    }
    
    func test_trimmedQuote_returnsNilForEmptyString() {
        // Given
        sut.quote = ""
        
        // Then
        XCTAssertNil(sut.trimmedQuote)
    }
    
    func test_trimmedQuote_returnsNilForWhitespace() {
        // Given
        sut.quote = "   "
        
        // Then
        XCTAssertNil(sut.trimmedQuote)
    }
    
    func test_trimmedQuote_returnsTrimmedValue() {
        // Given
        sut.quote = "  A quote  "
        
        // Then
        XCTAssertEqual(sut.trimmedQuote, "A quote")
    }
    
    // MARK: - Save Tests
    
    func test_save_success() async {
        // Given
        let media = MediaItem(title: "Movie", kind: .movie)
        sut.noteText = "Great movie!"
        sut.selectedMedia = media
        
        // When
        let success = await sut.save()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertTrue(sut.formState.isSaved)
        XCTAssertFalse(sut.formState.isSaving)
        XCTAssertFalse(sut.formState.isError)
        XCTAssertTrue(mockNoteRepository.invocations.contains(.create(text: "Great movie!", mediaItem: media, quote: nil)))
    }
    
    func test_save_withQuote() async {
        // Given
        let media = MediaItem(title: "Movie", kind: .movie)
        sut.noteText = "Great line!"
        sut.quote = "I'll be back"
        sut.selectedMedia = media
        
        // When
        let success = await sut.save()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertTrue(mockNoteRepository.invocations.contains(.create(text: "Great line!", mediaItem: media, quote: "I'll be back")))
        XCTAssertEqual(mockNoteRepository.createdNotes.first?.quote, "I'll be back")
    }
    
    func test_save_failsWhenCannotSave() async {
        // Given
        sut.noteText = ""
        sut.selectedMedia = nil
        
        // When
        let success = await sut.save()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertFalse(sut.formState.isSaved)
    }
    
    // MARK: - Reset Tests
    
    func test_reset_clearsAllState() {
        // Given
        sut.noteText = "Some text"
        sut.quote = "Some quote"
        sut.showQuoteField = true
        sut.selectedMedia = MediaItem(title: "Movie", kind: .movie)
        
        // When
        sut.reset()
        
        // Then
        XCTAssertEqual(sut.noteText, "")
        XCTAssertEqual(sut.quote, "")
        XCTAssertFalse(sut.showQuoteField)
        XCTAssertNil(sut.selectedMedia)
        XCTAssertTrue(sut.formState.isIdle)
    }
    
    // MARK: - Toggle Quote Field Tests
    
    func test_toggleQuoteField_showsAndClearsQuote() {
        // Given
        sut.showQuoteField = false
        sut.quote = ""
        
        // When - show
        sut.toggleQuoteField()
        
        // Then
        XCTAssertTrue(sut.showQuoteField)
        
        // Given - add quote
        sut.quote = "Some quote"
        
        // When - hide
        sut.toggleQuoteField()
        
        // Then - quote is cleared
        XCTAssertFalse(sut.showQuoteField)
        XCTAssertEqual(sut.quote, "")
    }
    
    // MARK: - Preselected Media Tests
    
    func test_init_withPreselectedMedia() {
        // Given
        let media = MediaItem(title: "Preselected", kind: .book)
        
        // When
        let viewModel = AddNoteViewModel(
            noteRepository: mockNoteRepository,
            preselectedMedia: media
        )
        
        // Then
        XCTAssertEqual(viewModel.selectedMedia?.title, "Preselected")
    }
    
    // MARK: - FormState Tests
    
    func test_formState_startsIdle() {
        XCTAssertTrue(sut.formState.isIdle)
    }
}
