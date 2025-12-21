import Foundation
import SwiftUI
@testable import MediaNotes

@MainActor
@Observable
final class MockEditNoteViewModel: EditNoteViewModelProtocol {
    let note: Note
    var editedText: String
    var editedQuote: String
    var showQuoteField: Bool
    var formState: FormState
    
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
    
    var saveResult: Bool = true
    
    /// Create a mock with specific state
    init(
        note: Note,
        editedText: String? = nil,
        editedQuote: String? = nil,
        showQuoteField: Bool? = nil,
        formState: FormState = .idle
    ) {
        self.note = note
        self.editedText = editedText ?? note.text
        self.editedQuote = editedQuote ?? (note.quote ?? "")
        self.showQuoteField = showQuoteField ?? (note.quote != nil && !note.quote!.isEmpty)
        self.formState = formState
    }
    
    /// Convenience: create mock in idle state with a note
    static func idle(note: Note) -> MockEditNoteViewModel {
        MockEditNoteViewModel(note: note)
    }
    
    /// Convenience: create mock in saving state
    static func saving(note: Note) -> MockEditNoteViewModel {
        MockEditNoteViewModel(note: note, formState: .saving)
    }
    
    func toggleQuoteField() {
        showQuoteField.toggle()
        if !showQuoteField {
            editedQuote = ""
        }
    }
    
    func save() async -> Bool {
        formState = .saving
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        if saveResult {
            formState = .saved
        } else {
            formState = .error("Failed to save")
        }
        return saveResult
    }
}

