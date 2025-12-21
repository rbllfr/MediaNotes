import Foundation
@testable import MediaNotes

/// Mock implementation of MediaRepository for unit testing
@MainActor
final class MockMediaRepository: MediaRepositoryProtocol {
    
    // MARK: - Invocation Tracking
    
    enum Invocation: Equatable {
        case fetchAll
        case fetchRootItems
        case fetchItemsMatching(searchText: String)
        case fetchItem(id: UUID)
        case save(item: MediaItem)
        case update(item: MediaItem)
        case delete(item: MediaItem)
        case addChild(parent: MediaItem, title: String, sortKey: String?)
        
        static func == (lhs: Invocation, rhs: Invocation) -> Bool {
            switch (lhs, rhs) {
            case (.fetchAll, .fetchAll),
                 (.fetchRootItems, .fetchRootItems):
                return true
            case let (.fetchItemsMatching(lText), .fetchItemsMatching(rText)):
                return lText == rText
            case let (.fetchItem(lId), .fetchItem(rId)):
                return lId == rId
            case let (.save(lItem), .save(rItem)):
                return lItem.id == rItem.id
            case let (.update(lItem), .update(rItem)):
                return lItem.id == rItem.id
            case let (.delete(lItem), .delete(rItem)):
                return lItem.id == rItem.id
            case let (.addChild(lParent, lTitle, lSortKey), .addChild(rParent, rTitle, rSortKey)):
                return lParent.id == rParent.id && lTitle == rTitle && lSortKey == rSortKey
            default:
                return false
            }
        }
    }
    
    private(set) var invocations: [Invocation] = []
    
    // MARK: - Stored Data (for verification)
    
    var items: [MediaItem] = []
    var savedItems: [MediaItem] = []
    var deletedItems: [MediaItem] = []
    
    // MARK: - Result Simulation
    
    var fetchAllResult: Result<[MediaItem], Error>?
    var saveResult: Result<Void, Error>?
    var addChildResult: Result<MediaItem, Error>?
    
    // MARK: - Error Simulation
    
    var shouldThrowError = false
    var errorToThrow: Error = RepositoryError.notFound
    
    // MARK: - Protocol Implementation
    
    func fetchAll() async throws -> [MediaItem] {
        invocations.append(.fetchAll)
        
        if let result = fetchAllResult {
            switch result {
            case .success(let items):
                return items
            case .failure(let error):
                throw error
            }
        }
        
        if shouldThrowError { throw errorToThrow }
        return items
    }
    
    func fetchRootItems() async throws -> [MediaItem] {
        invocations.append(.fetchRootItems)
        if shouldThrowError { throw errorToThrow }
        return items.filter { $0.parent == nil }
    }
    
    func fetchItems(matching searchText: String) async throws -> [MediaItem] {
        invocations.append(.fetchItemsMatching(searchText: searchText))
        if shouldThrowError { throw errorToThrow }
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    func fetchItem(by id: UUID) async throws -> MediaItem? {
        invocations.append(.fetchItem(id: id))
        if shouldThrowError { throw errorToThrow }
        return items.first { $0.id == id }
    }
    
    func save(_ item: MediaItem) async throws {
        invocations.append(.save(item: item))
        
        if let result = saveResult {
            switch result {
            case .success:
                break
            case .failure(let error):
                throw error
            }
        }
        
        if shouldThrowError { throw errorToThrow }
        savedItems.append(item)
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
    }
    
    func update(_ item: MediaItem) async throws {
        invocations.append(.update(item: item))
        if shouldThrowError { throw errorToThrow }
        item.updatedAt = Date()
    }
    
    func delete(_ item: MediaItem) async throws {
        invocations.append(.delete(item: item))
        if shouldThrowError { throw errorToThrow }
        deletedItems.append(item)
        items.removeAll { $0.id == item.id }
    }
    
    func addChild(to parent: MediaItem, title: String, sortKey: String?) async throws -> MediaItem {
        invocations.append(.addChild(parent: parent, title: title, sortKey: sortKey))
        
        if let result = addChildResult {
            switch result {
            case .success(let child):
                return child
            case .failure(let error):
                throw error
            }
        }
        
        if shouldThrowError { throw errorToThrow }
        
        guard let childKind = parent.kind.childKind else {
            throw RepositoryError.invalidOperation("Parent cannot have children")
        }
        
        let child = MediaItem(title: title, kind: childKind, sortKey: sortKey, parent: parent)
        parent.addChild(child)
        items.append(child)
        return child
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        invocations = []
        items = []
        savedItems = []
        deletedItems = []
        shouldThrowError = false
        fetchAllResult = nil
        saveResult = nil
        addChildResult = nil
    }
    
    func addTestItem(_ item: MediaItem) {
        items.append(item)
    }
    
    func setFetchAllResult(_ result: Result<[MediaItem], Error>) {
        fetchAllResult = result
    }
    
    func setSaveResult(_ result: Result<Void, Error>) {
        saveResult = result
    }
    
    func setAddChildResult(_ result: Result<MediaItem, Error>) {
        addChildResult = result
    }
    
    func setShouldThrowError(_ shouldThrow: Bool) {
        shouldThrowError = shouldThrow
    }
    
    func setDeleteResult(_ result: Result<Void, Error>) {
        if case .failure(let error) = result {
            shouldThrowError = true
            errorToThrow = error
        } else {
            shouldThrowError = false
        }
    }
}

