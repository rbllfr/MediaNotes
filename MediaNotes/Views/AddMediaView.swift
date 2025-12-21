import SwiftUI
import SwiftData

/// View for manually adding a new media item
struct AddMediaView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: any AddMediaViewModelProtocol
    
    /// Callback when media is created
    var onSave: ((MediaItem) -> Void)?
    
    @State private var showParentPicker = false
    @State private var showingAddAttribute = false
    
    init(viewModel: any AddMediaViewModelProtocol, onSave: ((MediaItem) -> Void)? = nil) {
        self._viewModel = State(initialValue: viewModel)
        self.onSave = onSave
    }
    
    struct AttributeEntry: Identifiable {
        let id = UUID()
        var key: MediaAttributeKey
        var value: String
    }
    
    private var canSave: Bool {
        !viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var accentColor: Color {
        Theme.color(for: viewModel.selectedKind)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Media type selector
                    mediaTypeSection
                    
                    // Basic info
                    basicInfoSection
                    
                    // Parent selector (for hierarchical types)
                    if viewModel.shouldShowParentSelector {
                        parentSelectorSection
                    }
                    
                    // Attributes
                    attributesSection
                }
                .padding(Theme.spacingMD)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Add Media")
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
                    Button("Save") {
                        saveMedia()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canSave ? accentColor : Theme.textTertiary)
                    .disabled(!canSave)
                }
            }
            .task {
                await viewModel.initialize()
            }
            .onChange(of: viewModel.selectedKind) { _, newKind in
                // Let ViewModel handle the kind change (it resets attributes automatically)
                viewModel.selectKind(newKind)
            }
            .sheet(isPresented: $showParentPicker) {
                parentPickerSheet
            }
        }
    }
    
    // MARK: - Media Type Section
    
    private var mediaTypeSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("TYPE")
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacingSM) {
                    ForEach(MediaKind.allCases) { kind in
                        kindButton(kind)
                    }
                }
            }
        }
    }
    
    private func kindButton(_ kind: MediaKind) -> some View {
        let isSelected = viewModel.selectedKind == kind
        let color = Theme.color(for: kind)
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectKind(kind)
            }
        } label: {
            VStack(spacing: Theme.spacingSM) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: kind.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? .white : color)
                }
                
                Text(kind.displayName)
                    .font(Theme.bodyFont(size: 12))
                    .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)
            }
            .frame(width: 70)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Basic Info Section
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("DETAILS")
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
            
            VStack(spacing: Theme.spacingMD) {
                // Title
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text("Title")
                        .font(Theme.bodyFont(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                    
                    TextField("Enter title...", text: $viewModel.title)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                        .textInputAutocapitalization(.words)
                        .padding(Theme.spacingMD)
                        .background(Theme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                }
                
                // Subtitle
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text(viewModel.subtitleLabel)
                        .font(Theme.bodyFont(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                    
                    TextField(viewModel.subtitlePlaceholder, text: $viewModel.subtitle)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                        .textInputAutocapitalization(.words)
                        .padding(Theme.spacingMD)
                        .background(Theme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                }
                
                // Artwork URL (optional)
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text("Artwork URL (optional)")
                        .font(Theme.bodyFont(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                    
                    TextField("https://...", text: $viewModel.artworkURL)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .padding(Theme.spacingMD)
                        .background(Theme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                }
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
        }
    }
    
    // MARK: - Parent Selector
    
    private var parentSelectorSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("PARENT \(viewModel.parentKind?.displayName.uppercased() ?? "ITEM")")
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
            
            VStack(spacing: Theme.spacingMD) {
                Button {
                    showParentPicker = true
                } label: {
                    HStack(spacing: Theme.spacingMD) {
                        if let parent = viewModel.selectedParent {
                            ZStack {
                                Circle()
                                    .fill(Theme.color(for: parent.kind).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: parent.kind.iconName)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.color(for: parent.kind))
                            }
                            
                            Text(parent.title)
                                .font(Theme.bodyFont(size: 16))
                                .foregroundStyle(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("Change")
                                .font(Theme.bodyFont(size: 14))
                                .foregroundStyle(accentColor)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Theme.secondaryBackground)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.textTertiary)
                            }
                            
                            Text("Select \(viewModel.parentKind?.displayName ?? "Parent")")
                                .font(Theme.bodyFont(size: 16))
                                .foregroundStyle(Theme.textSecondary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Sort key for children
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text("Sort Key (e.g., S01E01)")
                        .font(Theme.bodyFont(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                    
                    TextField("e.g., S02E05, 01, etc.", text: $viewModel.sortKey)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(Theme.spacingMD)
                        .background(Theme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                }
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
        }
    }
    
    private var parentPickerSheet: some View {
        NavigationStack {
            List {
                let filteredParents = viewModel.filteredParents
                
                if filteredParents.isEmpty {
                    ContentUnavailableView {
                        Label("No \(viewModel.parentKind?.displayName ?? "Parent")s", systemImage: "folder")
                    } description: {
                        Text("Add a \(viewModel.parentKind?.displayName.lowercased() ?? "parent") first, or create this as a standalone item.")
                    }
                } else {
                    ForEach(filteredParents, id: \.id) { item in
                        Button {
                            viewModel.selectedParent = item
                            showParentPicker = false
                        } label: {
                            HStack(spacing: Theme.spacingMD) {
                                Image(systemName: item.kind.iconName)
                                    .foregroundStyle(Theme.color(for: item.kind))
                                
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .foregroundStyle(Theme.textPrimary)
                                    if let subtitle = item.subtitle {
                                        Text(subtitle)
                                            .font(.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if viewModel.selectedParent?.id == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(accentColor)
                                }
                            }
                        }
                        .listRowBackground(Theme.cardBackground)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Select \(viewModel.parentKind?.displayName ?? "Parent")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showParentPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Attributes Section
    
    private var attributesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Text("ATTRIBUTES")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                
                Spacer()
                
                Button {
                    addNewAttribute()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(accentColor)
                }
            }
            
            VStack(spacing: Theme.spacingMD) {
                ForEach($viewModel.attributes) { $entry in
                    HStack(spacing: Theme.spacingMD) {
                        Text(entry.key.displayName)
                            .font(Theme.bodyFont(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("Value", text: $entry.value)
                            .font(Theme.bodyFont(size: 16))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(Theme.spacingSM)
                            .background(Theme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                        
                        Button {
                            removeAttribute(entry)
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                }
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
        }
    }
    
    private func addNewAttribute() {
        // Use the ViewModel's method
        let usedKeys = Set(viewModel.attributes.map { $0.key })
        let availableKeys = MediaAttributeKey.suggestedKeys(for: viewModel.selectedKind)
            .filter { !usedKeys.contains($0) }
        
        if let nextKey = availableKeys.first {
            viewModel.addAttribute(key: nextKey, value: "")
        }
    }
    
    private func removeAttribute(_ entry: AddMediaViewModel.AttributeEntry) {
        viewModel.removeAttribute(id: entry.id)
    }
    
    // MARK: - Save
    
    private func saveMedia() {
        Task {
            if let mediaItem = await viewModel.save() {
                onSave?(mediaItem)
                dismiss()
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
    
    return dependencies.makeAddMediaView { _ in }
}




