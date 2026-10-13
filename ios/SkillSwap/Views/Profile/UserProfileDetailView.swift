import SwiftUI

struct UserProfileDetailView: View {
    @EnvironmentObject var appState: AppState
    let user: UserProfile
    var onStartChat: () -> Void
    var onOpenLesson: (Lesson) -> Void
    
    @State private var showSafetyPrompt: Bool = false
    
    var userLessons: [Lesson] {
        appState.lessons.filter { $0.authorId == user.id }
    }
    
    var matchQuality: (score: Int, isPerfectMatch: Bool, teachMatch: SkillItem?, learnMatch: SkillItem?) {
        appState.getMatchQuality(for: user)
    }
    
    var body: some View {
        ZStack {
            PlayfulTokens.ground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header Card
                    headerCard
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Perfect Match Breakdown (if complementary)
                    matchBreakdownCard
                        .padding(.horizontal, 20)
                    
                    // Skills Grid Section
                    skillsSection
                        .padding(.horizontal, 20)
                    
                    // Lessons Offered Section
                    lessonsOfferedSection
                        .padding(.horizontal, 20)
                    
                    // Badges Section
                    badgesSection
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 60)
                }
            }
            
            // Bottom Action Bar
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        onStartChat()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message & Swap Skills")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(PlayfulTokens.accent)
                        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                        .overlay(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                                .stroke(PlayfulTokens.accentSecondaryDeep, lineWidth: 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 14) {
            UserAvatarView(emoji: user.avatarEmoji, colorHex: user.avatarColorHex, size: 76)
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(user.name)
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    
                    if matchQuality.isPerfectMatch {
                        PerfectMatchPill()
                    }
                }
                
                Text(user.handle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            Text(user.bio)
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.ink)
                .multilineTextAlignment(.center)
            
            // Stats Row
            HStack(spacing: 16) {
                statItem(title: "Level", value: "\(user.level)", icon: "star.fill", color: PlayfulTokens.gold)
                statItem(title: "Streak", value: "\(user.streakDays)d", icon: "flame.fill", color: PlayfulTokens.warning)
                statItem(title: "Taught", value: "\(user.lessonsTaughtCount)", icon: "graduationcap.fill", color: PlayfulTokens.accent)
                statItem(title: "Rating", value: String(format: "%.1f ★", user.averageRating), icon: "star.circle.fill", color: PlayfulTokens.gold)
            }
            .padding(.top, 6)
        }
        .padding(20)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.ink)
            }
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(PlayfulTokens.inkSecondary)
        }
    }
    
    // MARK: - Match Breakdown
    private var matchBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(PlayfulTokens.gold)
                Text("Skill Swap Compatibility")
                    .font(PlayfulTokens.headlineFont)
                    .foregroundStyle(PlayfulTokens.ink)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("THEY CAN TEACH YOU")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                    Text(matchQuality.teachMatch?.name ?? "General Skills")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(PlayfulTokens.gold)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("YOU CAN TEACH THEM")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                    Text(matchQuality.learnMatch?.name ?? "General Skills")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.purple)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
            .background(PlayfulTokens.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
        }
        .padding(16)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(matchQuality.isPerfectMatch ? PlayfulTokens.gold : PlayfulTokens.border, lineWidth: matchQuality.isPerfectMatch ? 2 : 1.5)
        }
    }
    
    // MARK: - Skills Section
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Can Teach
            VStack(alignment: .leading, spacing: 8) {
                Text("Skills \(user.name.components(separatedBy: " ").first ?? "They") Can Teach")
                    .font(PlayfulTokens.headlineFont)
                    .foregroundStyle(PlayfulTokens.ink)
                
                FlowLayout(spacing: 8) {
                    ForEach(user.teachSkills, id: \.self) { skillId in
                        if let skill = SkillItem.catalog.first(where: { $0.id == skillId }) {
                            SkillChip(skill: skill, isSelected: true, showCategoryIcon: true)
                        }
                    }
                }
            }
            
            Divider()
            
            // Wants to Learn
            VStack(alignment: .leading, spacing: 8) {
                Text("Skills \(user.name.components(separatedBy: " ").first ?? "They") Want to Learn")
                    .font(PlayfulTokens.headlineFont)
                    .foregroundStyle(PlayfulTokens.ink)
                
                FlowLayout(spacing: 8) {
                    ForEach(user.learnSkills, id: \.self) { skillId in
                        if let skill = SkillItem.catalog.first(where: { $0.id == skillId }) {
                            SkillChip(skill: skill, isSelected: false, showCategoryIcon: true)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    // MARK: - Lessons Offered Section
    private var lessonsOfferedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lessons by \(user.name.components(separatedBy: " ").first ?? "User")")
                .font(PlayfulTokens.headlineFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            if userLessons.isEmpty {
                Text("No published lessons yet.")
                    .font(PlayfulTokens.captionFont)
                    .foregroundStyle(PlayfulTokens.inkSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(userLessons) { lesson in
                    LessonRowCard(lesson: lesson) {
                        onOpenLesson(lesson)
                    }
                }
            }
        }
    }
    
    // MARK: - Badges Section
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Badges & Achievements")
                .font(PlayfulTokens.headlineFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            HStack(spacing: 12) {
                ForEach(user.badgesEarned, id: \.self) { badgeId in
                    if let badge = BadgeItem.allBadges.first(where: { $0.id == badgeId }) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(PlayfulTokens.goldSoft)
                                    .frame(width: 44, height: 44)
                                Image(systemName: badge.icon)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(PlayfulTokens.goldDeep)
                            }
                            Text(badge.title)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(PlayfulTokens.ink)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
}

// Simple FlowLayout Helper for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            currentX += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
            height = currentY + maxHeightInRow
        }
        return CGSize(width: width, height: max(height, 30))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += maxHeightInRow + spacing
                maxHeightInRow = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            maxHeightInRow = max(maxHeightInRow, size.height)
        }
    }
}
