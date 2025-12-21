import Foundation
import SwiftUI
@testable import MediaNotes

@MainActor
@Observable
final class MockAddNoteViewModel: AddNoteViewModelProtocol {
    var noteText: String
    var selectedMedia: MediaItem?
    var quote: String
    var showQuoteField: Bool
    var formState: FormState
    
    var canSave: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedMedia != nil
    }
    
    var characterCount: Int {
        noteText.count
    }
    
    var saveResult: Bool = true
    
    /// Create a mock with specific state
    init(
        noteText: String = "",
        selectedMedia: MediaItem? = nil,
        quote: String = "",
        showQuoteField: Bool = false,
        formState: FormState = .idle
    ) {
        self.noteText = noteText
        self.selectedMedia = selectedMedia
        self.quote = quote
        self.showQuoteField = showQuoteField
        self.formState = formState
    }
    
    /// Convenience: create mock in idle state (default form ready for input)
    static func idle(preselectedMedia: MediaItem? = nil) -> MockAddNoteViewModel {
        MockAddNoteViewModel(selectedMedia: preselectedMedia)
    }
    
    /// Convenience: create mock in saving state
    static func saving() -> MockAddNoteViewModel {
        MockAddNoteViewModel(formState: .saving)
    }
    
    /// Convenience: create mock with pre-filled content
    static func withContent(text: String, media: MediaItem) -> MockAddNoteViewModel {
        MockAddNoteViewModel(noteText: text, selectedMedia: media)
    }
    
    func selectMedia(_ media: MediaItem) {
        selectedMedia = media
    }
    
    func toggleQuoteField() {
        showQuoteField.toggle()
        if !showQuoteField {
            quote = ""
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
    
    func reset() {
        noteText = ""
        quote = ""
        showQuoteField = false
        selectedMedia = nil
        formState = .idle
    }
}

