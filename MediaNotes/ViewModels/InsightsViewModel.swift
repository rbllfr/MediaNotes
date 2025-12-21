import Foundation
import FoundationModels

// MARK: - Protocol

@MainActor
protocol InsightsViewModelProtocol: AnyObject, Observable {
    /// Current state of insights loading and display
    var viewState: ViewState<Insights> { get }
    
    /// Current availability of the language model
    var modelAvailability: SystemLanguageModel.Availability? { get }
    
    /// Whether the language model is available for generating insights
    var isModelAvailable: Bool { get }
    
    /// Human-readable reason why insights are unavailable, or nil if available
    var unavailabilityReason: String? { get }
    
    /// Navigation title for the insights view
    var navigationTitle: String { get }
    
    /// Message to display in the empty state
    var emptyStateMessage: String { get }
    
    /// Initializes the view model and checks model availability
    func initialize() async
    
    /// Generates insights from user notes
    func generateInsights() async
}

// MARK: - Implementation

@MainActor
@Observable
final class InsightsViewModel: InsightsViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let insightsProvider: any InsightsProviding
    
    // MARK: - State
    
    private(set) var viewState: ViewState<Insights> = .empty
    private(set) var modelAvailability: SystemLanguageModel.Availability?
    
    /// Private reference to media item for generating insights
    private let mediaItem: MediaItem?
    
    // MARK: - Computed Properties
    
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
    
    var navigationTitle: String {
        if let title = mediaItem?.title {
            return "Insights for \(title)"
        }
        return "Insights"
    }
    
    var emptyStateMessage: String {
        if let title = mediaItem?.title {
            return "Analyze your notes for \(title) to discover patterns and themes in your experience."
        }
        return "Analyze your notes to discover patterns and preferences in your media consumption."
    }
    
    // MARK: - Initialization
    
    init(insightsProvider: any InsightsProviding, mediaItem: MediaItem? = nil) {
        self.insightsProvider = insightsProvider
        self.mediaItem = mediaItem
    }
    
    // MARK: - Actions
    
    func initialize() async {
        guard viewState.isEmpty else { return }
        
        // Check model availability
        modelAvailability = await insightsProvider.availability
    }
    
    func generateInsights() async {
        viewState = .loading
        
        do {
            let insights: Insights
            if let mediaItem = mediaItem {
                insights = try await insightsProvider.generateInsights(for: mediaItem)
            } else {
                insights = try await insightsProvider.generateInsights()
            }
            viewState = .ready(insights)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}

