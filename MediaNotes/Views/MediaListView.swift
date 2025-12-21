import SwiftUI
import SwiftData

/// Media list screen showing all media items
/// ViewModel is always injected via init for testability
struct MediaListView: View {
    let viewModel: any MediaListViewModelProtocol
    @State private var showingAddMedia: Bool = false
    
    init(viewModel: any MediaListViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                switch viewModel.viewState {
                case .empty, .loading:
                    ProgressView()
                        .tint(Theme.accent)
                        
                case .ready(let items) where items.isEmpty:
                    emptyStateView
                    
                case .ready:
                    contentView
                    
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationTitle("Media")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddMedia = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddMedia) {
                DependencyProvider.shared.dependencies.makeAddMediaView(onSave: {_ in 
                    Task {
                        await viewModel.refresh()
                    }
                })
            }
            .onAppear {
                Task {
                    await viewModel.refresh()
                }
            }
            .task {
                await viewModel.initialize()
            }
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: Theme.spacingMD) {
                // Filter chips
                if !viewModel.activeMediaKinds.isEmpty {
                    filterChipsView
                        .padding(.horizontal, Theme.spacingMD)
                }
                
                // Sort options
                sortMenuView
                    .padding(.horizontal, Theme.spacingMD)
                
                // Media items grid
                LazyVStack(spacing: Theme.spacingMD) {
                    ForEach(viewModel.filteredItems, id: \.id) { item in
                        NavigationLink(destination: DependencyProvider.shared.dependencies.makeMediaDetailView(mediaItem: item)) {
                            MediaRowCompactView(mediaItem: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.spacingMD)
                
                // Bottom spacing for tab bar
                Spacer()
                    .frame(height: 100)
            }
            .padding(.top, Theme.spacingMD)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.textTertiary)
            }
            
            VStack(spacing: Theme.spacingSM) {
                Text("No Media Yet")
                    .font(Theme.displayFont(size: 24))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("Add books, movies, TV shows, music,\nand events to get started")
                    .font(Theme.bodyFont(size: 16))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingAddMedia = true
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "plus")
                    Text("Add Your First Media")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.spacingMD)
            
            Spacer()
            Spacer()
        }
        .padding(Theme.spacingLG)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: Theme.spacingLG) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.error)
            }
            
            VStack(spacing: Theme.spacingSM) {
                Text("Something went wrong")
                    .font(Theme.displayFont(size: 24))
                    .foregroundStyle(Theme.textPrimary)
                
                Text(message)
                    .font(Theme.bodyFont(size: 16))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.spacingMD)
            
            Spacer()
            Spacer()
        }
        .padding(Theme.spacingLG)
    }
    
    // MARK: - Filter Chips
    
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.spacingSM) {
                filterChip(
                    label: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedFilter == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.setFilter(nil)
                    }
                }
                
                ForEach(viewModel.activeMediaKinds) { kind in
                    filterChip(
                        label: kind.displayName,
                        icon: kind.iconName,
                        color: Theme.color(for: kind),
                        isSelected: viewModel.selectedFilter == kind
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleFilter(kind)
                        }
                    }
                }
            }
        }
    }
    
    private func filterChip(
        label: String,
        icon: String,
        color: Color = Theme.accent,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.spacingXS) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(Theme.bodyFont(size: 14))
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
    
    // MARK: - Sort Menu
    
    private var sortMenuView: some View {
        HStack {
            Text("\(viewModel.itemCount) item\(viewModel.itemCount == 1 ? "" : "s")")
                .font(Theme.bodyFont(size: 14))
                .foregroundStyle(Theme.textTertiary)
            
            Spacer()
            
            Menu {
                ForEach(MediaListSortOrder.allCases, id: \.rawValue) { order in
                    Button {
                        withAnimation {
                            viewModel.setSortOrder(order)
                        }
                    } label: {
                        HStack {
                            Text(order.rawValue)
                            if viewModel.sortOrder == order {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: Theme.spacingXS) {
                    Text(viewModel.sortOrder.rawValue)
                        .font(Theme.bodyFont(size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundStyle(Theme.textSecondary)
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
    
    return dependencies.makeMediaListView()
}

