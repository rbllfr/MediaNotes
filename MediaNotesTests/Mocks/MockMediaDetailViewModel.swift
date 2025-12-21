import Foundation
import SwiftUI
@testable import MediaNotes

@MainActor
@Observable
final class MockMediaDetailViewModel: MediaDetailViewModelProtocol {
    let mediaItem: MediaItem
    var viewState: ViewState<[Note]>
    var selectedChild: MediaItem?
    var showChildren: Bool = true
    
    private var notes: [Note] {
        viewState.data ?? []
    }
    
    var displayedNotes: [Note] {
        if let child = selectedChild {
            return (child.notes ?? []).sorted { $0.createdAt > $1.createdAt }
        }
        return mediaItem.allNotes
    }
    
    var accentColor: Color {
        Theme.color(for: mediaItem.kind)
    }
    
    var hasChildren: Bool {
        guard let children = mediaItem.children else { return false }
        return !children.isEmpty
    }
    
    var childKindName: String {
        mediaItem.kind.childKind?.displayName ?? "Items"
    }
    
    /// Create a mock with a specific state
    init(mediaItem: MediaItem, viewState: ViewState<[Note]> = .empty) {
        self.mediaItem = mediaItem
        self.viewState = viewState
    }
    
    /// Convenience: create mock in ready state with notes
    static func ready(mediaItem: MediaItem, notes: [Note] = []) -> MockMediaDetailViewModel {
        MockMediaDetailViewModel(mediaItem: mediaItem, viewState: .ready(notes))
    }
    
    /// Convenience: create mock in loading state
    static func loading(mediaItem: MediaItem) -> MockMediaDetailViewModel {
        MockMediaDetailViewModel(mediaItem: mediaItem, viewState: .loading)
    }
    
    /// Convenience: create mock in error state
    static func error(mediaItem: MediaItem, message: String) -> MockMediaDetailViewModel {
        MockMediaDetailViewModel(mediaItem: mediaItem, viewState: .error(message))
    }
    
    func initialize() async {
        // No-op for mock
    }
    
    func refresh() async {
        // No-op for mock
    }
    
    func deleteNote(_ note: Note) async {
        if case .ready(var currentNotes) = viewState {
            currentNotes.removeAll { $0.id == note.id }
            viewState = .ready(currentNotes)
        }
    }
    
    func selectChild(_ child: MediaItem?) {
        selectedChild = selectedChild?.id == child?.id ? nil : child
    }
    
    func clearChildFilter() {
        selectedChild = nil
    }
    
    func toggleChildrenVisibility() {
        showChildren.toggle()
    }
    
    func addChild(title: String, sortKey: String?) async -> MediaItem? {
        let child = MediaItem(title: title, kind: mediaItem.kind.childKind ?? mediaItem.kind, sortKey: sortKey)
        child.parent = mediaItem
        return child
    }
    
    func updateTitle(_ newTitle: String) async throws {
        mediaItem.title = newTitle
    }
    
    func deleteMediaItem() async throws {
        // No-op for mock - actual deletion would be handled by the repository
    }
}

