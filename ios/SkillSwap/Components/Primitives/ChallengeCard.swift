// 10x primitive: duolingo/challenge-card v2
import SwiftUI

@available(iOS 17.0, *)
enum ChallengeRewardState: Equatable {
    /// Progress not complete: chest sits dimmed.
    case locked
    /// Progress complete: chest wiggles, awaiting a tap.
    case ready
    /// Reward collected: chest opened with a burst, then rests.
    case opened
}

/// Partner in a shared challenge; setting one switches the card to its social
/// variant (absorbed friend-quest-card).
@available(iOS 17.0, *)
struct ChallengePartner {
    var name: String = "Friend"
    /// The partner's contribution toward the shared goal.
    var progress: Int
    /// Avatar slot; a neutral monogram circle when nil.
    var avatar: AnyView? = nil
}

@available(iOS 17.0, *)
struct ChallengeCardConfig {
    var cardFill: Color = PlayfulTokens.surfaceRaised
    var progressFill: Color = PlayfulTokens.warning
    var progressTrack: Color = PlayfulTokens.track
    var titleFont: Font = .system(.subheadline, design: .rounded, weight: .bold)
    var progressFont: Font = .system(.caption, design: .rounded, weight: .bold)
    var iconTint: Color = PlayfulTokens.warning
    var chestClosedGlyph: Image = Image(systemName: "shippingbox.fill")
    var chestOpenGlyph: Image = Image(systemName: "shippingbox.and.arrow.backward.fill")
    var chestReadyTint: Color = PlayfulTokens.gold
    // Social variant
    var userFill: Color = PlayfulTokens.accentSecondary
    var partnerFill: Color = PlayfulTokens.purple
    var timeFont: Font = .system(.caption, design: .rounded, weight: .semibold)
    var timeTint: Color = .secondary
    var timeGlyph: Image = Image(systemName: "clock")
    var avatarSize: CGFloat = 40
    var hapticsEnabled: Bool = true
}

/// Challenge card for any goal loop: icon slot, title, springy
/// fraction-labeled progress bar, and a trailing reward chest with
/// locked/ready(wiggling)/opened states. Passing a `partner` switches to the
/// social variant: two avatar slots flank a combined two-segment progress bar
/// with a time-remaining label.
@available(iOS 17.0, *)
struct ChallengeCard: View {
    var title: String
    /// The user's progress toward `goal`.
    var progress: Int
    var goal: Int
    var rewardState: ChallengeRewardState = .locked
    /// Optional leading icon slot (solo variant). The reference quest rows
    /// carry no leading icon, so `nil` (the default) hides the column.
    var icon: Image? = nil
    /// Time-remaining copy (e.g. "2 days left"). Hidden when nil.
    var timeRemaining: String? = nil
    /// Shared-challenge partner; non-nil renders the social variant.
    var partner: ChallengePartner? = nil
    var userName: String = "You"
    /// User avatar slot (social variant); a neutral monogram circle when nil.
    var userAvatar: AnyView? = nil
    var config: ChallengeCardConfig = ChallengeCardConfig()
    var onRewardTap: () -> Void = {}

    @State private var wiggling = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var userFraction: Double {
        goal > 0 ? min(1, Double(progress) / Double(goal)) : 0
    }
    private var partnerFraction: Double {
        guard let partner, goal > 0 else { return 0 }
        return min(1 - userFraction, Double(partner.progress) / Double(goal))
    }
    private var combinedProgress: Int { progress + (partner?.progress ?? 0) }

