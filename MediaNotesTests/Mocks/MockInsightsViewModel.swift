import Foundation
import FoundationModels
@testable import MediaNotes

@MainActor
@Observable
final class MockInsightsViewModel: InsightsViewModelProtocol {
    var viewState: ViewState<Insights>
    var modelAvailability: SystemLanguageModel.Availability?
    var navigationTitle: String
    var emptyStateMessage: String
    
    var isModelAvailable: Bool {
        if case .available = modelAvailability {
            return true
        }
        return false
    }
    
    var unavailabilityReason: String? {
        guard let availability = modelAvailability else { return nil }
        
        switch availability {
        case .available:
            return nil
        case .unavailable(.deviceNotEligible):
            return "Insights not supported on this device"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Apple Intelligence not enabled"
        case .unavailable(.modelNotReady):
            return "Model not ready"
        case .unavailable:
            return "Model unavailable"
        }
    }
    
    /// Create a mock with a specific state - perfect for snapshot testing
    init(
        viewState: ViewState<Insights> = .empty,
        modelAvailability: SystemLanguageModel.Availability? = .available,
        navigationTitle: String = "Insights",
        emptyStateMessage: String = "Analyze your notes to discover patterns and preferences in your media consumption."
    ) {
        self.viewState = viewState
        self.modelAvailability = modelAvailability
        self.navigationTitle = navigationTitle
        self.emptyStateMessage = emptyStateMessage
    }
    
    /// Convenience: create mock in ready state with insights
    static func ready(with insights: Insights = .example) -> MockInsightsViewModel {
        MockInsightsViewModel(viewState: .ready(insights), modelAvailability: .available)
    }
    
    /// Convenience: create mock in loading state
    static func loading() -> MockInsightsViewModel {
        MockInsightsViewModel(viewState: .loading, modelAvailability: .available)
    }
    
    /// Convenience: create mock in error state
    static func error(_ message: String) -> MockInsightsViewModel {
        MockInsightsViewModel(viewState: .error(message), modelAvailability: .available)
    }
    
    /// Convenience: create mock in unavailable state
    static func unavailable(reason: String) -> MockInsightsViewModel {
        let availability: SystemLanguageModel.Availability
        
        if reason.contains("not supported") {
            availability = .unavailable(.deviceNotEligible)
        } else if reason.contains("not enabled") {
            availability = .unavailable(.appleIntelligenceNotEnabled)
        } else if reason.contains("not ready") {
            availability = .unavailable(.modelNotReady)
        } else {
            availability = .unavailable(.modelNotReady)
        }
        
        return MockInsightsViewModel(viewState: .empty, modelAvailability: availability)
    }
    
    func initialize() async {
        // No-op for mock - state is pre-set
    }
    
    func generateInsights() async {
        // No-op for mock - state is pre-set
    }
}

