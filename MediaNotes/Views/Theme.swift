import SwiftUI

/// App-wide theme configuration
/// Clean, light aesthetic matching iOS system apps
enum Theme {
    
    // MARK: - Colors
    
    /// Primary background - very light
    static let background = Color(.systemBackground)
    
    /// Secondary background - grouped background
    static let secondaryBackground = Color(.secondarySystemBackground)
    
    /// Card/elevated surface
    static let cardBackground = Color(.systemGroupedBackground)
    
    /// Subtle border color
    static let border = Color(.separator)
    
    /// Primary text - system primary
    static let textPrimary = Color.primary
    
    /// Secondary text - system secondary
    static let textSecondary = Color.secondary
    
    /// Tertiary text - system tertiary
    static let textTertiary = Color(.tertiaryLabel)
    
    /// Primary accent - system accent
    static let accent = Color.accentColor
    
    /// Secondary accent - very light gray
    static let accentSecondary = Color(.systemGray5)
    
    /// Tertiary accent - light gray
    static let accentTertiary = Color(.systemGray4)
    
    /// Error color - system red
    static let error = Color.red
    
    // MARK: - Media Type Colors
    
    static let movieColor = Color(red: 0.93, green: 0.42, blue: 0.38)
    static let tvColor = Color(red: 0.45, green: 0.58, blue: 0.95)
    static let bookColor = Color(red: 0.95, green: 0.76, blue: 0.42)
    static let musicColor = Color(red: 0.72, green: 0.45, blue: 0.88)
    static let eventColor = Color(red: 0.38, green: 0.72, blue: 0.68)
    
    static func color(for kind: MediaKind) -> Color {
        switch kind {
        case .movie: return movieColor
        case .tvSeries, .episode: return tvColor
        case .book, .chapter: return bookColor
        case .album, .track: return musicColor
        case .liveEvent, .performance: return eventColor
        case .other: return accent
        }
    }
    
    // MARK: - Typography
    
    /// Display font for large titles - system serif
    static func displayFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    
    /// Heading font
    static func headingFont(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    /// Body font
    static func bodyFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    /// Monospace font for metadata
    static func monoFont(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    // MARK: - Spacing
    
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    
    // MARK: - Corner Radius
    
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 24
    
}

// MARK: - View Extensions

extension View {
    /// Apply themed card styling
    func themedCard() -> some View {
        self
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .stroke(Theme.border, lineWidth: 0.5)
            )
    }
    
    /// Apply themed list row styling
    func themedRow() -> some View {
        self
            .listRowBackground(Theme.cardBackground)
            .listRowSeparatorTint(Theme.border)
    }
    
    /// Apply theme background
    func themedBackground() -> some View {
        self
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    /// Glow effect for accent elements
    func accentGlow(color: Color = Theme.accent, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color.opacity(0.2), radius: radius)
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.headingFont(size: 16))
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingMD)
            .background {
                if isDisabled {
                    Color(.systemGray4)
                } else {
                    Theme.accent
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.headingFont(size: 16))
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingMD)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.bodyFont(size: 16))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
            .background(configuration.isPressed ? Color(.systemGray6) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
