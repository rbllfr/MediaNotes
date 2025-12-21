import Foundation
import FoundationModels
import SwiftData

// MARK: - Protocol

/// Protocol for generating insights from user notes
protocol InsightsProviding: Sendable {
    /// Checks if the insights feature is available on the current device
    var availability: SystemLanguageModel.Availability { get async }
    
    /// Generates insights based on all user notes
    /// - Returns: Generated insights with summary and rationale
    /// - Throws: Error if insights generation fails
    func generateInsights() async throws -> Insights
    
    /// Generates insights for a specific media item
    /// - Parameter mediaItem: The media item to generate insights for
    /// - Returns: Generated insights with summary and rationale
    /// - Throws: Error if insights generation fails
    func generateInsights(for mediaItem: MediaItem) async throws -> Insights
}

// MARK: - Foundation Models Implementation

/// Implementation using Apple's FoundationModels framework
@MainActor
final class FoundationModelsInsightsProvider: InsightsProviding {
    
    // MARK: - Dependencies
    
    private let model: SystemLanguageModel
    private let noteRepository: any NoteRepositoryProtocol
    
    // MARK: - Initialization
    
    init(model: SystemLanguageModel = .default, noteRepository: any NoteRepositoryProtocol) {
        self.model = model
        self.noteRepository = noteRepository
    }
    
    // MARK: - InsightsProviding
    
    var availability: SystemLanguageModel.Availability {
        get async {
            model.availability
        }
    }
    
    func generateInsights() async throws -> Insights {
        let session = makeSession()
        
        let response = try await session.respond(
            to: "Gather all the notes using the notesDatabase tool and use them to generate insights",
            generating: Insights.self
        )
        
        return response.content
    }
    
    func generateInsights(for mediaItem: MediaItem) async throws -> Insights {
        let session = makeSession()
        
        let response = try await session.respond(
            to: "Gather the notes for media with item ID: \(mediaItem.id) using the notesDatabase tool and use them to generate insights",
            generating: Insights.self
        )
        
        return response.content
    }
    
    private func makeSession() -> LanguageModelSession {
        LanguageModelSession(
            model: model,
            tools: [NotesDatabaseTool(noteRepository: noteRepository)],
            instructions: instructions
        )
    }
    
    private let instructions: String = """
        You are a helpful assistant that provides insights based on user notes for various media.

        The user can ask either for overall insights based on all notes added, or specific insioghts for a single media item.

        Provide the insights in second person, as if you were speaking to a person.

        Include suggestions for similar content they might enjoy.

        If you do not have enough notes, just say it.
        """
    
}

// MARK: - Models

/// Insights generated from user notes
@Generable(description: "Insights based in the notes the user added for various media")
struct Insights: Equatable {
    
    @Guide(description: "A short summary describing the user testes, provided in second person.")
    var summary: String
    
    @Guide(description: "A breakdown of the elements that led to the provided insights, provided in second person.")
    var rationale: String
    
    @Guide(description: "Personalized recommendations for new media the user might enjoy, based on their notes and preferences, provided in second person.")
    var recommendations: String
    
    /// Example insights for testing and previews
    static let example = Insights(
        summary: "You enjoy thought-provoking content that challenges your perspective.",
        rationale: "Your notes reveal a pattern of engagement with media that explores complex themes and philosophical questions. You frequently highlight moments that make you think differently about familiar concepts.",
        recommendations: "Based on your preferences, you might enjoy 'Arrival', 'The Leftovers', or 'Recursion' by Blake Crouch. These works share the intellectual depth and emotional resonance you seem to appreciate."
    )
}

// MARK: - Tools

/// Shared data models for tools
@Generable(description: "The media the note is for")
struct MediaItemData: Equatable {
    @Guide(description: "The media title the note is for")
    var title: String
    
    @Guide(description: "The media kind the note is for")
    var kind: String
    
    @Guide(description: "The parents of this media. For example, the episode in a series")
    var parents: [MediaItemData]?
}

@Generable(description: "A note added by the user")
struct NoteData: Equatable {
    
    @Guide(description: "The note text")
    var text: String
    
    @Guide(description: "The date the note was added, formatted as ISO8601 string")
    var createdAtISO8601: String
    
    @Guide(description: "Optional quote from the note")
    var quote: String?
    
    @Guide(description: "The media item the note is for")
    var mediaItem: MediaItemData
}

/// Tool that provides access to user notes for the language model
struct NotesDatabaseTool: Tool {
    let name = "notesDatabase"
    let description = "Provides user notes for media items. Can return all notes or filter by a specific media item ID."
    
    private let noteRepository: any NoteRepositoryProtocol
    
    init(noteRepository: any NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }
    
    @Generable
    struct Arguments {
        @Guide(description: "The ID of the media item to gather notes for. If not set, returns all notes.")
        let mediaItemId: String?
    }
    
    func call(arguments: Arguments) async throws -> [NoteData] {
        let notes: [Note]
        if let mediaItemId = arguments.mediaItemId {
            // Fetch all notes and filter by media item ID
            let allNotes = try await noteRepository.fetchAll()
            notes = allNotes.filter { $0.mediaItem?.id.uuidString == mediaItemId }
        } else {
            notes = try await noteRepository.fetchAll()
        }
        
        return notes.compactMap { note in
            guard let mediaItem = note.mediaItem else { return nil }
            
            return NoteData(
                text: note.text,
                createdAtISO8601: ISO8601DateFormatter().string(from: note.createdAt),
                quote: note.quote,
                mediaItem: MediaItemData(
                    title: mediaItem.title,
                    kind: mediaItem.kind.displayName,
                    parents: mediaItem.parent.map {
                        [
                            MediaItemData(
                                title: $0.title,
                                kind: $0.kind.displayName,
                            )
                        ]
                    } ?? []
                )
            )
        }
    }
}