    var body: some View {
        Group {
            if let partner {
                socialBody(partner)
            } else {
                soloBody
            }
        }
        .padding(16)
        .background(config.cardFill, in: RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard,
                                                          style: .continuous))
        .onAppear { startWiggleIfReady() }
        .onChange(of: rewardState) { _, _ in startWiggleIfReady() }
    }

    // MARK: Solo variant

    private var soloBody: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        soloIcon
                        titleText
                        Spacer(minLength: 8)
                        chest
                    }
                    soloProgressBar
                }
            } else {
                HStack(spacing: 14) {
                    soloIcon
                    VStack(alignment: .leading, spacing: 10) {
                        titleRow
                        soloProgressBar
                    }
                    chest
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(progress) of \(goal).")
    }

    @ViewBuilder
    private var soloIcon: some View {
        if let icon {
            icon
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(config.iconTint)
                .frame(width: 40)
        }
    }

    @ViewBuilder
    private var soloProgressBar: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 5) {
                soloProgressTrack
                progressLabel(progress)
            }
        } else {
            soloProgressTrack
                .overlay { progressLabel(progress) }
        }
    }

    private var soloProgressTrack: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(config.progressTrack)
                Capsule()
                    .fill(config.progressFill)
                    .frame(width: max(userFraction > 0 ? 14 : 0, proxy.size.width * userFraction))
                    .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.75), value: userFraction)
            }
        }
        .frame(height: 16)
    }

    private func progressLabel(_ amount: Int) -> some View {
        Text("\(amount) / \(goal)")
            .font(config.progressFont)
            .foregroundStyle(.secondary)
            .monospacedDigit()
    }

    private var chest: some View {
        Button(action: onRewardTap) {
            (rewardState == .opened ? config.chestOpenGlyph : config.chestClosedGlyph)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(chestTint)
                .rotationEffect(.degrees(wiggling ? 7 : (rewardState == .ready ? -7 : 0)))
                .scaleEffect(rewardState == .opened ? 1.05 : 1)
        }
        .disabled(rewardState != .ready)
        .sensoryFeedback(.success, trigger: rewardState) { _, new in
            config.hapticsEnabled && new == .opened
        }
        .accessibilityLabel("Challenge reward")
        .accessibilityValue(chestAccessibilityValue)
    }

    // MARK: Social variant

    private func socialBody(_ partner: ChallengePartner) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            titleRow
            HStack(spacing: 10) {
                avatar(userAvatar, name: userName, fill: config.userFill)
                combinedBar(partner)
                avatar(partner.avatar, name: partner.name, fill: config.partnerFill)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("Together \(combinedProgress) of \(goal). \(timeRemaining ?? "")")
    }

    private func combinedBar(_ partner: ChallengePartner) -> some View {
        VStack(spacing: 5) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(config.progressTrack)
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(config.userFill)
                            .frame(width: proxy.size.width * userFraction)
                        Rectangle()
                            .fill(config.partnerFill)
                            .frame(width: proxy.size.width * partnerFraction)
                    }
                    .clipShape(Capsule())
                    .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.75),
                               value: userFraction + partnerFraction)
                }
            }
            .frame(height: 16)
            // Fraction sits under the bar so it stays legible over any fill.
            Text("\(combinedProgress) / \(goal)")
                .font(config.progressFont)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    private func avatar(_ custom: AnyView?, name: String, fill: Color) -> some View {
        Group {
            if let custom {
                custom
            } else {
                Circle()
                    .fill(fill.opacity(0.2))
                    .overlay {
                        Text(name.prefix(1).uppercased())
                            .font(.system(.footnote, design: .rounded, weight: .heavy))
                            .foregroundStyle(fill)
                    }
            }
        }
        .frame(width: config.avatarSize, height: config.avatarSize)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(fill, lineWidth: 2))
        .accessibilityLabel(name)
    }

    // MARK: Shared pieces

    @ViewBuilder
    private var titleRow: some View {
        if let timeRemaining {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 5) {
                    titleText
                    timeLabel(timeRemaining)
                }
            } else {
                HStack(alignment: .top, spacing: 8) {
                    titleText
                    Spacer(minLength: 8)
                    timeLabel(timeRemaining)
                }
            }
        } else {
            titleText
        }
    }

    private func timeLabel(_ text: String) -> some View {
        Label(
            title: { Text(text).font(config.timeFont) },
            icon: { config.timeGlyph.font(config.timeFont) }
        )
        .foregroundStyle(config.timeTint)
    }

    private var titleText: some View {
            Text(title)
                .font(config.titleFont)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
    }

    private var chestTint: Color {
        switch rewardState {
        case .locked: PlayfulTokens.inkDisabled
        case .ready: config.chestReadyTint
        case .opened: config.iconTint
        }
    }

    private var chestAccessibilityValue: String {
        switch rewardState {
        case .locked: "Locked"
        case .ready: "Ready to open"
        case .opened: "Opened"
        }
    }

    private func startWiggleIfReady() {
        guard partner == nil, rewardState == .ready, !reduceMotion else {
            wiggling = false
            return
        }
        withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
            wiggling = true
        }
    }
}

#Preview("Challenge cards") {
    VStack(spacing: 12) {
        ChallengeCard(title: "Earn 30 XP", progress: 10, goal: 30)
        ChallengeCard(title: "Complete 3 perfect lessons", progress: 3, goal: 3, rewardState: .ready)
        ChallengeCard(title: "Spend 10 minutes learning", progress: 10, goal: 10, rewardState: .opened,
                      icon: Image(systemName: "clock.fill"))
        ChallengeCard(title: "Earn 200 XP together", progress: 80, goal: 200,
                      timeRemaining: "2 days left",
                      partner: ChallengePartner(name: "Mia", progress: 45))
    }
    .padding(20)
}
