import Foundation
import SwiftUI
@testable import MediaNotes

@MainActor
@Observable
final class MockSearchViewModel: SearchViewModelProtocol {
    var searchText: String = ""
    var searchScope: SearchScope = .all
    var viewState: ViewState<SearchResults>
    
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
    
    /// Create a mock with a specific state
    init(viewState: ViewState<SearchResults> = .ready(.empty)) {
        self.viewState = viewState
    }
    
    /// Convenience: create mock in ready state with results
    static func ready(mediaItems: [MediaItem] = [], notes: [Note] = []) -> MockSearchViewModel {
        MockSearchViewModel(viewState: .ready(SearchResults(mediaItems: mediaItems, notes: notes)))
    }
    
    /// Convenience: create mock in loading state
    static func loading() -> MockSearchViewModel {
        MockSearchViewModel(viewState: .loading)
    }
    
    /// Convenience: create mock in error state
    static func error(_ message: String) -> MockSearchViewModel {
        MockSearchViewModel(viewState: .error(message))
    }
    
    func initialize() async {
        // No-op for mock
    }
    
    func search() async {
        // No-op for mock
    }
    
    func setScope(_ scope: SearchScope) {
        searchScope = scope
    }
    
    func clearSearch() {
        searchText = ""
        viewState = .ready(.empty)
    }
    
    func highlightedText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let range = attributedString.range(of: searchText, options: .caseInsensitive) {
            attributedString[range].foregroundColor = UIColor(Theme.accent)
            attributedString[range].font = UIFont.boldSystemFont(ofSize: 16)
        }
        
        return attributedString
    }
}

