// 10x primitive: duolingo/points-counter v2
import SwiftUI

@available(iOS 17.0, *)
struct PointsCounterConfig {
    /// Points glyph slot; neutral gem symbol by default.
    var glyph: Image = Image(systemName: "diamond.fill")
    var glyphTint: Color = PlayfulTokens.accentSecondary
    var glyphSize: CGFloat = 18
    var countFont: Font = .system(.headline, design: .rounded, weight: .heavy)
    /// Count numeral color. `nil` (default) matches `glyphTint` — the
    /// reference HUD counters color their numbers like their glyphs.
    var countColor: Color? = nil
    /// Accessibility name for the point type (e.g. "Gems", "Coins", "Credits").
    var pointsName: String = "Points"
    var hapticsEnabled: Bool = true
}

/// Points/currency counter for any earnable balance: the number rolls up with
/// numeric-text steps while small particles fly into the glyph on gains. Pair
/// with `PointsSpendRow` for spend surfaces (shop lists, boosts, repairs).
@available(iOS 17.0, *)
struct PointsCounter: View {
    var amount: Int
    var config: PointsCounterConfig = PointsCounterConfig()

    @State private var shown = 0
    @State private var particleBurst = 0
    @State private var glyphPop = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 6) {
            config.glyph
                .font(.system(size: config.glyphSize, weight: .bold))
                .foregroundStyle(config.glyphTint)
                .scaleEffect(glyphPop ? 1.3 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: glyphPop)
                .overlay {
                    if particleBurst > 0, !reduceMotion {
                        FlyInParticles(tint: config.glyphTint, burst: particleBurst)
                    }
                }
            Text("\(shown)")
                .font(config.countFont)
                .foregroundStyle(config.countColor ?? config.glyphTint)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(shown)))
        }
        .onChange(of: amount, initial: true) { old, new in
            if reduceMotion || shown == 0 && old == new {
                shown = new
                return
            }
            if new > old { particleBurst += 1; popGlyph() }
            Task { await countUp(to: new) }
        }
        .sensoryFeedback(.increase, trigger: amount) { old, new in
            config.hapticsEnabled && new > old
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(config.pointsName)
        .accessibilityValue("\(amount)")
    }

    @MainActor
    private func countUp(to target: Int) async {
        let start = shown
        guard start != target else { return }
        let steps = min(14, max(4, abs(target - start)))
        for step in 1...steps {
            withAnimation(.linear(duration: 0.04)) {
                shown = start + (target - start) * step / steps
            }
            try? await Task.sleep(for: .milliseconds(45))
        }
    }

    private func popGlyph() {
        glyphPop = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            glyphPop = false
        }
    }
}

/// Six small glyph particles converging on the counter glyph, replayed on
/// each `burst` increment.
@available(iOS 17.0, *)
fileprivate struct FlyInParticles: View {
    var tint: Color
    var burst: Int
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                let angle = Double(index) * .pi / 3 + Double(burst)
                Circle()
                    .fill(tint)
                    .frame(width: 5, height: 5)
                    .offset(x: cos(angle) * 30 * (1 - progress),
                            y: sin(angle) * 30 * (1 - progress))
                    .opacity(1 - Double(progress) * 0.9)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onChange(of: burst, initial: true) { _, _ in
            progress = 0
            withAnimation(.easeIn(duration: 0.4)) { progress = 1 }
        }
    }
}

#Preview("Points counter") {
    struct Demo: View {
        @State private var amount = 500
        var body: some View {
            VStack(spacing: 24) {
                PointsCounter(amount: amount)
                PointsCounter(amount: 1250,
                              config: PointsCounterConfig(glyph: Image(systemName: "seal.fill"),
                                                          glyphTint: PlayfulTokens.warning,
                                                          pointsName: "Coins"))
                Button("+25") { amount += 25 }
            }
            .padding(24)
        }
    }
    return Demo()
}
