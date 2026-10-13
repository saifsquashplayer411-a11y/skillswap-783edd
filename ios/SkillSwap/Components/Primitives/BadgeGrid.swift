// 10x primitive: duolingo/badge-grid v2
import SwiftUI

@available(iOS 17.0, *)
struct BadgeGridItem: Identifiable {
    enum State: Equatable {
        case locked
        /// Earned at a tier (1-based); higher tiers render the tier number.
        case earned(tier: Int)
        /// Just earned: renders like earned plus a one-shot shine sweep.
        case newlyEarned(tier: Int)
    }
    let id: String
    var title: String
    var glyph: Image = Image(systemName: "rosette")
    var tint: Color = PlayfulTokens.warning
    var state: State = .locked
}

@available(iOS 17.0, *)
struct BadgeGridConfig {
    var lockedFill: Color = PlayfulTokens.track
    var lockedGlyphTint: Color = Color(.systemGray2)
    var titleFont: Font = PlayfulTokens.captionFont
    var tierFont: Font = .system(.caption2, design: .rounded, weight: .heavy)
    var columns: Int = 3
    var badgeSize: CGFloat = 84
}

/// Tiered achievement grid for any milestone system: rounded badges in
/// locked/earned states with a tier pip, desaturated locked badges, and a
/// diagonal shine sweep across newly earned badges.
@available(iOS 17.0, *)
struct BadgeGrid: View {
    var badges: [BadgeGridItem]
    var config: BadgeGridConfig = BadgeGridConfig()
    var onBadgeTap: (BadgeGridItem) -> Void = { _ in }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 14),
                            count: max(config.columns, 1))
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(badges) { badge in
                badgeCell(badge)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func badgeCell(_ badge: BadgeGridItem) -> some View {
        let earnedTier = tier(of: badge)
        let isNew = isNewlyEarned(badge)
        return Button {
            onBadgeTap(badge)
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: config.badgeSize * 0.3, style: .continuous)
                        .fill(earnedTier != nil ? badge.tint : config.lockedFill)
                        .frame(width: config.badgeSize, height: config.badgeSize)
                    badge.glyph
                        .font(.system(size: config.badgeSize * 0.4, weight: .bold))
                        .foregroundStyle(earnedTier != nil ? .white : config.lockedGlyphTint)
                    if let earnedTier, earnedTier > 1 {
                        Text("\(earnedTier)")
                            .font(config.tierFont)
                            .foregroundStyle(badge.tint)
                            .padding(6)
                            .background(.background, in: Circle())
                            .overlay(Circle().strokeBorder(badge.tint, lineWidth: 2))
                            .offset(x: config.badgeSize * 0.34, y: config.badgeSize * 0.34)
                    }
                }
                .overlay {
                    if isNew {
                        ShineSweep()
                            .clipShape(RoundedRectangle(cornerRadius: config.badgeSize * 0.3,
                                                        style: .continuous))
                    }
                }
                .saturation(earnedTier != nil ? 1 : 0)
                Text(badge.title)
                    .font(config.titleFont)
                    .foregroundStyle(earnedTier != nil ? .primary : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(badge.title)
        .accessibilityValue(earnedTier.map { "Earned, tier \($0)" } ?? "Locked")
    }

    private func tier(of badge: BadgeGridItem) -> Int? {
        switch badge.state {
        case .locked: nil
        case .earned(let tier), .newlyEarned(let tier): tier
        }
    }

    private func isNewlyEarned(_ badge: BadgeGridItem) -> Bool {
        if case .newlyEarned = badge.state { return true }
        return false
    }
}

/// One-shot diagonal light band sweeping across a newly earned badge.
@available(iOS 17.0, *)
fileprivate struct ShineSweep: View {
    @State private var phase: CGFloat = -1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(.white.opacity(0.55))
                .frame(width: proxy.size.width * 0.35)
                .rotationEffect(.degrees(22))
                .blur(radius: 4)
                .offset(x: phase * proxy.size.width * 1.6)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).delay(0.3)) { phase = 1 }
        }
    }
}

#Preview("Badges") {
    BadgeGrid(badges: [
        BadgeGridItem(id: "a", title: "Scholar", glyph: Image(systemName: "book.fill"),
                      tint: PlayfulTokens.accent, state: .earned(tier: 3)),
        BadgeGridItem(id: "b", title: "Sharpshooter", glyph: Image(systemName: "target"),
                      tint: PlayfulTokens.negative, state: .newlyEarned(tier: 1)),
        BadgeGridItem(id: "c", title: "Night Owl", glyph: Image(systemName: "moon.fill"),
                      tint: PlayfulTokens.accentSecondary, state: .earned(tier: 1)),
        BadgeGridItem(id: "d", title: "Champion", state: .locked),
        BadgeGridItem(id: "e", title: "Wildfire", glyph: Image(systemName: "flame.fill"),
                      tint: PlayfulTokens.warning, state: .locked),
    ])
    .padding(20)
}
