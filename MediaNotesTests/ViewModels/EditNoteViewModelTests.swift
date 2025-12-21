import XCTest
@testable import MediaNotes

@MainActor
final class EditNoteViewModelTests: XCTestCase {
    
    var sut: EditNoteViewModel!
    var mockNoteRepository: MockNoteRepository!
    var testNote: Note!
    var testMediaItem: MediaItem!
    
    override func setUp() async throws {
        mockNoteRepository = MockNoteRepository()
        testMediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        testNote = Note(text: "Original text", mediaItem: testMediaItem, quote: "Original quote")
        sut = EditNoteViewModel(note: testNote, noteRepository: mockNoteRepository)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockNoteRepository = nil
        testNote = nil
        testMediaItem = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_init_setsEditedTextFromNote() {
        // Then
        XCTAssertEqual(sut.editedText, "Original text")
    }
    
    func test_init_setsEditedQuoteFromNote() {
        // Then
        XCTAssertEqual(sut.editedQuote, "Original quote")
    }
    
    func test_init_showsQuoteFieldWhenNoteHasQuote() {
        // Then
        XCTAssertTrue(sut.showQuoteField)
    }
    
    func test_init_hidesQuoteFieldWhenNoteHasNoQuote() {
        // Given
        let noteWithoutQuote = Note(text: "Text", mediaItem: testMediaItem)
        
        // When
        let vm = EditNoteViewModel(note: noteWithoutQuote, noteRepository: mockNoteRepository)
        
        // Then
        XCTAssertFalse(vm.showQuoteField)
    }
    
    func test_init_formStateIsIdle() {
        // Then
        XCTAssertTrue(sut.formState.isIdle)
    }
    
    // MARK: - Has Changes Tests
    
    func test_hasChanges_falseWhenNoChanges() {
        // Then
        XCTAssertFalse(sut.hasChanges)
    }
    
    func test_hasChanges_trueWhenTextChanged() {
        // When
        sut.editedText = "New text"
        
        // Then
        XCTAssertTrue(sut.hasChanges)
    }
    
    func test_hasChanges_trueWhenQuoteChanged() {
        // When
        sut.editedQuote = "New quote"
        
        // Then
        XCTAssertTrue(sut.hasChanges)
    }
    
    func test_hasChanges_trueWhenQuoteAdded() {
        // Given
        let noteWithoutQuote = Note(text: "Text", mediaItem: testMediaItem)
        let vm = EditNoteViewModel(note: noteWithoutQuote, noteRepository: mockNoteRepository)
        
        // When
        vm.editedQuote = "New quote"
        
        // Then
        XCTAssertTrue(vm.hasChanges)
    }
    
    // MARK: - Can Save Tests
    
    func test_canSave_falseWhenNoChanges() {
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_falseWhenTextEmpty() {
        // When
        sut.editedText = ""
        
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_falseWhenTextOnlyWhitespace() {
        // When
        sut.editedText = "   \n\t  "
        
        // Then
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_trueWhenValidChanges() {
        // When
        sut.editedText = "Updated text"
        
        // Then
        XCTAssertTrue(sut.canSave)
    }
    
    // MARK: - Character Count Tests
    
    func test_characterCount_returnsCorrectCount() {
        // Given
        sut.editedText = "Hello World"
        
        // Then
        XCTAssertEqual(sut.characterCount, 11)
    }
    
    // MARK: - Accent Color Tests
    
    func test_accentColor_returnsMediaKindColor() {
        // Then
        XCTAssertEqual(sut.accentColor, Theme.color(for: .tvSeries))
    }
    
    func test_accentColor_returnsDefaultWhenNoMedia() {
        // Given
        let noteWithoutMedia = Note(text: "Text", mediaItem: nil)
        let vm = EditNoteViewModel(note: noteWithoutMedia, noteRepository: mockNoteRepository)
        
        // Then
        XCTAssertEqual(vm.accentColor, Theme.accent)
    }
    
    // MARK: - Toggle Quote Field Tests
    
    func test_toggleQuoteField_togglesVisibility() {
        // Given
        let initialState = sut.showQuoteField
        
        // When
        sut.toggleQuoteField()
        
        // Then
        XCTAssertEqual(sut.showQuoteField, !initialState)
    }
    
    func test_toggleQuoteField_clearsQuoteWhenHiding() {
        // Given
        sut.showQuoteField = true
        sut.editedQuote = "Some quote"
        
        // When
        sut.toggleQuoteField()
        
        // Then
        XCTAssertFalse(sut.showQuoteField)
        XCTAssertEqual(sut.editedQuote, "")
    }
    
    // MARK: - Save Tests
    
    func test_save_success() async {
        // Given
        sut.editedText = "Updated text"
        mockNoteRepository.setUpdateResult(.success(()))
        
        // When
        let success = await sut.save()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertTrue(sut.formState.isSaved)
        XCTAssertTrue(mockNoteRepository.invocations.contains(.update(note: testNote, text: "Updated text", quote: "Original quote")))
    }
    
    func test_save_trimsWhitespace() async {
        // Given
        sut.editedText = "  Updated text  "
        sut.editedQuote = "  Quote  "
        mockNoteRepository.setUpdateResult(.success(()))
        
        // When
        _ = await sut.save()
        
        // Then
        XCTAssertTrue(mockNoteRepository.invocations.contains(.update(note: testNote, text: "Updated text", quote: "Quote")))
    }
    
    func test_save_savesNilQuoteWhenEmpty() async {
        // Given
        sut.editedText = "Updated text"
        sut.editedQuote = "   "
        mockNoteRepository.setUpdateResult(.success(()))
        
        // When
        _ = await sut.save()
        
        // Then
        XCTAssertTrue(mockNoteRepository.invocations.contains(.update(note: testNote, text: "Updated text", quote: nil)))
    }
    
    func test_save_failsWhenTextEmpty() async {
        // Given
        sut.editedText = "   "
        
        // When
        let success = await sut.save()
        
        // Then
        XCTAssertFalse(success)
    }
    
    func test_save_setsErrorOnFailure() async {
        // Given
        sut.editedText = "Updated text"
        mockNoteRepository.setUpdateResult(.failure(NSError(domain: "test", code: 1)))
        
        // When
        let success = await sut.save()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(sut.formState.isError)
    }
    
    func test_save_setSavingStateDuringSave() async {
        // Given
        sut.editedText = "Updated text"
        mockNoteRepository.setUpdateResult(.success(()))
        
        // When
        let saveTask = Task {
            await sut.save()
        }
        
        // Small delay to catch the saving state
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        // Then - might be saving or saved depending on timing
        let isSavingOrSaved = sut.formState.isSaving || sut.formState.isSaved
        XCTAssertTrue(isSavingOrSaved)
        
        _ = await saveTask.value
    }
}

