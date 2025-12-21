import Foundation
import SwiftUI
@testable import MediaNotes

@MainActor
@Observable
final class MockAddMediaViewModel: AddMediaViewModelProtocol {
    var title: String
    var selectedKind: MediaKind
    var subtitle: String
    var artworkURL: String
    var selectedParent: MediaItem?
    var sortKey: String
    var attributes: [AddMediaViewModel.AttributeEntry]
    
    private(set) var isSaving: Bool = false
    private(set) var error: Error?
    private(set) var savedItem: MediaItem?
    private(set) var parentMediaItems: [MediaItem] = []
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var accentColor: Color {
        Theme.color(for: selectedKind)
    }
    
    var shouldShowParentSelector: Bool {
        switch selectedKind {
        case .episode, .chapter, .track, .performance:
            return true
        default:
            return false
        }
    }
    
    var parentKind: MediaKind? {
        switch selectedKind {
        case .episode: return .tvSeries
        case .chapter: return .book
        case .track: return .album
        case .performance: return .liveEvent
        default: return nil
        }
    }
    
    var subtitleLabel: String {
        switch selectedKind {
        case .movie, .tvSeries: return "Director / Creator"
        case .book: return "Author"
        case .album, .track: return "Artist"
        case .episode: return "Episode Title"
        case .chapter: return "Chapter Title"
        case .liveEvent, .performance: return "Venue / Location"
        case .other: return "Subtitle"
        }
    }
    
    var subtitlePlaceholder: String {
        "Enter \(subtitleLabel.lowercased())..."
    }
    
    var sortKeyLabel: String {
        switch selectedKind {
        case .episode: return "Episode Number (e.g., S01E01)"
        case .chapter: return "Chapter Number"
        case .track: return "Track Number"
        case .performance: return "Set Order"
        default: return "Sort Key"
        }
    }
    
    var sortKeyPlaceholder: String {
        switch selectedKind {
        case .episode: return "S01E01"
        case .chapter: return "01"
        case .track: return "01"
        case .performance: return "1"
        default: return "Sort order..."
        }
    }
    
    var filteredParents: [MediaItem] {
        guard let parentKind = parentKind else { return [] }
        return parentMediaItems.filter { $0.kind == parentKind }
    }
    
    var saveResult: MediaItem?
    
    /// Create a mock with specific state
    init(
        title: String = "",
        selectedKind: MediaKind = .movie,
        subtitle: String = "",
        artworkURL: String = "",
        selectedParent: MediaItem? = nil,
        sortKey: String = "",
        attributes: [AddMediaViewModel.AttributeEntry] = [],
        parentMediaItems: [MediaItem] = []
    ) {
        self.title = title
        self.selectedKind = selectedKind
        self.subtitle = subtitle
        self.artworkURL = artworkURL
        self.selectedParent = selectedParent
        self.sortKey = sortKey
        self.attributes = attributes
        self.parentMediaItems = parentMediaItems
    }
    
    /// Convenience: create mock in idle state
    static func idle() -> MockAddMediaViewModel {
        MockAddMediaViewModel()
    }
    
    /// Convenience: create mock with preselected kind
    static func withKind(_ kind: MediaKind) -> MockAddMediaViewModel {
        MockAddMediaViewModel(selectedKind: kind)
    }
    
    func initialize() async {
        // No-op for mock - parent items can be pre-set
    }
    
    func selectKind(_ kind: MediaKind) {
        selectedKind = kind
        // Reset parent-related fields when kind changes
        if !shouldShowParentSelector {
            selectedParent = nil
            sortKey = ""
        }
        // Reset attributes for new kind
        attributes = []
    }
    
    func save() async -> MediaItem? {
        isSaving = true
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        if let result = saveResult {
            savedItem = result
            isSaving = false
            return result
        }
        
        // Create a mock saved item if none provided
        let item = MediaItem(
            title: title,
            kind: selectedKind,
            subtitle: subtitle.isEmpty ? nil : subtitle,
            artworkURLString: artworkURL.isEmpty ? nil : artworkURL,
            sortKey: sortKey.isEmpty ? nil : sortKey,
            parent: selectedParent
        )
        
        savedItem = item
        isSaving = false
        return item
    }
    
    func addAttribute(key: MediaAttributeKey, value: String) {
        let entry = AddMediaViewModel.AttributeEntry(key: key, value: value)
        attributes.append(entry)
    }
    
    func removeAttribute(id: UUID) {
        attributes.removeAll { $0.id == id }
    }
    
    func reset() {
        title = ""
        subtitle = ""
        artworkURL = ""
        selectedParent = nil
        sortKey = ""
        attributes = []
        selectedKind = .movie
        isSaving = false
        error = nil
        savedItem = nil
    }
}

