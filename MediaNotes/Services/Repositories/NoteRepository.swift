import Foundation
import SwiftData

// MARK: - Protocol

/// Protocol for note data access - enables testing with mocks
protocol NoteRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Note]
    func fetchNotes(for mediaItem: MediaItem) async throws -> [Note]
    func fetchNotes(matching searchText: String) async throws -> [Note]
    func fetchNote(by id: UUID) async throws -> Note?
    func create(text: String, for mediaItem: MediaItem, quote: String?) async throws -> Note
    func update(_ note: Note, text: String, quote: String?) async throws
    func delete(_ note: Note) async throws
}

// MARK: - SwiftData Implementation

/// SwiftData-backed implementation of NoteRepository
/// Uses a shared ModelContext to ensure consistency across repositories
@MainActor
final class SwiftDataNoteRepository: NoteRepositoryProtocol {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchNotes(for mediaItem: MediaItem) async throws -> [Note] {
        let mediaId = mediaItem.id
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in
                note.mediaItem?.id == mediaId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchNotes(matching searchText: String) async throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in
                note.text.localizedStandardContains(searchText)
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchNote(by id: UUID) async throws -> Note? {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func create(text: String, for mediaItem: MediaItem, quote: String? = nil) async throws -> Note {
        let note = Note(text: text, mediaItem: mediaItem)
        if let quote = quote, !quote.isEmpty {
            note.quote = quote
        }
        
        modelContext.insert(note)
        mediaItem.updatedAt = Date()
        try modelContext.save()
        
        return note
    }
    
    func update(_ note: Note, text: String, quote: String?) async throws {
        note.update(text: text)
        note.quote = quote?.isEmpty == true ? nil : quote
        try modelContext.save()
    }
    
    func delete(_ note: Note) async throws {
        modelContext.delete(note)
        try modelContext.save()
    }
}

