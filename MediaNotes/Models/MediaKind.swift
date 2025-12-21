import Foundation

/// Represents the type of media item.
/// Generic and extensible - not hardcoded to specific platforms or services.
enum MediaKind: String, Codable, CaseIterable, Identifiable {
    case movie = "movie"
    case tvSeries = "tv_series"
    case episode = "episode"
    case book = "book"
    case chapter = "chapter"
    case album = "album"
    case track = "track"
    case liveEvent = "live_event"
    case performance = "performance"
    case other = "other"
    
    var id: String { rawValue }
    
    /// Human-readable display name
    var displayName: String {
        switch self {
        case .movie: return "Movie"
        case .tvSeries: return "TV Series"
        case .episode: return "Episode"
        case .book: return "Book"
        case .chapter: return "Chapter"
        case .album: return "Album"
        case .track: return "Track"
        case .liveEvent: return "Live Event"
        case .performance: return "Performance"
        case .other: return "Other"
        }
    }
    
    /// SF Symbol icon name for this media type
    var iconName: String {
        switch self {
        case .movie: return "film"
        case .tvSeries: return "tv"
        case .episode: return "play.tv"
        case .book: return "book.closed"
        case .chapter: return "bookmark"
        case .album: return "opticaldisc"
        case .track: return "music.note"
        case .liveEvent: return "ticket"
        case .performance: return "theatermasks"
        case .other: return "square.grid.2x2"
        }
    }
    
    /// Media kinds that can contain child items
    var canHaveChildren: Bool {
        switch self {
        case .tvSeries, .book, .album, .liveEvent:
            return true
        case .movie, .episode, .chapter, .track, .performance, .other:
            return false
        }
    }
    
    /// Expected child type for hierarchical media
    var childKind: MediaKind? {
        switch self {
        case .tvSeries: return .episode
        case .book: return .chapter
        case .album: return .track
        case .liveEvent: return .performance
        default: return nil
        }
    }
    
    /// Color associated with this media type for UI
    var accentColorName: String {
        switch self {
        case .movie: return "MovieColor"
        case .tvSeries, .episode: return "TVColor"
        case .book, .chapter: return "BookColor"
        case .album, .track: return "MusicColor"
        case .liveEvent, .performance: return "EventColor"
        case .other: return "AccentColor"
        }
    }
}




