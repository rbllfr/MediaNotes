import Foundation
import SwiftUI
import SwiftData

// MARK: - Protocol

/// Protocol for AddMediaViewModel, enables testing with mocks
@MainActor
protocol AddMediaViewModelProtocol: AnyObject, Observable {
    var title: String { get set }
    var selectedKind: MediaKind { get set }
    var subtitle: String { get set }
    var artworkURL: String { get set }
    var selectedParent: MediaItem? { get set }
    var sortKey: String { get set }
    var attributes: [AddMediaViewModel.AttributeEntry] { get set }
    var isSaving: Bool { get }
    var error: Error? { get }
    var savedItem: MediaItem? { get }
    var parentMediaItems: [MediaItem] { get }
    
    var canSave: Bool { get }
    var accentColor: Color { get }
    var shouldShowParentSelector: Bool { get }
    var parentKind: MediaKind? { get }
    var subtitleLabel: String { get }
    var subtitlePlaceholder: String { get }
    var sortKeyLabel: String { get }
    var sortKeyPlaceholder: String { get }
    var filteredParents: [MediaItem] { get }
    
    func initialize() async
    func selectKind(_ kind: MediaKind)
    func save() async -> MediaItem?
    func addAttribute(key: MediaAttributeKey, value: String)
    func removeAttribute(id: UUID)
    func reset()
}

// MARK: - Implementation

/// ViewModel for adding a new media item
@MainActor
@Observable
final class AddMediaViewModel: AddMediaViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let mediaRepository: any MediaRepositoryProtocol
    
    // MARK: - State
    
    var title = ""
    var selectedKind: MediaKind = .movie
    var subtitle = ""
    var artworkURL = ""
    var selectedParent: MediaItem?
    var sortKey = ""
    var attributes: [AttributeEntry] = []
    
    private(set) var isSaving = false
    private(set) var error: Error?
    private(set) var savedItem: MediaItem?
    private(set) var parentMediaItems: [MediaItem] = []
    
    struct AttributeEntry: Identifiable {
        let id = UUID()
        var key: MediaAttributeKey
        var value: String
    }
    
    // MARK: - Computed Properties
    
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
        case .movie: return "Director"
        case .tvSeries, .episode: return "Creator / Showrunner"
        case .book, .chapter: return "Author"
        case .album, .track: return "Artist"
        case .liveEvent, .performance: return "Venue"
        case .other: return "Subtitle"
        }
    }
    
    var subtitlePlaceholder: String {
        switch selectedKind {
        case .movie: return "e.g., Christopher Nolan"
        case .tvSeries, .episode: return "e.g., Vince Gilligan"
        case .book, .chapter: return "e.g., F. Scott Fitzgerald"
        case .album, .track: return "e.g., The Beatles"
        case .liveEvent, .performance: return "e.g., Madison Square Garden"
        case .other: return "Optional subtitle..."
        }
    }
    
    var sortKeyLabel: String {
        switch selectedKind {
        case .episode: return "Episode Number"
        case .chapter: return "Chapter Number"
        case .track: return "Track Number"
        case .performance: return "Date"
        default: return "Sort Key"
        }
    }
    
    var sortKeyPlaceholder: String {
        switch selectedKind {
        case .episode: return "e.g., S01E01"
        case .chapter: return "e.g., Chapter 1"
        case .track: return "e.g., 01"
        case .performance: return "e.g., 2024-01-15"
        default: return "Optional..."
        }
    }
    
    var filteredParents: [MediaItem] {
        guard let kind = parentKind else { return [] }
        return parentMediaItems.filter { $0.kind == kind }
    }
    
    // MARK: - Initialization
    
    init(mediaRepository: any MediaRepositoryProtocol) {
        self.mediaRepository = mediaRepository
        resetAttributes()
    }
    
    // MARK: - Actions
    
    func initialize() async {
        // Load parent media items
        do {
            let allItems = try await mediaRepository.fetchAll()
            parentMediaItems = allItems.filter { $0.parent == nil }
        } catch {
            self.error = error
        }
    }
    
    func selectKind(_ kind: MediaKind) {
        selectedKind = kind
        resetAttributes()
        
        if !shouldShowParentSelector {
            selectedParent = nil
        }
    }
    
    func selectParent(_ parent: MediaItem?) {
        selectedParent = parent
    }
    
    func addAttribute() {
        let usedKeys = Set(attributes.map { $0.key })
        let availableKeys = MediaAttributeKey.suggestedKeys(for: selectedKind)
            .filter { !usedKeys.contains($0) }
        
        if let nextKey = availableKeys.first {
            attributes.append(AttributeEntry(key: nextKey, value: ""))
        }
    }
    
    func addAttribute(key: MediaAttributeKey, value: String) {
        attributes.append(AttributeEntry(key: key, value: value))
    }
    
    func removeAttribute(id: UUID) {
        attributes.removeAll { $0.id == id }
    }
    
    func removeAttribute(_ entry: AttributeEntry) {
        removeAttribute(id: entry.id)
    }
    
    func updateAttributeValue(for entry: AttributeEntry, value: String) {
        if let index = attributes.firstIndex(where: { $0.id == entry.id }) {
            attributes[index].value = value
        }
    }
    
    func save() async -> MediaItem? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return nil }
        
        isSaving = true
        error = nil
        
        let trimmedSubtitle = subtitle.trimmingCharacters(in: .whitespaces)
        let trimmedArtworkURL = artworkURL.trimmingCharacters(in: .whitespaces)
        let trimmedSortKey = sortKey.trimmingCharacters(in: .whitespaces)
        
        let mediaItem = MediaItem(
            title: trimmedTitle,
            kind: selectedKind,
            subtitle: trimmedSubtitle.isEmpty ? nil : trimmedSubtitle,
            artworkURLString: trimmedArtworkURL.isEmpty ? nil : trimmedArtworkURL,
            sortKey: trimmedSortKey.isEmpty ? nil : trimmedSortKey,
            parent: selectedParent
        )
        
        // Add attributes
        for entry in attributes {
            let trimmedValue = entry.value.trimmingCharacters(in: .whitespaces)
            if !trimmedValue.isEmpty {
                mediaItem.setAttribute(entry.key, value: trimmedValue)
            }
        }
        
        // If we have a parent, add as child
        if let parent = selectedParent {
            parent.addChild(mediaItem)
        }
        
        do {
            try await mediaRepository.save(mediaItem)
            savedItem = mediaItem
            isSaving = false
            return mediaItem
        } catch {
            self.error = error
            isSaving = false
            return nil
        }
    }
    
    func reset() {
        title = ""
        selectedKind = .movie
        subtitle = ""
        artworkURL = ""
        selectedParent = nil
        sortKey = ""
        savedItem = nil
        error = nil
        resetAttributes()
    }
    
    private func resetAttributes() {
        attributes = MediaAttributeKey.suggestedKeys(for: selectedKind)
            .prefix(3)
            .map { AttributeEntry(key: $0, value: "") }
    }
}
