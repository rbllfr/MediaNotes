import SwiftUI
import SwiftData

/// View for managing child media items (episodes, chapters, tracks)
struct MediaHierarchyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let parentItem: MediaItem
    @State private var showingAddChild = false
    @State private var newChildTitle = ""
    @State private var newChildSortKey = ""
    
    private var accentColor: Color {
        Theme.color(for: parentItem.kind)
    }
    
    private var childKindName: String {
        parentItem.kind.childKind?.displayName ?? "Item"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(parentItem.sortedChildren, id: \.id) { child in
                        childRow(child)
                    }
                    .onDelete(perform: deleteChildren)
                } header: {
                    Text("\(parentItem.sortedChildren.count) \(childKindName)\(parentItem.sortedChildren.count == 1 ? "" : "s")")
                }
                
                Section {
                    Button {
                        showingAddChild = true
                    } label: {
                        Label("Add \(childKindName)", systemImage: "plus")
                            .foregroundStyle(accentColor)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("\(parentItem.title) - \(childKindName)s")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(accentColor)
                }
            }
            .sheet(isPresented: $showingAddChild) {
                addChildSheet
            }
        }
    }
    
    private func childRow(_ child: MediaItem) -> some View {
        HStack(spacing: Theme.spacingMD) {
            // Sort key badge
            if let sortKey = child.sortKey {
                Text(sortKey)
                    .font(Theme.monoFont(size: 13))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, Theme.spacingSM)
                    .padding(.vertical, Theme.spacingXS)
                    .background(accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(child.title)
                    .font(Theme.bodyFont(size: 16))
                    .foregroundStyle(Theme.textPrimary)
                
                if child.noteCount > 0 {
                    Text("\(child.noteCount) note\(child.noteCount == 1 ? "" : "s")")
                        .font(Theme.monoFont(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            
            Spacer()
        }
        .listRowBackground(Theme.cardBackground)
    }
    
    private var addChildSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("\(childKindName) Title", text: $newChildTitle)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Sort Key (e.g., S01E01, 01)", text: $newChildSortKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("New \(childKindName)")
                } footer: {
                    Text("Sort key is used to order items. Examples: S02E03, 01, 2024-11-18")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Add \(childKindName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        newChildTitle = ""
                        newChildSortKey = ""
                        showingAddChild = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addChild()
                    }
                    .disabled(newChildTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .foregroundStyle(accentColor)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func addChild() {
        let title = newChildTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        
        let sortKey = newChildSortKey.trimmingCharacters(in: .whitespaces)
        _ = parentItem.createChild(
            title: title,
            sortKey: sortKey.isEmpty ? nil : sortKey
        )
        
        newChildTitle = ""
        newChildSortKey = ""
        showingAddChild = false
    }
    
    private func deleteChildren(at offsets: IndexSet) {
        let sortedChildren = parentItem.sortedChildren
        for index in offsets {
            let child = sortedChildren[index]
            modelContext.delete(child)
        }
    }
}

// MARK: - Quick Add Child View

struct QuickAddChildView: View {
    @Environment(\.modelContext) private var modelContext
    
    let parentItem: MediaItem
    let onAdd: (MediaItem) -> Void
    
    @State private var title = ""
    @State private var sortKey = ""
    
    private var childKindName: String {
        parentItem.kind.childKind?.displayName ?? "Item"
    }
    
    private var accentColor: Color {
        Theme.color(for: parentItem.kind)
    }
    
    var body: some View {
        VStack(spacing: Theme.spacingMD) {
            HStack(spacing: Theme.spacingMD) {
                TextField("\(childKindName) title", text: $title)
                    .textFieldStyle(.plain)
                    .padding(Theme.spacingMD)
                    .background(Theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                
                TextField("Sort key", text: $sortKey)
                    .textFieldStyle(.plain)
                    .frame(width: 80)
                    .padding(Theme.spacingMD)
                    .background(Theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
                
                Button {
                    addChild()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(accentColor)
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(Theme.spacingMD)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
    }
    
    private func addChild() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        let trimmedSortKey = sortKey.trimmingCharacters(in: .whitespaces)
        if let child = parentItem.createChild(
            title: trimmedTitle,
            sortKey: trimmedSortKey.isEmpty ? nil : trimmedSortKey
        ) {
            onAdd(child)
        }
        
        title = ""
        sortKey = ""
    }
}

#Preview {
    let series = MediaItem(title: "Breaking Bad", kind: .tvSeries)
    
    return MediaHierarchyView(parentItem: series)
        .modelContainer(for: [MediaItem.self, Note.self, MediaAttribute.self], inMemory: true)
}




