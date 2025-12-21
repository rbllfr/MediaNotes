import Foundation
import SwiftData

// MARK: - Protocol

/// Protocol for media item data access - enables testing with mocks
protocol MediaRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [MediaItem]
    func fetchRootItems() async throws -> [MediaItem]
    func fetchItems(matching searchText: String) async throws -> [MediaItem]
    func fetchItem(by id: UUID) async throws -> MediaItem?
    func save(_ item: MediaItem) async throws
    func update(_ item: MediaItem) async throws
    func delete(_ item: MediaItem) async throws
    func addChild(to parent: MediaItem, title: String, sortKey: String?) async throws -> MediaItem
}

// MARK: - SwiftData Implementation

/// SwiftData-backed implementation of MediaRepository
/// Uses a shared ModelContext to ensure consistency across repositories
@MainActor
final class SwiftDataMediaRepository: MediaRepositoryProtocol {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() async throws -> [MediaItem] {
        let descriptor = FetchDescriptor<MediaItem>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchRootItems() async throws -> [MediaItem] {
        let descriptor = FetchDescriptor<MediaItem>(
            predicate: #Predicate<MediaItem> { $0.parent == nil },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchItems(matching searchText: String) async throws -> [MediaItem] {
        let descriptor = FetchDescriptor<MediaItem>(
            predicate: #Predicate<MediaItem> { item in
                item.title.localizedStandardContains(searchText)
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchItem(by id: UUID) async throws -> MediaItem? {
        let descriptor = FetchDescriptor<MediaItem>(
            predicate: #Predicate<MediaItem> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func save(_ item: MediaItem) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    
    func update(_ item: MediaItem) async throws {
        item.updatedAt = Date()
        try modelContext.save()
    }
    
    func delete(_ item: MediaItem) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func addChild(to parent: MediaItem, title: String, sortKey: String?) async throws -> MediaItem {
        guard let childKind = parent.kind.childKind else {
            throw RepositoryError.invalidOperation("Parent item cannot have children")
        }
        
        let child = MediaItem(
            title: title,
            kind: childKind,
            sortKey: sortKey
        )
        
        modelContext.insert(child)
        parent.addChild(child)
        parent.updatedAt = Date()
        
        try modelContext.save()
        return child
    }
}

// MARK: - Errors

enum RepositoryError: LocalizedError {
    case notFound
    case invalidOperation(String)
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item not found"
        case .invalidOperation(let message):
            return message
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}

