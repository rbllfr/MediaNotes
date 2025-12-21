import Foundation

/// Type-safe attribute key with namespacing for extensibility.
/// Provides well-known keys while supporting unknown future keys.
struct MediaAttributeKey: RawRepresentable, Hashable, Codable, Sendable {
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    // MARK: - Common Attributes
    
    /// Creator (director, showrunner, author)
    static let creator = MediaAttributeKey(rawValue: "common.creator")
    
    /// Release year
    static let releaseYear = MediaAttributeKey(rawValue: "common.releaseYear")
    
    /// Primary language
    static let language = MediaAttributeKey(rawValue: "common.language")
    
    /// Genre (comma-separated if multiple)
    static let genre = MediaAttributeKey(rawValue: "common.genre")
    
    /// Runtime in minutes
    static let runtime = MediaAttributeKey(rawValue: "common.runtime")
    
    // MARK: - TV Attributes
    
    /// Season number for episodes
    static let seasonNumber = MediaAttributeKey(rawValue: "tv.seasonNumber")
    
    /// Episode number within season
    static let episodeNumber = MediaAttributeKey(rawValue: "tv.episodeNumber")
    
    /// Parent series title (for episodes)
    static let seriesTitle = MediaAttributeKey(rawValue: "tv.seriesTitle")
    
    /// Network or streaming service
    static let network = MediaAttributeKey(rawValue: "tv.network")
    
    // MARK: - Book Attributes
    
    /// Author name
    static let author = MediaAttributeKey(rawValue: "book.author")
    
    /// ISBN identifier
    static let isbn = MediaAttributeKey(rawValue: "book.isbn")
    
    /// Publisher name
    static let publisher = MediaAttributeKey(rawValue: "book.publisher")
    
    /// Page count
    static let pageCount = MediaAttributeKey(rawValue: "book.pageCount")
    
    // MARK: - Music Attributes
    
    /// Artist name
    static let artist = MediaAttributeKey(rawValue: "music.artist")
    
    /// Album title (for tracks)
    static let albumTitle = MediaAttributeKey(rawValue: "music.albumTitle")
    
    /// Track number on album
    static let trackNumber = MediaAttributeKey(rawValue: "music.trackNumber")
    
    /// Record label
    static let label = MediaAttributeKey(rawValue: "music.label")
    
    // MARK: - Event Attributes
    
    /// Venue name
    static let venue = MediaAttributeKey(rawValue: "event.venue")
    
    /// City where event took place
    static let city = MediaAttributeKey(rawValue: "event.city")
    
    /// Date of the event (ISO 8601)
    static let eventDate = MediaAttributeKey(rawValue: "event.date")
    
    /// Performers (comma-separated)
    static let performers = MediaAttributeKey(rawValue: "event.performers")
    
    // MARK: - Helpers
    
    /// Returns the namespace prefix (e.g., "common", "tv", "book")
    var namespace: String {
        rawValue.components(separatedBy: ".").first ?? ""
    }
    
    /// Returns the key name without namespace
    var keyName: String {
        let parts = rawValue.components(separatedBy: ".")
        return parts.count > 1 ? parts.dropFirst().joined(separator: ".") : rawValue
    }
    
    /// Human-readable display name
    var displayName: String {
        switch self {
        case .creator: return "Creator"
        case .releaseYear: return "Release Year"
        case .language: return "Language"
        case .genre: return "Genre"
        case .runtime: return "Runtime"
        case .seasonNumber: return "Season"
        case .episodeNumber: return "Episode"
        case .seriesTitle: return "Series"
        case .network: return "Network"
        case .author: return "Author"
        case .isbn: return "ISBN"
        case .publisher: return "Publisher"
        case .pageCount: return "Pages"
        case .artist: return "Artist"
        case .albumTitle: return "Album"
        case .trackNumber: return "Track #"
        case .label: return "Label"
        case .venue: return "Venue"
        case .city: return "City"
        case .eventDate: return "Date"
        case .performers: return "Performers"
        default:
            // Fallback for unknown keys: capitalize the key name
            return keyName.capitalized
        }
    }
    
    /// Suggested keys for a given media kind
    static func suggestedKeys(for kind: MediaKind) -> [MediaAttributeKey] {
        var keys: [MediaAttributeKey] = [.creator, .releaseYear, .genre]
        
        switch kind {
        case .movie:
            keys.append(contentsOf: [.runtime, .language])
        case .tvSeries:
            keys.append(contentsOf: [.network, .language])
        case .episode:
            keys.append(contentsOf: [.seasonNumber, .episodeNumber, .seriesTitle, .runtime])
        case .book, .chapter:
            keys.append(contentsOf: [.author, .isbn, .publisher, .pageCount])
        case .album:
            keys.append(contentsOf: [.artist, .label])
        case .track:
            keys.append(contentsOf: [.artist, .albumTitle, .trackNumber])
        case .liveEvent, .performance:
            keys.append(contentsOf: [.venue, .city, .eventDate, .performers])
        case .other:
            break
        }
        
        return keys
    }
}




