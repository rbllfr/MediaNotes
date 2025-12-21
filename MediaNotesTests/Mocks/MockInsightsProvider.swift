import Foundation
import FoundationModels
@testable import MediaNotes

@MainActor
final class MockInsightsProvider: InsightsProviding {
    
    // MARK: - Invocation Tracking
    
    enum Invocation: Equatable {
        case getAvailability
        case generateInsights
        case generateInsightsForMedia(mediaItem: MediaItem)
        
        static func == (lhs: Invocation, rhs: Invocation) -> Bool {
            switch (lhs, rhs) {
            case (.getAvailability, .getAvailability),
                 (.generateInsights, .generateInsights):
                return true
            case let (.generateInsightsForMedia(lMedia), .generateInsightsForMedia(rMedia)):
                return lMedia.id == rMedia.id
            default:
                return false
            }
        }
    }
    
    private(set) var invocations: [Invocation] = []
    
    // MARK: - Configuration
    
    var mockAvailability: SystemLanguageModel.Availability = .available
    var mockInsights: Insights?
    var mockError: Error?
    
    // MARK: - InsightsProviding
    
    var availability: SystemLanguageModel.Availability {
        get async {
            invocations.append(.getAvailability)
            return mockAvailability
        }
    }
    
    func generateInsights() async throws -> Insights {
        invocations.append(.generateInsights)
        
        if let error = mockError {
            throw error
        }
        
        if let insights = mockInsights {
            return insights
        }
        
        // Default to example insights
        return .example
    }
    
    func generateInsights(for mediaItem: MediaItem) async throws -> Insights {
        invocations.append(.generateInsightsForMedia(mediaItem: mediaItem))
        
        if let error = mockError {
            throw error
        }
        
        if let insights = mockInsights {
            return insights
        }
        
        // Default to example insights
        return .example
    }
    
    // MARK: - Test Helpers
    
    /// Reset the mock to initial state
    func reset() {
        invocations = []
        mockAvailability = .available
        mockInsights = nil
        mockError = nil
    }
    
    /// Configure mock to return specific insights
    func setMockInsights(_ insights: Insights) {
        mockInsights = insights
        mockError = nil
    }
    
    /// Configure mock to throw an error
    func setMockError(_ error: Error) {
        mockError = error
        mockInsights = nil
    }
    
    /// Configure mock availability
    func setMockAvailability(_ availability: SystemLanguageModel.Availability) {
        mockAvailability = availability
    }
    
    // MARK: - Convenience Factory Methods
    
    /// Create a mock that returns successful insights
    static func withInsights(_ insights: Insights = .example) -> MockInsightsProvider {
        let mock = MockInsightsProvider()
        mock.setMockInsights(insights)
        return mock
    }
    
    /// Create a mock that throws an error
    static func withError(_ error: Error) -> MockInsightsProvider {
        let mock = MockInsightsProvider()
        mock.setMockError(error)
        return mock
    }
}

// MARK: - Test Error

enum MockInsightsError: LocalizedError {
    case failedToGenerate
    case networkUnavailable
    case modelTimeout
    
    var errorDescription: String? {
        switch self {
        case .failedToGenerate:
            return "Failed to generate insights"
        case .networkUnavailable:
            return "Network unavailable"
        case .modelTimeout:
            return "Model request timed out"
        }
    }
}

