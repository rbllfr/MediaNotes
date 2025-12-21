import Foundation
import SwiftData

/// Represents a single moment of reflection attached to a media item.
/// User thoughts are sacred - never auto-modified.
@Model
final class Note: Sendable, Equatable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Unique identifier
    var id: UUID
    
    /// The note text content
    var text: String
    
    /// When the note was created
    var createdAt: Date
    
    /// When the note was last edited (nil if never edited)
    var editedAt: Date?
    
    /// Optional quote from the media (for future use)
    var quote: String?
    
    /// Optional time offset in seconds (for music/video)
    var timeOffset: Double?
    
    // MARK: - Relationships
    
    /// The media item this note is attached to (required)
    var mediaItem: MediaItem?
    
    // MARK: - Initialization
    
    init(text: String, mediaItem: MediaItem?, quote: String? = nil, createdAt: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.createdAt = createdAt
        self.editedAt = nil
        self.quote = quote
        self.timeOffset = nil
        self.mediaItem = mediaItem
    }
    
    // MARK: - Computed Properties
    
    /// Whether this note has been edited
    var wasEdited: Bool {
        editedAt != nil
    }
    
    /// The most recent modification date
    var lastModified: Date {
        editedAt ?? createdAt
    }
    
    /// A preview of the note text (first 100 characters)
    var preview: String {
        if text.count <= 100 {
            return text
        }
        let index = text.index(text.startIndex, offsetBy: 100)
        return String(text[..<index]) + "…"
    }
    
    /// Formatted creation date for display
    @MainActor
    var formattedDate: String {
        formattedDate(relativeTo: DependencyProvider.shared.dependencies.timeProvider.now)
    }
    
    /// Formatted creation date for display, relative to a specific date
    /// - Parameter referenceDate: The date to compare against (default: now)
    /// - Returns: Formatted date string
    func formattedDate(relativeTo referenceDate: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDate(createdAt, inSameDayAs: referenceDate) {
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: createdAt))"
        } else if Calendar.current.isDate(createdAt, inSameDayAs: referenceDate.addingTimeInterval(-86400)) {
            formatter.dateFormat = "h:mm a"
            return "Yesterday, \(formatter.string(from: createdAt))"
        } else if Calendar.current.isDate(createdAt, equalTo: referenceDate, toGranularity: .year) {
            formatter.dateFormat = "MMM d, h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        
        return formatter.string(from: createdAt)
    }
    
    /// Short date format for lists
    @MainActor
    var shortDate: String {
        shortDate(relativeTo: DependencyProvider.shared.dependencies.timeProvider.now)
    }
    
    /// Short date format for lists, relative to a specific date
    /// - Parameter referenceDate: The date to compare against (default: now)
    /// - Returns: Short formatted date string
    func shortDate(relativeTo referenceDate: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDate(createdAt, inSameDayAs: referenceDate) {
            formatter.dateFormat = "h:mm a"
        } else if Calendar.current.isDate(createdAt, inSameDayAs: referenceDate.addingTimeInterval(-86400)) {
            return "Yesterday"
        } else if Calendar.current.isDate(createdAt, equalTo: referenceDate, toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
        } else if Calendar.current.isDate(createdAt, equalTo: referenceDate, toGranularity: .year) {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Methods
    
    /// Update the note text and set editedAt
    func update(text: String) {
        self.text = text
        self.editedAt = Date()
    }
    
    /// Update the optional quote
    func setQuote(_ quote: String?) {
        self.quote = quote
        self.editedAt = Date()
    }
    
    /// Update the time offset
    func setTimeOffset(_ offset: Double?) {
        self.timeOffset = offset
        self.editedAt = Date()
    }
}

// MARK: - Searchable

extension Note {
    /// Text content for search indexing
    var searchableText: String {
        var parts = [text]
        if let quote = quote { parts.append(quote) }
        return parts.joined(separator: " ")
    }
}

// MARK: - Time Offset Formatting

extension Note {
    /// Formatted time offset string (e.g., "1:23:45" or "23:45")
    var formattedTimeOffset: String? {
        guard let offset = timeOffset else { return nil }
        
        let hours = Int(offset) / 3600
        let minutes = (Int(offset) % 3600) / 60
        let seconds = Int(offset) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}




