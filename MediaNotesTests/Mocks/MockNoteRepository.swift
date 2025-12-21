import Foundation
@testable import MediaNotes

/// Mock implementation of NoteRepository for unit testing
@MainActor
final class MockNoteRepository: NoteRepositoryProtocol {
    
    // MARK: - Invocation Tracking
    
    enum Invocation: Equatable {
        case fetchAll
        case fetchNotesForMedia(mediaItem: MediaItem)
        case fetchNotesMatching(searchText: String)
        case fetchNote(id: UUID)
        case create(text: String, mediaItem: MediaItem, quote: String?)
        case update(note: Note, text: String, quote: String?)
        case delete(note: Note)
        
        static func == (lhs: Invocation, rhs: Invocation) -> Bool {
            switch (lhs, rhs) {
            case (.fetchAll, .fetchAll):
                return true
            case let (.fetchNotesForMedia(lMedia), .fetchNotesForMedia(rMedia)):
                return lMedia.id == rMedia.id
            case let (.fetchNotesMatching(lText), .fetchNotesMatching(rText)):
                return lText == rText
            case let (.fetchNote(lId), .fetchNote(rId)):
                return lId == rId
            case let (.create(lText, lMedia, lQuote), .create(rText, rMedia, rQuote)):
                return lText == rText && lMedia.id == rMedia.id && lQuote == rQuote
            case let (.update(lNote, lText, lQuote), .update(rNote, rText, rQuote)):
                return lNote.id == rNote.id && lText == rText && lQuote == rQuote
            case let (.delete(lNote), .delete(rNote)):
                return lNote.id == rNote.id
            default:
                return false
            }
        }
    }
    
    private(set) var invocations: [Invocation] = []
    
    // MARK: - Stored Data
    
    var notes: [Note] = []
    var createdNotes: [Note] = []
    var updatedNotes: [Note] = []
    var deletedNotes: [Note] = []
    
    // MARK: - Result Simulation
    
    var fetchNotesResult: Result<[Note], Error>?
    var deleteResult: Result<Void, Error>?
    var updateResult: Result<Void, Error>?
    
    // MARK: - Error Simulation
    
    var shouldThrowError = false
    var errorToThrow: Error = RepositoryError.notFound
    
    // MARK: - Protocol Implementation
    
    func fetchAll() async throws -> [Note] {
        invocations.append(.fetchAll)
        if shouldThrowError { throw errorToThrow }
        return notes
    }
    
    func fetchNotes(for mediaItem: MediaItem) async throws -> [Note] {
        invocations.append(.fetchNotesForMedia(mediaItem: mediaItem))
        
        if let result = fetchNotesResult {
            switch result {
            case .success(let notes):
                return notes
            case .failure(let error):
                throw error
            }
        }
        
        if shouldThrowError { throw errorToThrow }
        return notes.filter { $0.mediaItem?.id == mediaItem.id }
    }
    
    func fetchNotes(matching searchText: String) async throws -> [Note] {
        invocations.append(.fetchNotesMatching(searchText: searchText))
        if shouldThrowError { throw errorToThrow }
        return notes.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
    }
    
    func fetchNote(by id: UUID) async throws -> Note? {
        invocations.append(.fetchNote(id: id))
        if shouldThrowError { throw errorToThrow }
        return notes.first { $0.id == id }
    }
    
    func create(text: String, for mediaItem: MediaItem, quote: String?) async throws -> Note {
        invocations.append(.create(text: text, mediaItem: mediaItem, quote: quote))
        if shouldThrowError { throw errorToThrow }
        
        let note = Note(text: text, mediaItem: mediaItem)
        if let quote = quote {
            note.quote = quote
        }
        notes.append(note)
        createdNotes.append(note)
        return note
    }
    
    func update(_ note: Note, text: String, quote: String?) async throws {
        invocations.append(.update(note: note, text: text, quote: quote))
        
        if let result = updateResult {
            switch result {
            case .success:
                break
            case .failure(let error):
                throw error
            }
        }
        
        if shouldThrowError { throw errorToThrow }
        
        note.update(text: text)
        note.quote = quote
        updatedNotes.append(note)
    }
    
    func delete(_ note: Note) async throws {
        invocations.append(.delete(note: note))
        
        if let result = deleteResult {
            switch result {
            case .success:
                break
            case .failure(let error):
                throw error
            }
        }
        
        if shouldThrowError { throw errorToThrow }
        
        deletedNotes.append(note)
        notes.removeAll { $0.id == note.id }
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        invocations = []
        notes = []
        createdNotes = []
        updatedNotes = []
        deletedNotes = []
        shouldThrowError = false
        fetchNotesResult = nil
        deleteResult = nil
        updateResult = nil
    }
    
    func addTestNote(_ note: Note) {
        notes.append(note)
    }
    
    func setFetchNotesResult(_ result: Result<[Note], Error>) {
        fetchNotesResult = result
    }
    
    func setDeleteResult(_ result: Result<Void, Error>) {
        deleteResult = result
    }
    
    func setUpdateResult(_ result: Result<Void, Error>) {
        updateResult = result
    }
}

