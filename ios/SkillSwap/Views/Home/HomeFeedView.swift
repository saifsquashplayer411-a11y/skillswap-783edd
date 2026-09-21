import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var appState: AppState
    
    // Navigation Triggers
    @State private var selectedUserForProfile: UserProfile? = nil
    @State private var selectedLessonForDetail: Lesson? = nil
    @State private var activeConversationForChat: Conversation? = nil
    @State private var showChallengesSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                PlayfulTokens.ground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Top Header Bar: Streaks, Level, Credits
                        headerStatsBar
                        
                        // Safety Reminder Banner
                        SafetyBannerView()
                            .padding(.horizontal, 20)
                        
                        // Today's Daily Challenge Card
                        dailyChallengeHeroCard
                            .padding(.horizontal, 20)
                        
                        // Perfect Skill Matches Section
                        perfectSkillMatchesSection
                        
                        // Recommended Lessons Section
                        recommendedLessonsSection
                        
                        // Skill Credits Economy Card
                        skillCreditsPromoCard
                            .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("SkillSwap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(PlayfulTokens.accent)
                        Text("SkillSwap")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(PlayfulTokens.ink)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showChallengesSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(PlayfulTokens.warning)
                            Text("\(appState.currentUser.streakDays)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundStyle(PlayfulTokens.ink)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(PlayfulTokens.surfaceRaised)
                        .clipShape(Capsule())
                        .overlay {
                            Capsule().strokeBorder(PlayfulTokens.border, lineWidth: 1)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedUserForProfile) { user in
                UserProfileDetailView(user: user, onStartChat: {
                    let conv = appState.startConversation(with: user)
                    selectedUserForProfile = nil
                    activeConversationForChat = conv
                }, onOpenLesson: { lesson in
                    selectedUserForProfile = nil
                    selectedLessonForDetail = lesson
                })
            }
            .navigationDestination(item: $selectedLessonForDetail) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .navigationDestination(item: $activeConversationForChat) { conv in
                ChatDetailView(conversation: conv)
            }
            .sheet(isPresented: $showChallengesSheet) {
                ChallengesHubView()
            }
        }
    }
    
    // MARK: - Header Stats Bar (Streak, XP, Skill Credits)
    private var headerStatsBar: some View {
        HStack(spacing: 12) {
            // Streak Capsule
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(PlayfulTokens.warning)
                Text("\(appState.currentUser.streakDays)d streak")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(PlayfulTokens.surface)
            .clipShape(Capsule())
            .overlay { Capsule().strokeBorder(PlayfulTokens.border, lineWidth: 1) }
            
            // Level Pill
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(PlayfulTokens.gold)
                Text("Lvl \(appState.currentUser.level) \(appState.currentUser.levelTitle)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(PlayfulTokens.surface)
            .clipShape(Capsule())
            .overlay { Capsule().strokeBorder(PlayfulTokens.border, lineWidth: 1) }
            
            Spacer()
            
            // Skill Credits Badge
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(PlayfulTokens.accent)
                Text("\(appState.currentUser.skillCredits) Credits")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(PlayfulTokens.accentSoft.opacity(0.8))
            .clipShape(Capsule())
            .overlay { Capsule().strokeBorder(PlayfulTokens.accent.opacity(0.3), lineWidth: 1) }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Daily Challenge Hero Card
    private var dailyChallengeHeroCard: some View {
        let daily = appState.challenges.first(where: { $0.isDaily })
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(PlayfulTokens.accent)
                    Text("TODAY'S CHALLENGE")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                
                Spacer()
                
                Text("+50 XP")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.gold)
            }
            
            Text(daily?.title ?? "Daily Skill Practice")
                .font(PlayfulTokens.titleFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            Text(daily?.description ?? "Complete 1 short 10-minute lesson today to keep your streak alive.")
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.inkSecondary)
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(daily?.isCompleted == true ? "Completed! 🔥" : "Progress: \(daily?.currentProgress ?? 0)/\(daily?.targetProgress ?? 1)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(daily?.isCompleted == true ? PlayfulTokens.positive : PlayfulTokens.inkSecondary)
                    Spacer()
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(PlayfulTokens.track)
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(daily?.isCompleted == true ? PlayfulTokens.positive : PlayfulTokens.accent)
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(daily?.currentProgress ?? 0) / CGFloat(max(1, daily?.targetProgress ?? 1)))), height: 10)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(18)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Perfect Skill Matches Section
    private var perfectSkillMatchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(PlayfulTokens.gold)
                        Text("Perfect Skill Matches")
                            .font(PlayfulTokens.titleFont)
                            .foregroundStyle(PlayfulTokens.ink)
                    }
                    Text("Peers who teach what you want, and want what you teach")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Carousel or List of Matches
            VStack(spacing: 12) {
                let matches = appState.recommendedUsers
                if matches.isEmpty {
                    VStack(spacing: 8) {
                        Text("No skill matches yet")
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                        Text("Add more skills to your profile to unlock new peer matches.")
                            .font(PlayfulTokens.captionFont)
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(PlayfulTokens.surface)
                    .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
                    .padding(.horizontal, 20)
                } else {
                    ForEach(matches.prefix(3)) { user in
                        let quality = appState.getMatchQuality(for: user)
                        PeerMatchCard(
                            user: user,
                            matchQuality: quality,
                            onConnect: {
                                let conv = appState.startConversation(with: user)
                                activeConversationForChat = conv
                            },
                            onTapProfile: {
                                selectedUserForProfile = user
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
    
    // MARK: - Recommended Lessons Section
    private var recommendedLessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recommended Lessons")
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    Text("Bite-sized guides matched to your learning goals")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 10) {
                ForEach(appState.recommendedLessons) { lesson in
                    LessonRowCard(lesson: lesson) {
                        selectedLessonForDetail = lesson
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Skill Credits Promo Card
    private var skillCreditsPromoCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(PlayfulTokens.goldSoft)
                    .frame(width: 52, height: 52)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(PlayfulTokens.goldDeep)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Teach & Learn Economy")
                    .font(PlayfulTokens.headlineFont)
                    .foregroundStyle(PlayfulTokens.ink)
                Text("Teach 1 lesson → Earn 1 Skill Credit → Spend it learning anything new.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
}
