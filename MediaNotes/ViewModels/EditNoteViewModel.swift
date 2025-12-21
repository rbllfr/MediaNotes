import Foundation
import SwiftUI
import SwiftData

// MARK: - Protocol

/// Protocol for EditNoteViewModel, enables testing with mocks
@MainActor
protocol EditNoteViewModelProtocol: AnyObject, Observable {
    var note: Note { get }
    var editedText: String { get set }
    var editedQuote: String { get set }
    var showQuoteField: Bool { get set }
    var formState: FormState { get }
    var hasChanges: Bool { get }
    var canSave: Bool { get }
    var accentColor: Color { get }
    var characterCount: Int { get }
    
    func toggleQuoteField()
    func save() async -> Bool
}

// MARK: - Implementation

/// ViewModel for editing an existing note
@MainActor
@Observable
final class EditNoteViewModel: EditNoteViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let noteRepository: any NoteRepositoryProtocol
    
    // MARK: - State
    
    let note: Note
    var editedText: String
    var editedQuote: String
    var showQuoteField: Bool
    private(set) var formState: FormState = .idle
    
    // MARK: - Computed Properties
    
    var hasChanges: Bool {
        editedText != note.text || editedQuote != (note.quote ?? "")
    }
    
    var canSave: Bool {
        !editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && hasChanges
    }
    
    var accentColor: Color {
        if let mediaItem = note.mediaItem {
            return Theme.color(for: mediaItem.kind)
        }
        return Theme.accent
    }
    
    var characterCount: Int {
        editedText.count
    }
    
    // MARK: - Initialization
    
    init(note: Note, noteRepository: any NoteRepositoryProtocol) {
        self.note = note
        self.noteRepository = noteRepository
        self.editedText = note.text
        self.editedQuote = note.quote ?? ""
        self.showQuoteField = note.quote != nil && !note.quote!.isEmpty
    }
    
    // MARK: - Actions
    
    func toggleQuoteField() {
        showQuoteField.toggle()
        if !showQuoteField {
            editedQuote = ""
        }
    }
    
    func save() async -> Bool {
        let trimmedText = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return false }
        
        formState = .saving
        
        let trimmedQuote = editedQuote.trimmingCharacters(in: .whitespacesAndNewlines)
        let quote: String? = trimmedQuote.isEmpty ? nil : trimmedQuote
        
        do {
            try await noteRepository.update(note, text: trimmedText, quote: quote)
            formState = .saved
            return true
        } catch {
            formState = .error(error.localizedDescription)
            return false
        }
    }
}
