import Foundation
import SwiftUI
import SwiftData

// MARK: - Protocol

/// Protocol for SelectMediaViewModel, enables testing with mocks
@MainActor
protocol SelectMediaViewModelProtocol: AnyObject, Observable {
    var searchText: String { get set }
    var selectedKind: MediaKind? { get set }
    var viewState: ViewState<[MediaItem]> { get }
    var filteredItems: [MediaItem] { get }
    var parentItems: [MediaItem] { get }
    var recentlyUsed: [MediaItem] { get }
    
    func initialize() async
    func refresh() async
    func clearSearch()
}

// MARK: - Implementation

/// ViewModel for selecting a media item
@MainActor
@Observable
final class SelectMediaViewModel: SelectMediaViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let mediaRepository: any MediaRepositoryProtocol
    
    // MARK: - State
    
    var searchText = ""
    var selectedKind: MediaKind?
    private(set) var viewState: ViewState<[MediaItem]> = .empty
    
    // MARK: - Computed Properties
    
    private var allMediaItems: [MediaItem] {
        viewState.data ?? []
    }
    
    var filteredItems: [MediaItem] {
        var items = allMediaItems
        
        // Filter by kind
        if let kind = selectedKind {
            items = items.filter { $0.kind == kind }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            items = items.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                (item.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (item.parent?.title.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return items
    }
    
    var parentItems: [MediaItem] {
        filteredItems.filter { $0.parent == nil }
    }
    
    var recentlyUsed: [MediaItem] {
        Array(parentItems.prefix(5))
    }
    
    // MARK: - Initialization
    
    init(mediaRepository: any MediaRepositoryProtocol) {
        self.mediaRepository = mediaRepository
    }
    
    // MARK: - Actions
    
    /// Initialize the view model - only loads if state is empty
    func initialize() async {
        guard viewState.isEmpty else { return }
        await loadData()
    }
    
    /// Force refresh data
    func refresh() async {
        await loadData()
    }
    
    private func loadData() async {
        viewState = .loading
        
        do {
            let items = try await mediaRepository.fetchAll()
            viewState = .ready(items)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
}
