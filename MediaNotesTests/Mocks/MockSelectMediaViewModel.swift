import Foundation
import SwiftUI
@testable import MediaNotes

@MainActor
@Observable
final class MockSelectMediaViewModel: SelectMediaViewModelProtocol {
    var searchText: String = ""
    var selectedKind: MediaKind?
    var viewState: ViewState<[MediaItem]>
    
    private var allMediaItems: [MediaItem] {
        viewState.data ?? []
    }
    
    var filteredItems: [MediaItem] {
        var items = allMediaItems
        
        if let kind = selectedKind {
            items = items.filter { $0.kind == kind }
        }
        
        if !searchText.isEmpty {
            items = items.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                (item.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false)
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
    
    /// Create a mock with a specific state
    init(viewState: ViewState<[MediaItem]> = .empty, allItems: [MediaItem]? = nil) {
        if let items = allItems {
            self.viewState = .ready(items)
        } else {
            self.viewState = viewState
        }
    }
    
    /// Convenience: create mock in ready state with items
    static func ready(with items: [MediaItem]) -> MockSelectMediaViewModel {
        MockSelectMediaViewModel(viewState: .ready(items))
    }
    
    /// Convenience: create mock in loading state
    static func loading() -> MockSelectMediaViewModel {
        MockSelectMediaViewModel(viewState: .loading)
    }
    
    /// Convenience: create mock in error state
    static func error(_ message: String) -> MockSelectMediaViewModel {
        MockSelectMediaViewModel(viewState: .error(message))
    }
    
    func initialize() async {
        // No-op for mock
    }
    
    func refresh() async {
        // No-op for mock
    }
    
    func clearSearch() {
        searchText = ""
    }
}

