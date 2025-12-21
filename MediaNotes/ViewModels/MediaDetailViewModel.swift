import Foundation
import SwiftUI
import SwiftData

// MARK: - Protocol

/// Protocol for MediaDetailViewModel, enables testing with mocks
@MainActor
protocol MediaDetailViewModelProtocol: AnyObject, Observable {
    var mediaItem: MediaItem { get }
    var viewState: ViewState<[Note]> { get }
    var selectedChild: MediaItem? { get set }
    var showChildren: Bool { get set }
    var displayedNotes: [Note] { get }
    var accentColor: Color { get }
    var hasChildren: Bool { get }
    var childKindName: String { get }
    
    func initialize() async
    func refresh() async
    func deleteNote(_ note: Note) async
    func selectChild(_ child: MediaItem?)
    func clearChildFilter()
    func toggleChildrenVisibility()
    func addChild(title: String, sortKey: String?) async -> MediaItem?
    func updateTitle(_ newTitle: String) async throws
    func deleteMediaItem() async throws
}

// MARK: - Implementation

/// ViewModel for the Media Detail screen
@MainActor
@Observable
final class MediaDetailViewModel: MediaDetailViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let mediaRepository: any MediaRepositoryProtocol
    private let noteRepository: any NoteRepositoryProtocol
    
    // MARK: - State
    
    let mediaItem: MediaItem
    private(set) var viewState: ViewState<[Note]> = .empty
    
    var selectedChild: MediaItem?
    var showChildren = true
    
    // MARK: - Computed Properties
    
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
    
    // MARK: - Initialization
    
    init(
        mediaItem: MediaItem,
        mediaRepository: any MediaRepositoryProtocol,
        noteRepository: any NoteRepositoryProtocol
    ) {
        self.mediaItem = mediaItem
        self.mediaRepository = mediaRepository
        self.noteRepository = noteRepository
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
            let loadedNotes = try await noteRepository.fetchNotes(for: mediaItem)
            viewState = .ready(loadedNotes)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    func deleteNote(_ note: Note) async {
        do {
            try await noteRepository.delete(note)
            // Update state by removing the deleted note
            if case .ready(var currentNotes) = viewState {
                currentNotes.removeAll { $0.id == note.id }
                viewState = .ready(currentNotes)
            }
        } catch {
            viewState = .error(error.localizedDescription)
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
        do {
            return try await mediaRepository.addChild(
                to: mediaItem,
                title: title,
                sortKey: sortKey
            )
        } catch {
            viewState = .error(error.localizedDescription)
            return nil
        }
    }
    
    func updateTitle(_ newTitle: String) async throws {
        mediaItem.title = newTitle
        try await mediaRepository.update(mediaItem)
    }
    
    func deleteMediaItem() async throws {
        try await mediaRepository.delete(mediaItem)
    }
}
