import Foundation
import SwiftData

/// Represents any media item the user can attach notes to.
/// Supports hierarchical structures (series → episodes, album → tracks, etc.)
@Model
final class MediaItem: Sendable, Equatable {
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Unique identifier
    var id: UUID
    
    /// Primary title of the media item
    var title: String
    
    /// Type of media (movie, episode, book, etc.)
    private var kindRawValue: String
    
    /// Optional subtitle (author, artist, venue, etc.)
    var subtitle: String?
    
    /// URL string for artwork image
    var artworkURLString: String?
    
    /// Optional sorting key for ordering siblings within a parent
    /// Examples: "S02E03", "01", "2024-11-18"
    var sortKey: String?
    
    /// Timestamp when this item was first created
    var createdAt: Date
    
    /// Timestamp when this item was last modified
    var updatedAt: Date
    
    // MARK: - Relationships
    
    /// Parent media item (e.g., series for an episode)
    var parent: MediaItem?
    
    /// Child media items (e.g., episodes for a series)
    @Relationship(deleteRule: .cascade, inverse: \MediaItem.parent)
    var children: [MediaItem]?
    
    /// Notes attached to this media item
    @Relationship(deleteRule: .cascade, inverse: \Note.mediaItem)
    var notes: [Note]?
    
    /// Flexible metadata attributes
    @Relationship(deleteRule: .cascade, inverse: \MediaAttribute.mediaItem)
    var attributes: [MediaAttribute]?
    
    // MARK: - Initialization
    
    init(
        title: String,
        kind: MediaKind,
        subtitle: String? = nil,
        artworkURLString: String? = nil,
        sortKey: String? = nil,
        parent: MediaItem? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.kindRawValue = kind.rawValue
        self.subtitle = subtitle
        self.artworkURLString = artworkURLString
        self.sortKey = sortKey
        self.createdAt = Date()
        self.updatedAt = Date()
        self.parent = parent
        self.children = []
        self.notes = []
        self.attributes = []
    }
    
    // MARK: - Computed Properties
    
    /// Type-safe access to the media kind
    var kind: MediaKind {
        get { MediaKind(rawValue: kindRawValue) ?? .other }
        set { 
            kindRawValue = newValue.rawValue
            updatedAt = Date()
        }
    }
    
    /// URL for artwork (if valid)
    var artworkURL: URL? {
        guard let urlString = artworkURLString else { return nil }
        return URL(string: urlString)
    }
    
    /// Total number of notes attached to this item
    var noteCount: Int {
        notes?.count ?? 0
    }
    
    /// Date of the most recent note (or nil if no notes)
    var lastNoteDate: Date? {
        notes?.max(by: { $0.createdAt < $1.createdAt })?.createdAt
    }
    
    /// All notes including those from children, sorted by date
    var allNotes: [Note] {
        var result = notes ?? []
        for child in (children ?? []) {
            result.append(contentsOf: child.allNotes)
        }
        return result.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Total note count including children
    var totalNoteCount: Int {
        let directNotes = notes?.count ?? 0
        let childNotes = children?.reduce(0) { $0 + $1.totalNoteCount } ?? 0
        return directNotes + childNotes
    }
    
    /// Sorted children using sortKey
    var sortedChildren: [MediaItem] {
        (children ?? []).sorted { first, second in
            if let key1 = first.sortKey, let key2 = second.sortKey {
                return key1.localizedStandardCompare(key2) == .orderedAscending
            }
            return first.createdAt < second.createdAt
        }
    }
    
    /// Display subtitle with additional context
    var displaySubtitle: String? {
        if let subtitle = subtitle, !subtitle.isEmpty {
            return subtitle
        }
        
        // Generate subtitle from attributes based on kind
        switch kind {
        case .episode:
            if let season = getAttribute(.seasonNumber),
               let episode = getAttribute(.episodeNumber) {
                return "S\(season)E\(episode)"
            }
        case .track:
            if let artist = getAttribute(.artist) {
                return artist
            }
        case .book, .chapter:
            if let author = getAttribute(.author) {
                return author
            }
        case .liveEvent, .performance:
            if let venue = getAttribute(.venue),
               let city = getAttribute(.city) {
                return "\(venue), \(city)"
            }
        default:
            break
        }
        
        return nil
    }
    
    /// Full path title including parent (e.g., "Breaking Bad → Ozymandias")
    var fullPathTitle: String {
        if let parent = parent {
            return "\(parent.title) → \(title)"
        }
        return title
    }
    
    // MARK: - Attribute Helpers
    
    /// Get attribute value by key
    func getAttribute(_ key: MediaAttributeKey) -> String? {
        attributes?.first { $0.key == key.rawValue }?.value
    }
    
    /// Set or update an attribute
    func setAttribute(_ key: MediaAttributeKey, value: String?) {
        updatedAt = Date()
        
        if let value = value {
            if let existing = attributes?.first(where: { $0.key == key.rawValue }) {
                existing.value = value
            } else {
                let attribute = MediaAttribute(key: key, value: value, mediaItem: self)
                if attributes == nil {
                    attributes = []
                }
                attributes?.append(attribute)
            }
        } else {
            // Remove attribute if value is nil
            attributes?.removeAll { $0.key == key.rawValue }
        }
    }
    
    /// Remove an attribute
    func removeAttribute(_ key: MediaAttributeKey) {
        attributes?.removeAll { $0.key == key.rawValue }
        updatedAt = Date()
    }
    
    // MARK: - Child Management
    
    /// Add a child media item
    func addChild(_ child: MediaItem) {
        child.parent = self
        if children == nil {
            children = []
        }
        children?.append(child)
        updatedAt = Date()
    }
    
    /// Create and add a new child episode/chapter/track
    func createChild(title: String, sortKey: String? = nil) -> MediaItem? {
        guard let childKind = kind.childKind else { return nil }
        
        let child = MediaItem(
            title: title,
            kind: childKind,
            sortKey: sortKey,
            parent: self
        )
        addChild(child)
        return child
    }
}

// MARK: - Searchable

extension MediaItem {
    /// Text content for search indexing
    var searchableText: String {
        var parts = [title]
        if let subtitle = subtitle { parts.append(subtitle) }
        if let parent = parent { parts.append(parent.title) }
        
        // Include attribute values
        for attr in (attributes ?? []) {
            parts.append(attr.value)
        }
        
        return parts.joined(separator: " ")
    }
}




