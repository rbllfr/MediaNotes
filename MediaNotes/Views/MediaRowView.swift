import SwiftUI
import SwiftData

/// Card view for displaying a media item in lists
struct MediaRowView: View {
    let mediaItem: MediaItem
    
    private var accentColor: Color {
        Theme.color(for: mediaItem.kind)
    }
    
    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            // Artwork / Placeholder
            artworkView
            
            // Content
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                // Media type badge
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: mediaItem.kind.iconName)
                        .font(.system(size: 10))
                    Text(mediaItem.kind.displayName.uppercased())
                        .font(Theme.monoFont(size: 10))
                }
                .foregroundStyle(accentColor)
                
                // Title
                Text(mediaItem.title)
                    .font(Theme.headingFont(size: 17))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                
                // Subtitle
                if let subtitle = mediaItem.displaySubtitle {
                    Text(subtitle)
                        .font(Theme.bodyFont(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: Theme.spacingXS)
                
                // Stats row
                HStack(spacing: Theme.spacingMD) {
                    // Note count
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: "note.text")
                            .font(.system(size: 12))
                        Text("\(mediaItem.totalNoteCount)")
                            .font(Theme.monoFont(size: 12))
                    }
                    .foregroundStyle(Theme.textTertiary)
                    
                    // Children count (if applicable)
                    if let children = mediaItem.children, !children.isEmpty {
                        HStack(spacing: Theme.spacingXS) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 12))
                            Text("\(children.count)")
                                .font(Theme.monoFont(size: 12))
                        }
                        .foregroundStyle(Theme.textTertiary)
                    }
                    
                    Spacer()
                    
                    // Last note date
                    if let lastDate = mediaItem.lastNoteDate {
                        Text(formatDate(lastDate))
                            .font(Theme.monoFont(size: 11))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(Theme.spacingMD)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMD)
                .stroke(Theme.border, lineWidth: 0.5)
        )
    }
    
    // MARK: - Artwork View
    
    @ViewBuilder
    private var artworkView: some View {
        Group {
            if let artworkURL = mediaItem.artworkURL {
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
        .frame(width: 90, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusSM)
                .stroke(Theme.border, lineWidth: 0.5)
        )
    }
    
    private var placeholderArtwork: some View {
        ZStack {
            LinearGradient(
                colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: mediaItem.kind.iconName)
                .font(.system(size: 24))
                .foregroundStyle(accentColor.opacity(0.6))
        }
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Compact Row Variant

struct MediaRowCompactView: View {
    let mediaItem: MediaItem
    var showNoteCount: Bool = true
    
    private var accentColor: Color {
        Theme.color(for: mediaItem.kind)
    }
    
    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            // Icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: mediaItem.kind.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(accentColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(mediaItem.title)
                    .font(Theme.bodyFont(size: 16))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                
                if let subtitle = mediaItem.displaySubtitle {
                    Text(subtitle)
                        .font(Theme.bodyFont(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Note count badge
            if showNoteCount && mediaItem.totalNoteCount > 0 {
                // Note count
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: "note.text")
                        .font(.system(size: 12))
                    Text("\(mediaItem.totalNoteCount)")
                        .font(Theme.monoFont(size: 12))
                }
                .foregroundStyle(Theme.textTertiary)
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
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

#Preview {
    VStack(spacing: Theme.spacingMD) {
        MediaRowView(mediaItem: MediaItem(
            title: "Breaking Bad",
            kind: .tvSeries,
            subtitle: "Vince Gilligan"
        ))
        
        MediaRowCompactView(mediaItem: MediaItem(
            title: "The Great Gatsby",
            kind: .book,
            subtitle: "F. Scott Fitzgerald"
        ))
    }
    .padding()
    .background(Theme.background)
}




