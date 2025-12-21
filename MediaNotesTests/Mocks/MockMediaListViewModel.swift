import Foundation
import SwiftUI
@testable import MediaNotes

// MARK: - Mock Media List ViewModel

/// Mock implementation of MediaListViewModelProtocol for testing views
@MainActor
@Observable
final class MockMediaListViewModel: MediaListViewModelProtocol {
    
    // MARK: - Invocation Tracking
    
    enum Invocation: Equatable {
        case initialize
        case refresh
        case setFilter(kind: MediaKind?)
        case toggleFilter(kind: MediaKind)
        case setSortOrder(order: MediaListSortOrder)
    }
    
    private(set) var invocations: [Invocation] = []
    
    // MARK: - State
    
    var viewState: ViewState<[MediaItem]>
    var selectedFilter: MediaKind?
    var sortOrder: MediaListSortOrder
    var filteredItems: [MediaItem]
    var activeMediaKinds: [MediaKind]
    var itemCount: Int
    
    // MARK: - Initialization
    
    init(
        viewState: ViewState<[MediaItem]> = .empty,
        selectedFilter: MediaKind? = nil,
        sortOrder: MediaListSortOrder = .recentlyAdded,
        filteredItems: [MediaItem] = [],
        activeMediaKinds: [MediaKind] = [],
        itemCount: Int = 0
    ) {
        self.viewState = viewState
        self.selectedFilter = selectedFilter
        self.sortOrder = sortOrder
        self.filteredItems = filteredItems
        self.activeMediaKinds = activeMediaKinds
        self.itemCount = itemCount
    }
    
    // MARK: - Convenience Initializers
    
    static func empty() -> MockMediaListViewModel {
        MockMediaListViewModel(viewState: .empty)
    }
    
    static func loading() -> MockMediaListViewModel {
        MockMediaListViewModel(viewState: .loading)
    }
    
    static func ready(with items: [MediaItem]) -> MockMediaListViewModel {
        let activeKinds = Array(Set(items.map { $0.kind }))
            .sorted { $0.rawValue < $1.rawValue }
        
        return MockMediaListViewModel(
            viewState: .ready(items),
            filteredItems: items,
            activeMediaKinds: activeKinds,
            itemCount: items.count
        )
    }
    
    static func error(_ message: String) -> MockMediaListViewModel {
        MockMediaListViewModel(viewState: .error(message))
    }
    
    // MARK: - Actions
    
    func initialize() async {
        invocations.append(.initialize)
    }
    
    func refresh() async {
        invocations.append(.refresh)
    }
    
    func setFilter(_ kind: MediaKind?) {
        invocations.append(.setFilter(kind: kind))
        selectedFilter = kind
    }
    
    func toggleFilter(_ kind: MediaKind) {
        invocations.append(.toggleFilter(kind: kind))
        selectedFilter = selectedFilter == kind ? nil : kind
    }
    
    func setSortOrder(_ order: MediaListSortOrder) {
        invocations.append(.setSortOrder(order: order))
        sortOrder = order
    }
}

