import Foundation
import SwiftUI
import SwiftData

// MARK: - Protocol

/// Protocol for AddNoteViewModel, enables testing with mocks
@MainActor
protocol AddNoteViewModelProtocol: AnyObject, Observable {
    var noteText: String { get set }
    var selectedMedia: MediaItem? { get set }
    var quote: String { get set }
    var showQuoteField: Bool { get set }
    var formState: FormState { get }
    var canSave: Bool { get }
    var characterCount: Int { get }
    
    func selectMedia(_ media: MediaItem)
    func toggleQuoteField()
    func save() async -> Bool
    func reset()
}

// MARK: - Implementation

/// ViewModel for the Add Note flow
@MainActor
@Observable
final class AddNoteViewModel: AddNoteViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let noteRepository: any NoteRepositoryProtocol
    
    // MARK: - State
    
    var noteText = ""
    var selectedMedia: MediaItem?
    var quote = ""
    var showQuoteField = false
    private(set) var formState: FormState = .idle
    
    // MARK: - Computed Properties
    
    var canSave: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedMedia != nil
    }
    
    var characterCount: Int {
        noteText.count
    }
    
    var trimmedText: String {
        noteText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var trimmedQuote: String? {
        let trimmed = quote.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    // MARK: - Initialization
    
    init(noteRepository: any NoteRepositoryProtocol, preselectedMedia: MediaItem? = nil) {
        self.noteRepository = noteRepository
        self.selectedMedia = preselectedMedia
    }
    
    // MARK: - Actions
    
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
        guard canSave, let media = selectedMedia else { return false }
        
        formState = .saving
        
        do {
            _ = try await noteRepository.create(
                text: trimmedText,
                for: media,
                quote: trimmedQuote
            )
            formState = .saved
            return true
        } catch {
            formState = .error(error.localizedDescription)
            return false
        }
    }
    
    func reset() {
        noteText = ""
        quote = ""
        showQuoteField = false
        selectedMedia = nil
        formState = .idle
    }
}
