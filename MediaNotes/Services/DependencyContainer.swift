import Foundation
import SwiftUI
import SwiftData

// MARK: - Dependency Container

/// Central container for dependency injection
/// Enables swapping implementations for testing
@MainActor
final class DependencyContainer: DependencyContaining {
    
    private let modelContainer: ModelContainer
    let timeProvider: TimeProvider
    
    init(modelContainer: ModelContainer, timeProvider: TimeProvider = SystemTimeProvider()) {
        self.modelContainer = modelContainer
        self.timeProvider = timeProvider
    }
    
    func makeLibraryView() -> LibraryView {
        let viewModel = LibraryViewModel(
            mediaRepository: makeMediaRepository(),
            noteRepository: makeNoteRepository()
        )
        return LibraryView(viewModel: viewModel)
    }
    
    func makeMediaListView() -> MediaListView {
        let viewModel = MediaListViewModel(
            mediaRepository: makeMediaRepository()
        )
        return MediaListView(viewModel: viewModel)
    }
    
    func makeSearchView() -> SearchView {
        let viewModel = SearchViewModel(
            mediaRepository: makeMediaRepository(),
            noteRepository: makeNoteRepository()
        )
        return SearchView(viewModel: viewModel)
    }
    
    func makeInsightsView(mediaItem: MediaItem? = nil) -> InsightsView {
        let viewModel = InsightsViewModel(
            insightsProvider: makeInsightsProvider(),
            mediaItem: mediaItem
        )
        return InsightsView(viewModel: viewModel)
    }
    
    func makeAddNoteView(preselectedMedia: MediaItem?) -> AddNoteView {
        let viewModel = AddNoteViewModel(
            noteRepository: makeNoteRepository(),
            preselectedMedia: preselectedMedia
        )
        return AddNoteView(viewModel: viewModel)
    }
    
    func makeMediaDetailView(mediaItem: MediaItem) -> MediaDetailView {
        let viewModel = MediaDetailViewModel(
            mediaItem: mediaItem,
            mediaRepository: makeMediaRepository(),
            noteRepository: makeNoteRepository()
        )
        return MediaDetailView(viewModel: viewModel)
    }
    
    func makeEditNoteView(note: Note) -> EditNoteView {
        let viewModel = EditNoteViewModel(
            note: note,
            noteRepository: makeNoteRepository()
        )
        return EditNoteView(viewModel: viewModel)
    }
    
    func makeSelectMediaView(selectedMedia: Binding<MediaItem?>) -> SelectMediaView {
        let viewModel = SelectMediaViewModel(
            mediaRepository: makeMediaRepository()
        )
        return SelectMediaView(viewModel: viewModel, selectedMedia: selectedMedia)
    }
    
    func makeAddMediaView(onSave: ((MediaItem) -> Void)?) -> AddMediaView {
        let viewModel = AddMediaViewModel(
            mediaRepository: makeMediaRepository()
        )
        return AddMediaView(viewModel: viewModel, onSave: onSave)
    }
    
    private func makeMediaRepository() -> any MediaRepositoryProtocol {
        SwiftDataMediaRepository(modelContext: modelContainer.mainContext)
    }
    
    private func makeNoteRepository() -> any NoteRepositoryProtocol {
        SwiftDataNoteRepository(modelContext: modelContainer.mainContext)
    }
    
    private func makeInsightsProvider() -> any InsightsProviding {
        FoundationModelsInsightsProvider(noteRepository: makeNoteRepository())
    }
    
}
