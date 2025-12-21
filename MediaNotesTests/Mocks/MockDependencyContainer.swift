import Foundation
import SwiftUI
import SwiftData
@testable import MediaNotes

/// Mock dependency container for testing
/// Provides configurable mock repositories
@MainActor
final class MockDependencyContainer: DependencyContaining {
    
    // MARK: - Mock Services
    
    let timeProvider: TimeProvider
    
    // MARK: - Mock Repositories
    
    let mediaRepository: any MediaRepositoryProtocol
    let noteRepository: any NoteRepositoryProtocol
    let insightsProvider: any InsightsProviding
    
    // MARK: - Initialization
    
    init(
        timeProvider: TimeProvider = FixedTimeProvider()
    ) {
        self.timeProvider = timeProvider
        self.mediaRepository = MockMediaRepository()
        self.noteRepository = MockNoteRepository()
        self.insightsProvider = MockInsightsProvider()
    }
    
    // MARK: - View Factories
    
    func makeLibraryView() -> LibraryView {
        let viewModel = LibraryViewModel(
            mediaRepository: mediaRepository,
            noteRepository: noteRepository
        )
        return LibraryView(viewModel: viewModel)
    }
    
    func makeMediaListView() -> MediaListView {
        let viewModel = MediaListViewModel(
            mediaRepository: mediaRepository
        )
        return MediaListView(viewModel: viewModel)
    }
    
    func makeSearchView() -> SearchView {
        let viewModel = SearchViewModel(
            mediaRepository: mediaRepository,
            noteRepository: noteRepository
        )
        return SearchView(viewModel: viewModel)
    }
    
    func makeInsightsView(mediaItem: MediaItem? = nil) -> InsightsView {
        let viewModel = InsightsViewModel(
            insightsProvider: insightsProvider,
            mediaItem: mediaItem
        )
        return InsightsView(viewModel: viewModel)
    }
    
    func makeAddNoteView(preselectedMedia: MediaItem?) -> AddNoteView {
        let viewModel = AddNoteViewModel(
            noteRepository: noteRepository,
            preselectedMedia: preselectedMedia
        )
        return AddNoteView(viewModel: viewModel)
    }
    
    func makeMediaDetailView(mediaItem: MediaItem) -> MediaDetailView {
        let viewModel = MediaDetailViewModel(
            mediaItem: mediaItem,
            mediaRepository: mediaRepository,
            noteRepository: noteRepository
        )
        return MediaDetailView(viewModel: viewModel)
    }
    
    func makeEditNoteView(note: Note) -> EditNoteView {
        let viewModel = EditNoteViewModel(
            note: note,
            noteRepository: noteRepository
        )
        return EditNoteView(viewModel: viewModel)
    }
    
    func makeSelectMediaView(selectedMedia: Binding<MediaItem?>) -> SelectMediaView {
        let viewModel = SelectMediaViewModel(
            mediaRepository: mediaRepository
        )
        return SelectMediaView(viewModel: viewModel, selectedMedia: selectedMedia)
    }
    
    func makeAddMediaView(onSave: ((MediaItem) -> Void)?) -> AddMediaView {
        let viewModel = AddMediaViewModel(
            mediaRepository: mediaRepository
        )
        return AddMediaView(viewModel: viewModel, onSave: onSave)
    }
}

