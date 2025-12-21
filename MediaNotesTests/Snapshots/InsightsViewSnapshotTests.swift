import XCTest
import SwiftUI
import SnapshotTesting
import FoundationModels
@testable import MediaNotes

@MainActor
final class InsightsViewSnapshotTests: XCTestCase {
    
    // Fixed date for consistent snapshots (Nov 15, 2023 at 2:00 PM)
    private let fixedDate = Date(timeIntervalSince1970: 1700064000)
    
    override func setUp() {
        super.setUp()
        // Initialize DependencyProvider with fixed time provider
        let timeProvider = FixedTimeProvider(now: fixedDate)
        let mockContainer = MockDependencyContainer(timeProvider: timeProvider)
        DependencyProvider.shared.initialize(container: mockContainer)
    }
    
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }
    
    // MARK: - Empty State
    
    func testInsightsView_EmptyState() {
        let viewModel = MockInsightsViewModel(viewState: .empty, modelAvailability: .available)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Loading State
    
    func testInsightsView_LoadingState() {
        let viewModel = MockInsightsViewModel.loading()
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Ready State with Insights
    
    func testInsightsView_ReadyState_WithInsights() {
        let insights = Insights(
            summary: "You tend to prefer action-packed content, especially when it comes to books and movies. Your notes reveal a strong interest in science fiction and dystopian themes.",
            rationale: "You added numerous notes about sci-fi movies like 'The Matrix' and 'Inception', and dystopian books such as '1984'. Your commentary frequently mentions themes of reality, control, and philosophical questions about consciousness.",
            recommendations: "Based on your interests, you might enjoy 'Blade Runner 2049', 'Dune' by Frank Herbert, 'The Expanse' series, or 'Arrival'. For books, consider 'Neuromancer' by William Gibson or 'Snow Crash' by Neal Stephenson."
        )
        let viewModel = MockInsightsViewModel.ready(with: insights)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_ReadyState_ShortInsights() {
        let insights = Insights(
            summary: "You enjoy diverse media types.",
            rationale: "Your notes span across different genres and formats.",
            recommendations: "Try exploring 'Everything Everywhere All at Once' or 'Station Eleven'."
        )
        let viewModel = MockInsightsViewModel.ready(with: insights)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_ReadyState_LongInsights() {
        let insights = Insights(
            summary: "You have a deep appreciation for thought-provoking narratives that challenge conventional thinking and explore complex philosophical questions. Your preferences lean heavily toward content that examines the nature of reality, consciousness, and social structures.",
            rationale: "Your extensive collection of notes demonstrates a pattern of engagement with media that questions the status quo. From science fiction that explores alternative realities to dystopian literature that critiques societal norms, your annotations consistently highlight moments where characters or narratives challenge assumptions. You show particular interest in works that blend entertainment with intellectual depth, often noting scenes or passages that provoke reflection on consciousness, free will, and the nature of truth. Your commentary reveals someone who values media that doesn't just entertain, but also stimulates critical thinking about fundamental aspects of human existence.",
            recommendations: "Given your intellectual curiosity and philosophical interests, you would likely appreciate 'Solaris' by Stanisław Lem, 'The Left Hand of Darkness' by Ursula K. Le Guin, or 'Blindsight' by Peter Watts. For films, consider 'Arrival', 'Primer', or 'Stalker' by Andrei Tarkovsky. TV series like 'Dark', 'Westworld' (Season 1), and 'Severance' align well with your interest in consciousness and reality. For non-fiction, 'Gödel, Escher, Bach' by Douglas Hofstadter or 'The Structure of Scientific Revolutions' by Thomas Kuhn might resonate with your analytical approach to narrative."
        )
        let viewModel = MockInsightsViewModel.ready(with: insights)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Error State
    
    func testInsightsView_ErrorState() {
        let viewModel = MockInsightsViewModel.error("Failed to connect to language model. Please check your internet connection and try again.")
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_ErrorState_ShortMessage() {
        let viewModel = MockInsightsViewModel.error("Network unavailable")
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Unavailable States
    
    func testInsightsView_Unavailable_DeviceNotEligible() {
        let viewModel = MockInsightsViewModel.unavailable(reason: "Insights not supported on this device")
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_Unavailable_AppleIntelligenceNotEnabled() {
        let viewModel = MockInsightsViewModel.unavailable(reason: "Apple Intelligence not enabled")
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_Unavailable_ModelNotReady() {
        let viewModel = MockInsightsViewModel.unavailable(reason: "Model not ready")
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Different Device Sizes
    
    func testInsightsView_iPad_ReadyState() {
        let insights = Insights(
            summary: "You enjoy thought-provoking content that challenges your perspective.",
            rationale: "Your notes reflect deep engagement with philosophical themes across various media types.",
            recommendations: "Explore 'The Leftovers', 'Annihilation', or 'Recursion' by Blake Crouch."
        )
        let viewModel = MockInsightsViewModel.ready(with: insights)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 768, height: 1024)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_SmallPhone_ReadyState() {
        let insights = Insights(
            summary: "You prefer action-packed content.",
            rationale: "Most of your notes are about high-energy movies and thrilling books.",
            recommendations: "Check out 'Mad Max: Fury Road', 'John Wick' series, or 'Old Man's War' by John Scalzi."
        )
        let viewModel = MockInsightsViewModel.ready(with: insights)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 320, height: 568)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Dark Mode
    
    func testInsightsView_DarkMode_ReadyState() {
        let insights = Insights(
            summary: "You have diverse tastes in media.",
            rationale: "Your notes cover a wide range of genres and formats.",
            recommendations: "Try 'The Good Place', 'Parasite', or 'Cloud Atlas' for genre-blending experiences."
        )
        let viewModel = MockInsightsViewModel.ready(with: insights)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
            .environment(\.colorScheme, .dark)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_DarkMode_ErrorState() {
        let viewModel = MockInsightsViewModel.error("Failed to generate insights")
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
            .environment(\.colorScheme, .dark)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_DarkMode_Unavailable() {
        let viewModel = MockInsightsViewModel.unavailable(reason: "Insights not supported on this device")
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
            .environment(\.colorScheme, .dark)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Media-Specific Insights
    
    func testInsightsView_MediaSpecific_EmptyState() {
        let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries, subtitle: "Vince Gilligan")
        let viewModel = MockInsightsViewModel(viewState: .empty, modelAvailability: .available, mediaItem: mediaItem)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_MediaSpecific_ReadyState() {
        let mediaItem = MediaItem(title: "The Matrix", kind: .movie)
        let insights = Insights(
            summary: "You found The Matrix particularly thought-provoking, focusing on its philosophical themes and groundbreaking visual effects.",
            rationale: "Your notes consistently highlight the film's exploration of reality vs. simulation, with several references to the 'red pill/blue pill' metaphor. You also noted the innovative 'bullet time' cinematography and how it enhanced the storytelling. Your annotations suggest you appreciated both the action sequences and the deeper philosophical questions about consciousness and free will.",
            recommendations: "Based on your engagement with The Matrix, you might enjoy 'Inception' for similar reality-bending themes, 'Blade Runner 2049' for philosophical sci-fi, or 'Dark City' for another take on manufactured reality. Consider revisiting 'The Matrix' sequels with your newfound insights."
        )
        let viewModel = MockInsightsViewModel(viewState: .ready(insights), modelAvailability: .available, mediaItem: mediaItem)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_MediaSpecific_Book() {
        let mediaItem = MediaItem(title: "Dune", kind: .book, subtitle: "Frank Herbert")
        let insights = Insights(
            summary: "Your notes on Dune show deep appreciation for its world-building and political intrigue.",
            rationale: "You've highlighted numerous passages about the ecology of Arrakis and the Fremen culture. Your annotations frequently reference the themes of power, religion, and environmentalism. You seem particularly engaged with Paul's character development and the critique of messianic figures.",
            recommendations: "Given your thorough engagement with Dune, consider the rest of Frank Herbert's Dune series, particularly 'Dune Messiah' which deconstructs the hero myth. You might also enjoy 'The Left Hand of Darkness' by Ursula K. Le Guin or 'Hyperion' by Dan Simmons for similar epic scope and philosophical depth."
        )
        let viewModel = MockInsightsViewModel(viewState: .ready(insights), modelAvailability: .available, mediaItem: mediaItem)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_MediaSpecific_TVSeries() {
        let mediaItem = MediaItem(title: "The Expanse", kind: .tvSeries)
        let insights = Insights(
            summary: "You appreciate The Expanse's realistic take on space travel and complex political dynamics.",
            rationale: "Your notes across multiple episodes emphasize the show's attention to physics and the consequences of living in space. You've commented on the nuanced portrayal of different factions and how the series avoids simple good vs. evil narratives.",
            recommendations: "For similar hard sci-fi, try 'Battlestar Galactica' (2004 series), 'For All Mankind', or the book series 'The Expanse' is based on by James S.A. Corey. You might also enjoy 'Foundation' on Apple TV+ for similar epic scope."
        )
        let viewModel = MockInsightsViewModel(viewState: .ready(insights), modelAvailability: .available, mediaItem: mediaItem)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testInsightsView_MediaSpecific_DarkMode() {
        let mediaItem = MediaItem(title: "Interstellar", kind: .movie)
        let insights = Insights(
            summary: "You were deeply moved by Interstellar's emotional core alongside its scientific concepts.",
            rationale: "Your notes balance appreciation for the film's scientific accuracy with emotional responses to the father-daughter relationship. You've highlighted the time dilation scenes and their emotional impact.",
            recommendations: "Try 'Arrival' for similar emotional sci-fi, 'Contact' for another hard sci-fi film with heart, or 'The Martian' for science-grounded optimism."
        )
        let viewModel = MockInsightsViewModel(viewState: .ready(insights), modelAvailability: .available, mediaItem: mediaItem)
        let view = InsightsView(viewModel: viewModel)
            .frame(width: 375, height: 812)
            .environment(\.colorScheme, .dark)
        
        assertSnapshot(of: view, as: .image)
    }
}

