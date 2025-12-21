import SwiftUI
import SwiftData

/// Detail view for a media item showing all attached notes
/// ViewModel is always injected via init for testability
struct MediaDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var viewModel: any MediaDetailViewModelProtocol
    
    @State private var showingAddNote = false
    @State private var showingEditNote = false
    @State private var selectedNote: Note?
    @State private var showingDeleteAlert = false
    @State private var noteToDelete: Note?
    @State private var showingDeleteMediaAlert = false
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    @State private var showingInsights = false
    
    init(viewModel: any MediaDetailViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                VStack(spacing: Theme.spacingLG) {
                    // Metadata section
                    if !(viewModel.mediaItem.attributes?.isEmpty ?? true) {
                        metadataSection
                    }
                    
                    // Children section (episodes, chapters, etc.)
                    if let children = viewModel.mediaItem.children, !children.isEmpty {
                        childrenSection(children)
                    }
                    
                    // Notes section
                    notesSection
                    
                    // Delete media button
                    deleteMediaButton
                }
                .padding(Theme.spacingMD)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background.opacity(0.8), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if isEditingTitle {
                    Button("Cancel") {
                        isEditingTitle = false
                        editedTitle = viewModel.mediaItem.title
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
            
            if isEditingTitle {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            try? await viewModel.updateTitle(editedTitle)
                            isEditingTitle = false
                        }
                    }
                    .foregroundStyle(viewModel.accentColor)
                    .fontWeight(.semibold)
                    .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            } else {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editedTitle = viewModel.mediaItem.title
                        isEditingTitle = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(viewModel.accentColor)
                    }
                }
                
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(.fixed, placement: .primaryAction)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingInsights = true
                    } label: {
                        Image(systemName: "sparkles")
                            .foregroundStyle(viewModel.accentColor)
                    }
                }
                
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(.fixed, placement: .primaryAction)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(viewModel.accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            // Refresh when add note sheet dismisses
            Task { await viewModel.refresh() }
        } content: {
            DependencyProvider.shared.dependencies.makeAddNoteView(preselectedMedia: viewModel.mediaItem)
        }
        .sheet(isPresented: $showingEditNote) {
            // Refresh when edit note sheet dismisses
            Task { await viewModel.refresh() }
        } content: {
            if let note = selectedNote {
                DependencyProvider.shared.dependencies.makeEditNoteView(note: note)
            }
        }
        .sheet(isPresented: $showingInsights) {
            DependencyProvider.shared.dependencies.makeInsightsView(mediaItem: viewModel.mediaItem)
        }
        .alert("Delete Note?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    Task {
                        await viewModel.deleteNote(note)
                    }
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Delete \(viewModel.mediaItem.title)?", isPresented: $showingDeleteMediaAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteMediaItem()
                    dismiss()
                }
            }
        } message: {
            Text("This will permanently delete this media item and all \(viewModel.mediaItem.totalNoteCount) associated notes. This action cannot be undone.")
        }
        .task {
            await viewModel.initialize()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: Theme.spacingMD) {
            // Artwork
            artworkView
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
            
            VStack(spacing: Theme.spacingSM) {
                // Media type badge
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: viewModel.mediaItem.kind.iconName)
                        .font(.system(size: 12))
                    Text(viewModel.mediaItem.kind.displayName.uppercased())
                        .font(Theme.monoFont(size: 12))
                }
                .foregroundStyle(viewModel.accentColor)
                
                // Title
                if isEditingTitle {
                    TextField("Title", text: $editedTitle, axis: .vertical)
                        .font(Theme.displayFont(size: 28))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, Theme.spacingMD)
                        .padding(.vertical, Theme.spacingSM)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                } else {
                    Text(viewModel.mediaItem.title)
                        .font(Theme.displayFont(size: 28))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                }
                
                // Subtitle
                if let subtitle = viewModel.mediaItem.displaySubtitle {
                    Text(subtitle)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textSecondary)
                }
                
                // Stats
                HStack(spacing: Theme.spacingLG) {
                    statBadge(
                        value: "\(viewModel.mediaItem.totalNoteCount)",
                        label: "Notes",
                        icon: "note.text"
                    )
                    
                    if let children = viewModel.mediaItem.children, !children.isEmpty {
                        statBadge(
                            value: "\(children.count)",
                            label: viewModel.childKindName,
                            icon: "list.bullet"
                        )
                    }
                }
                .padding(.top, Theme.spacingSM)
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.bottom, Theme.spacingMD)
        }
        .background(
            LinearGradient(
                colors: [viewModel.accentColor.opacity(0.15), Theme.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    @ViewBuilder
    private var artworkView: some View {
        if let artworkURL = viewModel.mediaItem.artworkURL {
            AsyncImage(url: artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    placeholderArtwork
                @unknown default:
                    placeholderArtwork
                }
            }
        } else {
            placeholderArtwork
        }
    }
    
    private var placeholderArtwork: some View {
        ZStack {
            LinearGradient(
                colors: [viewModel.accentColor.opacity(0.4), viewModel.accentColor.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: viewModel.mediaItem.kind.iconName)
                .font(.system(size: 64))
                .foregroundStyle(viewModel.accentColor.opacity(0.4))
        }
    }
    
    private func statBadge(value: String, label: String, icon: String) -> some View {
        VStack(spacing: Theme.spacingXS) {
            HStack(spacing: Theme.spacingXS) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(value)
                    .font(Theme.headingFont(size: 18))
            }
            .foregroundStyle(Theme.textPrimary)
            
            Text(label)
                .font(Theme.bodyFont(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
    }
    
    // MARK: - Metadata Section
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            sectionHeader(title: "Details", icon: "info.circle")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.spacingMD) {
                ForEach(viewModel.mediaItem.attributes ?? [], id: \.id) { attribute in
                    VStack(alignment: .leading, spacing: Theme.spacingXS) {
                        Text(attribute.displayName)
                            .font(Theme.monoFont(size: 11))
                            .foregroundStyle(Theme.textTertiary)
                        
                        Text(attribute.value)
                            .font(Theme.bodyFont(size: 15))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
        }
    }
    
    // MARK: - Children Section
    
    private func childrenSection(_ children: [MediaItem]) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleChildrenVisibility()
                }
            } label: {
                HStack {
                    sectionHeader(
                        title: viewModel.childKindName,
                        icon: "list.bullet",
                        count: children.count
                    )
                    
                    Spacer()
                    
                    Image(systemName: viewModel.showChildren ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .buttonStyle(.plain)
            
            if viewModel.showChildren {
                // Filter chips for children
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.spacingSM) {
                        childFilterChip(label: "All", isSelected: viewModel.selectedChild == nil) {
                            withAnimation { viewModel.clearChildFilter() }
                        }
                        
                        ForEach(viewModel.mediaItem.sortedChildren, id: \.id) { child in
                            childFilterChip(
                                label: child.sortKey ?? child.title,
                                isSelected: viewModel.selectedChild?.id == child.id,
                                noteCount: child.noteCount
                            ) {
                                withAnimation {
                                    viewModel.selectChild(child)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func childFilterChip(
        label: String,
        isSelected: Bool,
        noteCount: Int = 0,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.spacingXS) {
                Text(label)
                    .font(Theme.bodyFont(size: 14))
                    .lineLimit(1)
                
                if noteCount > 0 {
                    Text("\(noteCount)")
                        .font(Theme.monoFont(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? viewModel.accentColor : Theme.secondaryBackground)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
            .background(isSelected ? viewModel.accentColor.opacity(0.2) : Theme.cardBackground)
            .foregroundStyle(isSelected ? viewModel.accentColor : Theme.textSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? viewModel.accentColor.opacity(0.5) : Theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Notes Section
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack {
                sectionHeader(
                    title: viewModel.selectedChild != nil ? "\(viewModel.selectedChild!.title) Notes" : "Notes",
                    icon: "note.text",
                    count: viewModel.displayedNotes.count
                )
                
                Spacer()
                
                if viewModel.selectedChild != nil {
                    Button {
                        withAnimation { viewModel.clearChildFilter() }
                    } label: {
                        Text("Show All")
                            .font(Theme.bodyFont(size: 14))
                            .foregroundStyle(viewModel.accentColor)
                    }
                }
            }
            
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .tint(viewModel.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingXL)
                    
            case .error(let message):
                errorView(message: message)
                
            case .empty, .ready:
                if viewModel.displayedNotes.isEmpty {
                    emptyNotesView
                } else {
                    LazyVStack(spacing: Theme.spacingMD) {
                        ForEach(viewModel.displayedNotes, id: \.id) { note in
                            NoteRowView(
                                note: note,
                                showMediaInfo: viewModel.selectedChild == nil && viewModel.hasChildren,
                                onEdit: {
                                    selectedNote = note
                                    showingEditNote = true
                                },
                                onDelete: {
                                    noteToDelete = note
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Theme.error)
            
            Text("Error loading notes")
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textSecondary)
            
            Text(message)
                .font(Theme.bodyFont(size: 14))
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
            
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Text("Try Again")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
    }
    
    private var emptyNotesView: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(Theme.textTertiary)
            
            Text("No notes yet")
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textSecondary)
            
            Button {
                showingAddNote = true
            } label: {
                Text("Add a Note")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
    }
    
    // MARK: - Delete Media Button
    
    private var deleteMediaButton: some View {
        VStack(spacing: Theme.spacingMD) {
            Divider()
                .padding(.vertical, Theme.spacingSM)
            
            Button {
                showingDeleteMediaAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                    Text("Delete \(viewModel.mediaItem.kind.displayName)")
                        .font(Theme.bodyFont(size: 16))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingMD)
            }
            .foregroundStyle(Theme.error)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .stroke(Theme.error.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(title: String, icon: String, count: Int? = nil) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(viewModel.accentColor)
            
            Text(title)
                .font(Theme.headingFont(size: 18))
                .foregroundStyle(Theme.textPrimary)
            
            if let count = count {
                Text("(\(count))")
                    .font(Theme.bodyFont(size: 14))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }
}


#Preview {
    let schema = Schema([MediaItem.self, Note.self, MediaAttribute.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let dependencies = DependencyContainer(modelContainer: container)
    
    // Initialize DependencyProvider for preview
    DependencyProvider.shared.initialize(container: dependencies)
    
    let item = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
    return NavigationStack {
        dependencies.makeMediaDetailView(mediaItem: item)
    }
}
