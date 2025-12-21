import XCTest
import SwiftUI
import SnapshotTesting
@testable import MediaNotes

@MainActor
final class ThemeSnapshotTests: XCTestCase {
    
    override func invokeTest() {
        withSnapshotTesting(record: .missing) {
            super.invokeTest()
        }
    }
    
    // MARK: - Color Palette Tests
    
    func testColorPalette_Dark() {
        let view = VStack(spacing: Theme.spacingMD) {
            colorSwatch("Background", color: Theme.background)
            colorSwatch("Secondary BG", color: Theme.secondaryBackground)
            colorSwatch("Card BG", color: Theme.cardBackground)
            colorSwatch("Text Primary", color: Theme.textPrimary)
            colorSwatch("Text Secondary", color: Theme.textSecondary)
            colorSwatch("Accent", color: Theme.accent)
        }
        .padding()
        .frame(width: 300)
        .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testMediaKindColors() {
        let view = VStack(spacing: Theme.spacingSM) {
            ForEach(MediaKind.allCases) { kind in
                HStack {
                    Image(systemName: kind.iconName)
                        .foregroundStyle(Theme.color(for: kind))
                    Text(kind.displayName)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
                .padding(Theme.spacingSM)
                .background(Theme.cardBackground)
            }
        }
        .padding()
        .frame(width: 300)
        .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Typography Tests
    
    func testTypography() {
        let view = VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Display Font")
                .font(Theme.displayFont(size: 28))
                .foregroundStyle(Theme.textPrimary)
            
            Text("Heading Font")
                .font(Theme.headingFont(size: 20))
                .foregroundStyle(Theme.textPrimary)
            
            Text("Body Font Regular")
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textPrimary)
            
            Text("Monospace Metadata")
                .font(Theme.monoFont(size: 14))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .frame(width: 300)
        .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Button Style Tests
    
    func testPrimaryButton() {
        let view = VStack(spacing: Theme.spacingMD) {
            Button("Primary Button") {}
                .buttonStyle(PrimaryButtonStyle())
            
            Button("Disabled") {}
                .buttonStyle(PrimaryButtonStyle(isDisabled: true))
        }
        .padding()
        .frame(width: 300)
        .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testSecondaryButton() {
        let view = Button("Secondary Button") {}
            .buttonStyle(SecondaryButtonStyle())
            .padding()
            .frame(width: 300)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    func testGhostButton() {
        let view = Button("Ghost Button") {}
            .buttonStyle(GhostButtonStyle())
            .padding()
            .frame(width: 300)
            .background(Theme.background)
        
        assertSnapshot(of: view, as: .image)
    }
    
    // MARK: - Helper Views
    
    private func colorSwatch(_ name: String, color: Color) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 40)
            
            Text(name)
                .font(Theme.bodyFont(size: 14))
                .foregroundStyle(Theme.textPrimary)
            
            Spacer()
        }
    }
}
