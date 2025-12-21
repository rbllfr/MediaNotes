import SwiftUI
import SwiftData

/// View for selecting a media item to attach a note to
struct SelectMediaView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: any SelectMediaViewModelProtocol
    @Binding var selectedMedia: MediaItem?
    
    @State private var showingAddMedia = false
    
    init(viewModel: any SelectMediaViewModelProtocol, selectedMedia: Binding<MediaItem?>) {
        self._viewModel = State(initialValue: viewModel)
        self._selectedMedia = selectedMedia
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingMD) {
                    // Search bar
                    searchBar
                    
                    // Filter chips
                    filterChips
                    
                    // Content
                    if viewModel.filteredItems.isEmpty && !viewModel.searchText.isEmpty {
                        noResultsView
                    } else {
                        mediaListContent
                    }
                }
                .padding(Theme.spacingMD)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Select Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddMedia = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddMedia) {
                DependencyProvider.shared.dependencies.makeAddMediaView { newMedia in
                    selectedMedia = newMedia
                    dismiss()
                }
            }
            .task {
                await viewModel.initialize()
            }
            .onChange(of: showingAddMedia) { oldValue, newValue in
                // Refresh when sheet closes
                if oldValue && !newValue {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Theme.textTertiary)
            
            TextField("Search media...", text: $viewModel.searchText)
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textPrimary)
                .autocorrectionDisabled()
            
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
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.spacingSM) {
                filterChip(label: "All", isSelected: viewModel.selectedKind == nil) {
                    withAnimation { viewModel.selectedKind = nil }
                }
                
                ForEach(MediaKind.allCases) { kind in
                    filterChip(
                        label: kind.displayName,
                        icon: kind.iconName,
                        color: Theme.color(for: kind),
                        isSelected: viewModel.selectedKind == kind
                    ) {
                        withAnimation {
                            viewModel.selectedKind = viewModel.selectedKind == kind ? nil : kind
                        }
                    }
                }
            }
        }
    }
    
    private func filterChip(
        label: String,
        icon: String? = nil,
        color: Color = Theme.accent,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.spacingXS) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(label)
                    .font(Theme.bodyFont(size: 13))
            }
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
            .background(isSelected ? color.opacity(0.2) : Theme.cardBackground)
            .foregroundStyle(isSelected ? color : Theme.textSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? color.opacity(0.5) : Theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Media List Content
    
    private var mediaListContent: some View {
        VStack(alignment: .leading, spacing: Theme.spacingLG) {
            // Recently used section
            if viewModel.searchText.isEmpty && !viewModel.recentlyUsed.isEmpty && viewModel.selectedKind == nil {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    sectionHeader("Recent")
                    
                    ForEach(viewModel.recentlyUsed, id: \.id) { item in
                        mediaSelectButton(item)
                    }
                }
            }
            
            // All media section
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                if viewModel.searchText.isEmpty && viewModel.selectedKind == nil {
                    sectionHeader("All Media")
                }
                
                ForEach(viewModel.parentItems, id: \.id) { item in
                    mediaSelectButton(item)
                    
                    // Show children if expanded or if there are notes
                    if let children = item.children, !children.isEmpty {
                        ForEach(item.sortedChildren, id: \.id) { child in
                            mediaSelectButton(child, isChild: true)
                        }
                    }
                }
            }
            
            // Add new option
            addNewMediaButton
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(Theme.monoFont(size: 11))
            .foregroundStyle(Theme.textTertiary)
            .padding(.top, Theme.spacingSM)
    }
    
    private func mediaSelectButton(_ item: MediaItem, isChild: Bool = false) -> some View {
        Button {
            selectedMedia = item
            dismiss()
        } label: {
            HStack(spacing: Theme.spacingMD) {
                if isChild {
                    // Indent for children
                    Rectangle()
                        .fill(Theme.color(for: item.kind).opacity(0.3))
                        .frame(width: 2)
                        .padding(.leading, Theme.spacingMD)
                }
                
                ZStack {
                    Circle()
                        .fill(Theme.color(for: item.kind).opacity(0.2))
                        .frame(width: isChild ? 36 : 44, height: isChild ? 36 : 44)
                    
                    Image(systemName: item.kind.iconName)
                        .font(.system(size: isChild ? 14 : 18))
                        .foregroundStyle(Theme.color(for: item.kind))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(Theme.bodyFont(size: isChild ? 15 : 16))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: Theme.spacingSM) {
                        if let subtitle = item.displaySubtitle ?? item.sortKey {
                            Text(subtitle)
                                .font(Theme.bodyFont(size: 12))
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(1)
                        }
                        
                        if item.noteCount > 0 {
                            Text("·")
                                .foregroundStyle(Theme.textTertiary)
                            Text("\(item.noteCount) notes")
                                .font(Theme.monoFont(size: 11))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                }
                
                Spacer()
                
                if selectedMedia?.id == item.id {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.color(for: item.kind))
                }
            }
            .padding(.vertical, Theme.spacingSM)
            .padding(.horizontal, Theme.spacingMD)
            .background(
                selectedMedia?.id == item.id ? 
                    Theme.color(for: item.kind).opacity(0.1) : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Add New Media Button
    
    private var addNewMediaButton: some View {
        Button {
            showingAddMedia = true
        } label: {
            HStack(spacing: Theme.spacingMD) {
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.accent)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add New Media")
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("Create a new movie, show, book, etc.")
                        .font(Theme.bodyFont(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, Theme.spacingMD)
    }
    
    // MARK: - No Results
    
    private var noResultsView: some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Theme.textTertiary)
            
            Text("No media found")
                .font(Theme.headingFont(size: 18))
                .foregroundStyle(Theme.textPrimary)
            
            Text("Try a different search or add new media")
                .font(Theme.bodyFont(size: 14))
                .foregroundStyle(Theme.textSecondary)
            
            Button {
                showingAddMedia = true
            } label: {
                Text("Add New Media")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
    }
}

#Preview {
    let schema = Schema([MediaItem.self, Note.self, MediaAttribute.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let dependencies = DependencyContainer(modelContainer: container)
    
    // Initialize DependencyProvider for preview
    DependencyProvider.shared.initialize(container: dependencies)
        
    return dependencies.makeSelectMediaView(selectedMedia: .constant(nil))
}




