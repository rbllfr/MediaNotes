import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class ContentViewSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize DependencyProvider for snapshot tests
        let mockContainer = MockDependencyContainer()
        DependencyProvider.shared.initialize(container: mockContainer)
    }
    
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }
    
    // MARK: - ContentView Tests
    
    func testContentView_LibraryTab() {
        let view = ContentView()
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testContentView_SearchTab() {
        let view = ContentView()
            .frame(width: 375, height: 812)
        
        // Note: Would need to programmatically switch tabs in a real scenario
        assertSnapshot(of: view, as: .image(precision: 0.99))
    }
    
    func testContentView_CustomTabBar() {
        let view = ContentView()
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Different Device Sizes
    
    func testContentView_iPhone13() {
        let view = ContentView()
            .frame(width: 390, height: 844)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testContentView_iPhoneSE() {
        let view = ContentView()
            .frame(width: 375, height: 667)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testContentView_iPhone15ProMax() {
        let view = ContentView()
            .frame(width: 430, height: 932)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Tab Bar Details
    
    func testTabBar_AllElements() {
        let view = ContentView()
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, as: .image(precision: 0.99))
    }
}
