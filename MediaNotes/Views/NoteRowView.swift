import SwiftUI
import SwiftData

/// Card view for displaying a note
struct NoteRowView: View {
    let note: Note
    var showMediaInfo: Bool = false
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    @State private var showingActions = false
    
    private var timeProvider: TimeProvider {
        DependencyProvider.shared.dependencies.timeProvider
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            // Header
            HStack(alignment: .top) {
                // Date & edit indicator
                VStack(alignment: .leading, spacing: 2) {
                    Text(note.formattedDate(relativeTo: timeProvider.now))
                        .font(Theme.monoFont(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                    
                    if note.wasEdited {
                        Text("edited")
                            .font(Theme.monoFont(size: 10))
                            .foregroundStyle(Theme.textTertiary.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Media info (if showing in search results)
                if showMediaInfo, let mediaItem = note.mediaItem {
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: mediaItem.kind.iconName)
                            .font(.system(size: 11))
                        Text(mediaItem.title)
                            .font(Theme.bodyFont(size: 12))
                            .lineLimit(1)
                    }
                    .foregroundStyle(Theme.color(for: mediaItem.kind))
                    .padding(.horizontal, Theme.spacingSM)
                    .padding(.vertical, Theme.spacingXS)
                    .background(Theme.color(for: mediaItem.kind).opacity(0.15))
                    .clipShape(Capsule())
                }
                
                // Action menu
                if onEdit != nil || onDelete != nil {
                    Menu {
                        if let onEdit = onEdit {
                            Button {
                                onEdit()
                            } label: {
                                Label("Edit Note", systemImage: "pencil")
                            }
                        }
                        
                        if let onDelete = onDelete {
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
                                Label("Delete Note", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                }
            }
            
            // Quote (if present)
            if let quote = note.quote, !quote.isEmpty {
                HStack(spacing: Theme.spacingSM) {
                    Rectangle()
                        .fill(Theme.accent.opacity(0.5))
                        .frame(width: 3)
                    
                    Text(quote)
                        .font(.system(size: 15, design: .serif))
                        .italic()
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(3)
                }
                .padding(.vertical, Theme.spacingXS)
            }
            
            // Note text
            Text(note.text)
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            // Time offset (if present)
            if let timeOffset = note.formattedTimeOffset {
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(timeOffset)
                        .font(Theme.monoFont(size: 12))
                }
                .foregroundStyle(Theme.textTertiary)
                .padding(.top, Theme.spacingXS)
            }
        }
        .padding(Theme.spacingMD)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .stroke(Theme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Compact Note Row

struct NoteRowCompactView: View {
    let note: Note
    var showMediaInfo: Bool = false
    
    private var timeProvider: TimeProvider {
        DependencyProvider.shared.dependencies.timeProvider
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            HStack {
                Text(note.shortDate(relativeTo: timeProvider.now))
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                
                if showMediaInfo, let mediaItem = note.mediaItem {
                    Text("·")
                        .foregroundStyle(Theme.textTertiary)
                    
                    Text(mediaItem.title)
                        .font(Theme.bodyFont(size: 11))
                        .foregroundStyle(Theme.color(for: mediaItem.kind))
                        .lineLimit(1)
                }
                
                Spacer()
                
                if note.wasEdited {
                    Image(systemName: "pencil")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            
            Text(note.preview)
                .font(Theme.bodyFont(size: 15))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
        }
        .padding(.vertical, Theme.spacingSM)
    }
}

// MARK: - Preview

#Preview {
    let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
    let note = Note(text: "This episode really shows Walter's transformation. The scene in the desert is unforgettable. You can see the exact moment he decides to embrace his darker side.", mediaItem: mediaItem)
    
    return VStack(spacing: Theme.spacingMD) {
        NoteRowView(
            note: note,
            onEdit: { },
            onDelete: { }
        )
        
        NoteRowView(
            note: note,
            showMediaInfo: true,
            onEdit: { },
            onDelete: { }
        )
        
        NoteRowCompactView(note: note, showMediaInfo: true)
            .padding(.horizontal)
            .background(Theme.secondaryBackground)
    }
    .padding()
    .background(Theme.background)
}




