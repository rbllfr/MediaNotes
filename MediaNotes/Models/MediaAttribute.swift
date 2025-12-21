import Foundation
import SwiftData

/// Flexible key-value metadata attached to a MediaItem.
/// Allows unlimited extension without schema changes.
@Model
final class MediaAttribute: Sendable, Equatable {
    static func == (lhs: MediaAttribute, rhs: MediaAttribute) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Unique identifier
    var id: UUID
    
    /// Attribute key (namespaced string, e.g., "tv.seasonNumber")
    var key: String
    
    /// Attribute value (always stored as string)
    var value: String
    
    /// The media item this attribute belongs to
    var mediaItem: MediaItem?
    
    init(key: MediaAttributeKey, value: String, mediaItem: MediaItem? = nil) {
        self.id = UUID()
        self.key = key.rawValue
        self.value = value
        self.mediaItem = mediaItem
    }
    
    init(keyString: String, value: String, mediaItem: MediaItem? = nil) {
        self.id = UUID()
        self.key = keyString
        self.value = value
        self.mediaItem = mediaItem
    }
    
    /// Type-safe access to the attribute key
    var attributeKey: MediaAttributeKey {
        MediaAttributeKey(rawValue: key)
    }
    
    /// Display name for the key
    var displayName: String {
        attributeKey.displayName
    }
}

// MARK: - Convenience Extensions

extension MediaAttribute {
    /// Creates an attribute for season number
    static func season(_ number: Int, for mediaItem: MediaItem? = nil) -> MediaAttribute {
        MediaAttribute(key: .seasonNumber, value: String(number), mediaItem: mediaItem)
    }
    
    /// Creates an attribute for episode number
    static func episode(_ number: Int, for mediaItem: MediaItem? = nil) -> MediaAttribute {
        MediaAttribute(key: .episodeNumber, value: String(number), mediaItem: mediaItem)
    }
    
    /// Creates an attribute for release year
    static func year(_ year: Int, for mediaItem: MediaItem? = nil) -> MediaAttribute {
        MediaAttribute(key: .releaseYear, value: String(year), mediaItem: mediaItem)
    }
    
    /// Creates an attribute for creator
    static func creator(_ name: String, for mediaItem: MediaItem? = nil) -> MediaAttribute {
        MediaAttribute(key: .creator, value: name, mediaItem: mediaItem)
    }
    
    /// Creates an attribute for author
    static func author(_ name: String, for mediaItem: MediaItem? = nil) -> MediaAttribute {
        MediaAttribute(key: .author, value: name, mediaItem: mediaItem)
    }
    
    /// Creates an attribute for artist
    static func artist(_ name: String, for mediaItem: MediaItem? = nil) -> MediaAttribute {
        MediaAttribute(key: .artist, value: name, mediaItem: mediaItem)
    }
}




