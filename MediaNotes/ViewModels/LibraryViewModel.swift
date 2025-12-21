import Foundation
import SwiftUI
import SwiftData

// MARK: - Protocol

/// Protocol for LibraryViewModel, enables testing with mocks
@MainActor
protocol LibraryViewModelProtocol: AnyObject, Observable {
    var viewState: ViewState<[MediaItem]> { get }
    var selectedFilter: MediaKind? { get set }
    var sortOrder: LibrarySortOrder { get set }
    var filteredItems: [MediaItem] { get }
    var activeMediaKinds: [MediaKind] { get }
    var itemCount: Int { get }
    
    func initialize() async
    func refresh() async
    func setFilter(_ kind: MediaKind?)
    func toggleFilter(_ kind: MediaKind)
    func setSortOrder(_ order: LibrarySortOrder)
}

// MARK: - Sort Order

enum LibrarySortOrder: String, CaseIterable {
    case recentlyNoted = "Recently Noted"
    case recentlyAdded = "Recently Added"
    case alphabetical = "A-Z"
    case noteCount = "Most Notes"
}

// MARK: - Implementation

/// ViewModel for the Library screen
/// Contains all presentation logic, easily testable
@MainActor
@Observable
final class LibraryViewModel: LibraryViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let mediaRepository: any MediaRepositoryProtocol
    private let noteRepository: any NoteRepositoryProtocol
    
    // MARK: - State
    
    private(set) var viewState: ViewState<[MediaItem]> = .empty
    var selectedFilter: MediaKind?
    var sortOrder: LibrarySortOrder = .recentlyNoted
    
    // MARK: - Computed Properties
    
    private var mediaItems: [MediaItem] {
        viewState.data ?? []
    }
    
    var filteredItems: [MediaItem] {
        var items = mediaItems.filter { $0.totalNoteCount > 0 }
        
        if let filter = selectedFilter {
            items = items.filter { $0.kind == filter }
        }
        
        return sortItems(items)
    }
    
    var activeMediaKinds: [MediaKind] {
        let kinds = Set(mediaItems.filter { $0.totalNoteCount > 0 }.map { $0.kind })
        return MediaKind.allCases.filter { kinds.contains($0) }
    }
    
    var itemCount: Int {
        filteredItems.count
    }
    
    // MARK: - Initialization
    
    init(mediaRepository: any MediaRepositoryProtocol, noteRepository: any NoteRepositoryProtocol) {
        self.mediaRepository = mediaRepository
        self.noteRepository = noteRepository
    }
    
    // MARK: - Actions
    
    /// Initialize the view model - only loads if state is empty
    func initialize() async {
        guard viewState.isEmpty else { return }
        viewState = .loading
        await loadData()
    }
    
    /// Force refresh data
    func refresh() async {
        guard viewState.isReady else { return }
        await loadData()
    }
    
    private func loadData() async {
        do {
            let items = try await mediaRepository.fetchRootItems()
            viewState = .ready(items)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    func setFilter(_ kind: MediaKind?) {
        selectedFilter = kind
    }
    
    func toggleFilter(_ kind: MediaKind) {
        selectedFilter = selectedFilter == kind ? nil : kind
    }
    
    func setSortOrder(_ order: LibrarySortOrder) {
        sortOrder = order
    }
    
    // MARK: - Private Helpers
    
    private func sortItems(_ items: [MediaItem]) -> [MediaItem] {
        var sorted = items
        
        switch sortOrder {
        case .recentlyNoted:
            sorted.sort { ($0.lastNoteDate ?? .distantPast) > ($1.lastNoteDate ?? .distantPast) }
        case .recentlyAdded:
            sorted.sort { $0.createdAt > $1.createdAt }
        case .alphabetical:
            sorted.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .noteCount:
            sorted.sort { $0.totalNoteCount > $1.totalNoteCount }
        }
        
        return sorted
    }
}
