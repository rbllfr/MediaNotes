import SwiftUI
import SwiftData

/// Search view for finding media items and notes
/// ViewModel is always injected via init for testability
struct SearchView: View {
    @State var viewModel: any SearchViewModelProtocol
    
    init(viewModel: any SearchViewModelProtocol) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchHeader
                    
                    if viewModel.searchText.isEmpty {
                        emptySearchState
                    } else {
                        switch viewModel.viewState {
                        case .loading:
                            ProgressView()
                                .tint(Theme.accent)
                                .frame(maxHeight: .infinity)
                                
                        case .ready(let results) where results.isEmpty:
                            noResultsState
                            
                        case .ready:
                            searchResults
                            
                        case .error(let message):
                            errorState(message: message)
                            
                        case .empty:
                            emptySearchState
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.background, for: .navigationBar)
        }
        .task {
            await viewModel.initialize()
        }
    }
    
    // MARK: - Search Header
    
    private var searchHeader: some View {
        VStack(spacing: Theme.spacingMD) {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.textTertiary)
                
                TextField("Search media and notes...", text: $viewModel.searchText)
                    .font(Theme.bodyFont(size: 16))
                    .foregroundStyle(Theme.textPrimary)
                    .autocorrectionDisabled()
                    .onSubmit {
                        Task { await viewModel.search() }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            
            if !viewModel.searchText.isEmpty {
                HStack(spacing: Theme.spacingSM) {
                    ForEach(SearchScope.allCases, id: \.rawValue) { scope in
                        scopeButton(scope: scope)
                    }
                    Spacer()
                }
            }
        }
        .padding(Theme.spacingMD)
        .onChange(of: viewModel.searchText) { _, _ in
            Task { await viewModel.search() }
        }
    }
    
    private func scopeButton(scope: SearchScope) -> some View {
        let isSelected = viewModel.searchScope == scope
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.setScope(scope)
            }
        } label: {
            Text(scope.rawValue)
                .font(Theme.bodyFont(size: 14))
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
                .background(isSelected ? Theme.accent.opacity(0.2) : Theme.cardBackground)
                .foregroundStyle(isSelected ? Theme.accent : Theme.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Theme.accent.opacity(0.5) : Theme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptySearchState: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.textTertiary)
            }
            
            VStack(spacing: Theme.spacingSM) {
                Text("Search Your Library")
                    .font(Theme.displayFont(size: 22))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("Find media items and notes\nby title or content")
                    .font(Theme.bodyFont(size: 15))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding(Theme.spacingLG)
    }
    
    private var noResultsState: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.textTertiary)
            }
            
            VStack(spacing: Theme.spacingSM) {
                Text("No Results")
                    .font(Theme.displayFont(size: 22))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("No matches found for \"\(viewModel.searchText)\"")
                    .font(Theme.bodyFont(size: 15))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding(Theme.spacingLG)
    }
    
    private func errorState(message: String) -> some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.error)
            }
            
            VStack(spacing: Theme.spacingSM) {
                Text("Search Error")
                    .font(Theme.displayFont(size: 22))
                    .foregroundStyle(Theme.textPrimary)
                
                Text(message)
                    .font(Theme.bodyFont(size: 15))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding(Theme.spacingLG)
    }
    
    // MARK: - Search Results
    
    private var searchResults: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Theme.spacingLG) {
                if !viewModel.filteredMediaResults.isEmpty {
                    mediaResultsSection
                }
                
                if !viewModel.filteredNoteResults.isEmpty {
                    noteResultsSection
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding(Theme.spacingMD)
        }
    }
    
    private var mediaResultsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack {
                Text("MEDIA")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                
                Text("(\(viewModel.mediaResultCount))")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
            
            ForEach(viewModel.filteredMediaResults, id: \.id) { item in
                NavigationLink(destination: DependencyProvider.shared.dependencies.makeMediaDetailView(mediaItem: item)) {
                    mediaSearchResult(item: item)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func mediaSearchResult(item: MediaItem) -> some View {
        HStack(spacing: Theme.spacingMD) {
            ZStack {
                Circle()
                    .fill(Theme.color(for: item.kind).opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.kind.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.color(for: item.kind))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.highlightedText(item.title))
                    .font(Theme.bodyFont(size: 16))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: Theme.spacingSM) {
                    Text(item.kind.displayName)
                        .font(Theme.monoFont(size: 11))
                        .foregroundStyle(Theme.color(for: item.kind))
                    
                    if let subtitle = item.displaySubtitle {
                        Text("·")
                            .foregroundStyle(Theme.textTertiary)
                        Text(subtitle)
                            .font(Theme.bodyFont(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            if item.totalNoteCount > 0 {
                Text("\(item.totalNoteCount)")
                    .font(Theme.monoFont(size: 12))
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, Theme.spacingSM)
                    .padding(.vertical, Theme.spacingXS)
                    .background(Theme.secondaryBackground)
                    .clipShape(Capsule())
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(Theme.spacingMD)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
    }
    
    private var noteResultsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack {
                Text("NOTES")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                
                Text("(\(viewModel.noteResultCount))")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
            
            ForEach(viewModel.filteredNoteResults, id: \.id) { note in
                if let mediaItem = note.mediaItem {
                    NavigationLink(destination: DependencyProvider.shared.dependencies.makeMediaDetailView(mediaItem: mediaItem)) {
                        noteSearchResult(note: note)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func noteSearchResult(note: Note) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            if let media = note.mediaItem {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: media.kind.iconName)
                        .font(.system(size: 11))
                    Text(media.title)
                        .font(Theme.bodyFont(size: 12))
                        .lineLimit(1)
                }
                .foregroundStyle(Theme.color(for: media.kind))
            }
            
            Text(viewModel.highlightedText(note.preview))
                .font(Theme.bodyFont(size: 15))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(3)
            
            Text(note.shortDate)
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(Theme.spacingMD)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
    }
}

#Preview {
    let schema = Schema([MediaItem.self, Note.self, MediaAttribute.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let dependencies = DependencyContainer(modelContainer: container)
    
    // Initialize DependencyProvider for preview
    DependencyProvider.shared.initialize(container: dependencies)
    
    return dependencies.makeSearchView()
}
