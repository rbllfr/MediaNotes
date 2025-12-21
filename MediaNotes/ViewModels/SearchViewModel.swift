import Foundation
import SwiftUI
import SwiftData

// MARK: - Search Results Type

struct SearchResults: Equatable {
    let mediaItems: [MediaItem]
    let notes: [Note]
    
    var isEmpty: Bool {
        mediaItems.isEmpty && notes.isEmpty
    }
    
    static let empty = SearchResults(mediaItems: [], notes: [])
}

// MARK: - Search Scope

enum SearchScope: String, CaseIterable {
    case all = "All"
    case media = "Media"
    case notes = "Notes"
}

// MARK: - Protocol

/// Protocol for SearchViewModel, enables testing with mocks
@MainActor
protocol SearchViewModelProtocol: AnyObject, Observable {
    var searchText: String { get set }
    var searchScope: SearchScope { get set }
    var viewState: ViewState<SearchResults> { get }
    var filteredMediaResults: [MediaItem] { get }
    var filteredNoteResults: [Note] { get }
    var hasResults: Bool { get }
    var mediaResultCount: Int { get }
    var noteResultCount: Int { get }
    
    func initialize() async
    func search() async
    func setScope(_ scope: SearchScope)
    func clearSearch()
    func highlightedText(_ text: String) -> AttributedString
}

// MARK: - Implementation

/// ViewModel for the Search screen
@MainActor
@Observable
final class SearchViewModel: SearchViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let mediaRepository: any MediaRepositoryProtocol
    private let noteRepository: any NoteRepositoryProtocol
    
    // MARK: - State
    
    var searchText = ""
    var searchScope: SearchScope = .all
    private(set) var viewState: ViewState<SearchResults> = .ready(.empty)
    
    // MARK: - Computed Properties
    
    private var results: SearchResults {
        viewState.data ?? .empty
    }
    
    var hasResults: Bool {
        !results.isEmpty
    }
    
    var filteredMediaResults: [MediaItem] {
        guard searchScope == .all || searchScope == .media else { return [] }
        return results.mediaItems
    }
    
    var filteredNoteResults: [Note] {
        guard searchScope == .all || searchScope == .notes else { return [] }
        return results.notes
    }
    
    var mediaResultCount: Int {
        filteredMediaResults.count
    }
    
    var noteResultCount: Int {
        filteredNoteResults.count
    }
    
    // MARK: - Initialization
    
    init(mediaRepository: any MediaRepositoryProtocol, noteRepository: any NoteRepositoryProtocol) {
        self.mediaRepository = mediaRepository
        self.noteRepository = noteRepository
    }
    
    // MARK: - Actions
    
    /// Initialize - for search, this is a no-op since we start ready
    func initialize() async {
        // Search starts in ready state with empty results
        // No initialization needed
    }
    
    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            viewState = .ready(.empty)
            return
        }
        
        viewState = .loading
        
        do {
            async let mediaTask = mediaRepository.fetchItems(matching: query)
            async let notesTask = noteRepository.fetchNotes(matching: query)
            
            let (media, notes) = try await (mediaTask, notesTask)
            viewState = .ready(SearchResults(mediaItems: media, notes: notes))
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    func setScope(_ scope: SearchScope) {
        searchScope = scope
    }
    
    func clearSearch() {
        searchText = ""
        viewState = .ready(.empty)
    }
    
    /// Highlight matching text in search results
    func highlightedText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let range = attributedString.range(of: searchText, options: .caseInsensitive) {
            attributedString[range].foregroundColor = UIColor(Theme.accent)
            attributedString[range].font = UIFont.boldSystemFont(ofSize: 16)
        }
        
        return attributedString
    }
}
