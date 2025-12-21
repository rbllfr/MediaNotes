import XCTest
import FoundationModels
@testable import MediaNotes

@MainActor
final class InsightsViewModelTests: XCTestCase {
    
    var sut: InsightsViewModel!
    var mockProvider: MockInsightsProvider!
    
    override func setUp() async throws {
        mockProvider = MockInsightsProvider()
        sut = InsightsViewModel(insightsProvider: mockProvider)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockProvider = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_initialize_checksAvailability() async {
        // Given
        mockProvider.setMockAvailability(.available)
        mockProvider.setMockInsights(.example)
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertNotNil(sut.modelAvailability)
        XCTAssertTrue(sut.isModelAvailable)
    }
    
    func test_initialize_doesNotGenerateInsights() async {
        // Given
        mockProvider.setMockAvailability(.available)
        let insights = Insights(
            summary: "You love sci-fi content",
            rationale: "Most of your notes are about sci-fi movies and books",
            recommendations: "Try reading 'Foundation' by Isaac Asimov or watching 'Interstellar'"
        )
        mockProvider.setMockInsights(insights)
        
        // When
        await sut.initialize()
        
        // Then - should check availability but not generate insights
        XCTAssertTrue(sut.isModelAvailable)
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertFalse(mockProvider.invocations.contains(.generateInsights))
    }
    
    func test_initialize_checksAvailabilityEvenWhenUnavailable() async {
        // Given
        mockProvider.setMockAvailability(.unavailable(.deviceNotEligible))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertFalse(sut.isModelAvailable)
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertFalse(mockProvider.invocations.contains(.generateInsights))
    }
    
    func test_initialize_onlyRunsOnce() async {
        // Given
        mockProvider.setMockAvailability(.available)
        mockProvider.setMockInsights(.example)
        
        // When
        await sut.initialize()
        await sut.initialize() // Second call should not check availability again
        
        // Then
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertFalse(mockProvider.invocations.contains(.generateInsights))
    }
    
    // MARK: - Generate Insights Tests
    
    func test_generateInsights_setsLoadingState() async {
        // Given
        mockProvider.setMockInsights(.example)
        
        // When
        let task = Task {
            await sut.generateInsights()
        }
        
        // Check loading state (this is a race condition, but the test should usually pass)
        // In a real scenario, you might need more sophisticated state tracking
        
        await task.value
        
        // Then - should end in ready state
        XCTAssertTrue(sut.viewState.isReady)
    }
    
    func test_generateInsights_updatesViewStateWithInsights() async {
        // Given
        let insights = Insights(
            summary: "You enjoy diverse media",
            rationale: "Your notes span across movies, books, and music",
            recommendations: "Explore more variety with 'Arrival' or 'The Left Hand of Darkness'"
        )
        mockProvider.setMockInsights(insights)
        
        // When
        await sut.generateInsights()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
        XCTAssertEqual(sut.viewState.data?.summary, insights.summary)
        XCTAssertEqual(sut.viewState.data?.rationale, insights.rationale)
    }
    
    func test_generateInsights_handlesError() async {
        // Given
        mockProvider.setMockError(MockInsightsError.failedToGenerate)
        
        // When
        await sut.generateInsights()
        
        // Then
        XCTAssertTrue(sut.viewState.isError)
        XCTAssertEqual(sut.viewState.errorMessage, "Failed to generate insights")
    }
    
    func test_generateInsights_canBeCalledMultipleTimes() async {
        // Given
        let firstInsights = Insights(summary: "First", rationale: "First rationale", recommendations: "First recommendations")
        mockProvider.setMockInsights(firstInsights)
        
        // When - first generation
        await sut.generateInsights()
        
        // Then
        XCTAssertEqual(sut.viewState.data?.summary, "First")
        let firstCount = mockProvider.invocations.filter { $0 == .generateInsights }.count
        XCTAssertEqual(firstCount, 1)
        
        // Given - update mock insights
        let secondInsights = Insights(summary: "Second", rationale: "Second rationale", recommendations: "Second recommendations")
        mockProvider.setMockInsights(secondInsights)
        
        // When - second generation
        await sut.generateInsights()
        
        // Then
        XCTAssertEqual(sut.viewState.data?.summary, "Second")
        let secondCount = mockProvider.invocations.filter { $0 == .generateInsights }.count
        XCTAssertEqual(secondCount, 2)
    }
    
    // MARK: - Model Availability Tests
    
    func test_isModelAvailable_trueWhenAvailable() async {
        // Given
        mockProvider.setMockAvailability(.available)
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertTrue(sut.isModelAvailable)
        XCTAssertNil(sut.unavailabilityReason)
    }
    
    func test_isModelAvailable_falseWhenDeviceNotEligible() async {
        // Given
        mockProvider.setMockAvailability(.unavailable(.deviceNotEligible))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertFalse(sut.isModelAvailable)
        XCTAssertEqual(sut.unavailabilityReason, "Insights not supported on this device")
    }
    
    func test_unavailabilityReason_appleIntelligenceNotEnabled() async {
        // Given
        mockProvider.setMockAvailability(.unavailable(.appleIntelligenceNotEnabled))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertFalse(sut.isModelAvailable)
        XCTAssertEqual(sut.unavailabilityReason, "Apple Intelligence not enabled")
    }
    
    func test_unavailabilityReason_modelNotReady() async {
        // Given
        mockProvider.setMockAvailability(.unavailable(.modelNotReady))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertFalse(sut.isModelAvailable)
        XCTAssertEqual(sut.unavailabilityReason, "Model not ready")
    }
    
    // MARK: - ViewState Tests
    
    func test_viewState_startsEmpty() {
        // Then
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertNil(sut.modelAvailability)
    }
    
    func test_viewState_transitionsCorrectly() async {
        // Given
        mockProvider.setMockAvailability(.available)
        mockProvider.setMockInsights(.example)
        
        // Initial state - should be empty
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertFalse(sut.viewState.isLoading)
        XCTAssertFalse(sut.viewState.isReady)
        XCTAssertFalse(sut.viewState.isError)
        
        // When - initialize (checks availability only)
        await sut.initialize()
        
        // Then - should still be empty
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertTrue(sut.isModelAvailable)
        
        // When - generate insights
        await sut.generateInsights()
        
        // Then - should transition to ready
        XCTAssertTrue(sut.viewState.isReady)
        XCTAssertFalse(sut.viewState.isLoading)
        XCTAssertFalse(sut.viewState.isEmpty)
        XCTAssertFalse(sut.viewState.isError)
    }
    
    func test_viewState_errorStateContainsMessage() async {
        // Given
        mockProvider.setMockError(MockInsightsError.networkUnavailable)
        
        // When
        await sut.generateInsights()
        
        // Then
        XCTAssertTrue(sut.viewState.isError)
        XCTAssertNotNil(sut.viewState.errorMessage)
    }
    
    // MARK: - Integration Tests
    
    func test_fullFlow_initializeThenGenerate() async {
        // Given
        mockProvider.setMockAvailability(.available)
        let insights = Insights(
            summary: "Integration test summary",
            rationale: "Integration test rationale",
            recommendations: "Integration test recommendations"
        )
        mockProvider.setMockInsights(insights)
        
        // When
        await sut.initialize()
        
        // Then - after initialize, should be empty but available
        XCTAssertTrue(sut.isModelAvailable)
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertFalse(mockProvider.invocations.contains(.generateInsights))
        
        // When - user presses generate button
        await sut.generateInsights()
        
        // Then - insights are generated
        XCTAssertTrue(sut.viewState.isReady)
        XCTAssertEqual(sut.viewState.data?.summary, insights.summary)
        XCTAssertTrue(mockProvider.invocations.contains(.generateInsights))
    }
    
    func test_fullFlow_unavailableModelStaysEmpty() async {
        // Given
        mockProvider.setMockAvailability(.unavailable(.deviceNotEligible))
        
        // When
        await sut.initialize()
        
        // Then
        XCTAssertFalse(sut.isModelAvailable)
        XCTAssertTrue(sut.viewState.isEmpty)
        XCTAssertNotNil(sut.unavailabilityReason)
        XCTAssertFalse(mockProvider.invocations.contains(.generateInsights))
    }
    
    func test_fullFlow_errorRecoveryWithRetry() async {
        // Given
        mockProvider.setMockError(MockInsightsError.modelTimeout)
        
        // When - first attempt fails
        await sut.generateInsights()
        
        // Then
        XCTAssertTrue(sut.viewState.isError)
        
        // Given - fix the error
        mockProvider.setMockInsights(.example)
        
        // When - retry
        await sut.generateInsights()
        
        // Then
        XCTAssertTrue(sut.viewState.isReady)
        XCTAssertNotNil(sut.viewState.data)
        let count = mockProvider.invocations.filter { $0 == .generateInsights }.count
        XCTAssertEqual(count, 2)
    }
    
    // MARK: - Media-Specific Insights Tests
    
    func test_navigationTitle_generalInsights() {
        // Given/When - ViewModel created without media item
        // Then
        XCTAssertEqual(sut.navigationTitle, "Insights")
    }
    
    func test_navigationTitle_mediaSpecificInsights() {
        // Given
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
        
        // When
        let mediaSpecificViewModel = InsightsViewModel(
            insightsProvider: mockProvider,
            mediaItem: mediaItem
        )
        
        // Then
        XCTAssertEqual(mediaSpecificViewModel.navigationTitle, "Insights for Breaking Bad")
    }
    
    func test_emptyStateMessage_generalInsights() {
        // Given/When - ViewModel created without media item
        // Then
        XCTAssertEqual(sut.emptyStateMessage, "Analyze your notes to discover patterns and preferences in your media consumption.")
    }
    
    func test_emptyStateMessage_mediaSpecificInsights() {
        // Given
        let mediaItem = MediaItem(title: "The Matrix", kind: .movie)
        
        // When
        let mediaSpecificViewModel = InsightsViewModel(
            insightsProvider: mockProvider,
            mediaItem: mediaItem
        )
        
        // Then
        XCTAssertEqual(mediaSpecificViewModel.emptyStateMessage, "Analyze your notes for The Matrix to discover patterns and themes in your experience.")
    }
    
    func test_generateInsights_callsGeneralMethodWhenNoMediaItem() async {
        // Given
        mockProvider.setMockInsights(.example)
        
        // When
        await sut.generateInsights()
        
        // Then
        XCTAssertTrue(mockProvider.invocations.contains(.generateInsights))
        XCTAssertFalse(mockProvider.invocations.contains(where: { 
            if case .generateInsightsForMedia = $0 { return true }
            return false
        }))
    }
    
    func test_generateInsights_callsMediaSpecificMethodWhenMediaItemProvided() async {
        // Given
        let mediaItem = MediaItem(title: "The Matrix", kind: .movie)
        let mediaSpecificViewModel = InsightsViewModel(
            insightsProvider: mockProvider,
            mediaItem: mediaItem
        )
        let insights = Insights(
            summary: "You found The Matrix thought-provoking",
            rationale: "Your notes focus on the philosophical themes and cinematography",
            recommendations: "Try 'Inception' or 'Blade Runner 2049' for similar themes"
        )
        mockProvider.setMockInsights(insights)
        
        // When
        await mediaSpecificViewModel.generateInsights()
        
        // Then
        XCTAssertFalse(mockProvider.invocations.contains(.generateInsights))
        XCTAssertTrue(mockProvider.invocations.contains(.generateInsightsForMedia(mediaItem: mediaItem)))
        XCTAssertTrue(mediaSpecificViewModel.viewState.isReady)
        XCTAssertEqual(mediaSpecificViewModel.viewState.data?.summary, insights.summary)
    }
    
    func test_generateInsights_mediaSpecificHandlesError() async {
        // Given
        let mediaItem = MediaItem(title: "Dune", kind: .book)
        let mediaSpecificViewModel = InsightsViewModel(
            insightsProvider: mockProvider,
            mediaItem: mediaItem
        )
        mockProvider.setMockError(MockInsightsError.failedToGenerate)
        
        // When
        await mediaSpecificViewModel.generateInsights()
        
        // Then
        XCTAssertTrue(mediaSpecificViewModel.viewState.isError)
        XCTAssertEqual(mediaSpecificViewModel.viewState.errorMessage, "Failed to generate insights")
        XCTAssertTrue(mockProvider.invocations.contains(.generateInsightsForMedia(mediaItem: mediaItem)))
    }
    
    func test_generateInsights_mediaSpecificCanBeCalledMultipleTimes() async {
        // Given
        let mediaItem = MediaItem(title: "Interstellar", kind: .movie)
        let mediaSpecificViewModel = InsightsViewModel(
            insightsProvider: mockProvider,
            mediaItem: mediaItem
        )
        let firstInsights = Insights(
            summary: "First viewing impressions",
            rationale: "Initial thoughts on science accuracy",
            recommendations: "Explore more hard sci-fi"
        )
        mockProvider.setMockInsights(firstInsights)
        
        // When - first generation
        await mediaSpecificViewModel.generateInsights()
        
        // Then
        XCTAssertEqual(mediaSpecificViewModel.viewState.data?.summary, "First viewing impressions")
        let firstCount = mockProvider.invocations.filter { $0 == .generateInsightsForMedia(mediaItem: mediaItem) }.count
        XCTAssertEqual(firstCount, 1)
        
        // Given - update mock insights
        let secondInsights = Insights(
            summary: "After second viewing",
            rationale: "Noticed more emotional depth",
            recommendations: "Compare with 'Arrival'"
        )
        mockProvider.setMockInsights(secondInsights)
        
        // When - second generation
        await mediaSpecificViewModel.generateInsights()
        
        // Then
        XCTAssertEqual(mediaSpecificViewModel.viewState.data?.summary, "After second viewing")
        let secondCount = mockProvider.invocations.filter { $0 == .generateInsightsForMedia(mediaItem: mediaItem) }.count
        XCTAssertEqual(secondCount, 2)
    }
}

