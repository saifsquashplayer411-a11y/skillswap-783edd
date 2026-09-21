// 10x primitive: duolingo/design-tokens v2
import SwiftUI

/// Central design tokens for the Electric Swap playful dimensional language.
/// Primary: #1CB0F6 (Electric Blue)
/// Accent / Gold: #FFC800 (Electric Gold)
/// Surface: #F5F8FA (Soft Cool Slate)
/// Text / Ink: #14213D (Deep Navy Ink)
@available(iOS 17.0, *)
enum PlayfulTokens {
    // MARK: Grounds & surfaces
    /// Screen background - Electric Swap pure canvas
    static let ground: Color = Color(red: 0.98, green: 0.99, blue: 1.00)
    /// Card surface - Crisp white cards
    static let surface: Color = Color.white
    /// Raised list-card fill - Electric Swap soft surface #F5F8FA
    static let surfaceRaised: Color = Color(red: 0.96, green: 0.97, blue: 0.98)

    // MARK: Ink
    /// Primary text - Deep Navy Ink #14213D
    static let ink: Color = Color(red: 0.08, green: 0.13, blue: 0.24)
    /// Secondary text - Cool Navy Muted
    static let inkSecondary: Color = Color(red: 0.42, green: 0.48, blue: 0.58)
    /// Text and glyphs on saturated accent fills.
    static let inkOnAccent: Color = Color.white
    /// Inactive/zero-state tint (empty streak, locked chest).
    static let inkDisabled: Color = Color(red: 0.75, green: 0.80, blue: 0.86)

    // MARK: Accent & semantics
    /// Signature action Electric Blue #1CB0F6: CTAs, primary actions, highlights
    static let accent: Color = Color(red: 0.11, green: 0.69, blue: 0.96)
    /// Pale electric blue fill ~#E2F5FE (selected state backgrounds, chips)
    static let accentSoft: Color = Color(red: 0.89, green: 0.96, blue: 1.00)
    /// Secondary blue tone
    static let accentSecondary: Color = Color(red: 0.08, green: 0.56, blue: 0.80)
    static let accentSecondarySoft: Color = Color(red: 0.92, green: 0.97, blue: 1.00)
    static let accentSecondaryLight: Color = Color(red: 0.52, green: 0.85, blue: 1.00)
    static let accentSecondaryDeep: Color = Color(red: 0.06, green: 0.42, blue: 0.62)

    /// Reward Gold #FFC800 (streaks, badges, credits, rewards)
    static let gold: Color = Color(red: 1.00, green: 0.78, blue: 0.00)
    static let goldSoft: Color = Color(red: 1.00, green: 0.96, blue: 0.82)
    static let goldDeep: Color = Color(red: 0.85, green: 0.62, blue: 0.00)

    /// Success / correct green
    static let positive: Color = Color(red: 0.31, green: 0.78, blue: 0.47)
    /// Error red
    static let negative: Color = Color(red: 1.00, green: 0.32, blue: 0.32)
    static let negativeDeep: Color = Color(red: 0.88, green: 0.18, blue: 0.18)
    static let negativeSoft: Color = Color(red: 1.00, green: 0.90, blue: 0.90)
    /// Streak / Energy Orange
    static let warning: Color = Color(red: 1.00, green: 0.55, blue: 0.00)
    /// Playful Purple Accent
    static let purple: Color = Color(red: 0.58, green: 0.37, blue: 0.95)

    /// Electric gradient
    static let premiumGradient: [Color] = [
        Color(red: 0.11, green: 0.69, blue: 0.96),
        Color(red: 0.00, green: 0.50, blue: 0.85),
    ]
    static let premiumPurple: Color = Color(red: 0.58, green: 0.37, blue: 0.95)

    /// Hairline borders
    static let border: Color = Color(red: 0.88, green: 0.91, blue: 0.94)
    /// Progress tracks and slot fills
    static let track: Color = Color(red: 0.90, green: 0.93, blue: 0.96)

    // MARK: Radii
    static let radiusCard: CGFloat = 18
    static let radiusControl: CGFloat = 14
    static let radiusSheet: CGFloat = 28
    /// Signature depth rim: press travel on buttons (4pt)
    static let rimHeight: CGFloat = 4

    // MARK: Type
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static let titleFont: Font = .system(.title2, design: .rounded, weight: .heavy)
    static let headlineFont: Font = .system(.headline, design: .rounded, weight: .heavy)
    static let bodyFont: Font = .system(.body, design: .rounded, weight: .semibold)
    static let captionFont: Font = .system(.caption, design: .rounded, weight: .bold)
    static let buttonFont: Font = .system(.body, design: .rounded, weight: .bold)
}
