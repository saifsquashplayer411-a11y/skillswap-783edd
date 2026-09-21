import SwiftUI

struct ChallengesHubView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                PlayfulTokens.ground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Streak Hero Header
                        streakStatusCard
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Weekly XP Goal Meter
                        weeklyGoalCard
                            .padding(.horizontal, 20)
                        
                        // Active Daily Quests
                        dailyQuestsSection
                            .padding(.horizontal, 20)
                        
                        // Friend-style Collaboration Quests
                        friendQuestsSection
                            .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Challenges & Streaks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(PlayfulTokens.accent)
                }
            }
        }
    }
    
    // MARK: - Streak Hero Card
    private var streakStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(PlayfulTokens.warning.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(PlayfulTokens.warning)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(appState.currentUser.streakDays) Day Learning Streak! 🔥")
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    
                    Text("Complete 1 short lesson every day to build lasting mastery.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Streak Freezes & Days Row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "snowflake")
                        .foregroundStyle(PlayfulTokens.accent)
                    Text("\(appState.streakFreezesAvailable) Streak Freeze Active")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(PlayfulTokens.ink)
                }
                
                Spacer()
                
                Text("Missing 1 day won't reset you")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
        }
        .padding(18)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    // MARK: - Weekly Goal Card
    private var weeklyGoalCard: some View {
        let progress = min(1.0, Double(appState.currentWeeklyXp) / Double(appState.weeklyXpGoal))
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(PlayfulTokens.gold)
                    Text("WEEKLY XP GOAL")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                
                Spacer()
                
                Text("\(appState.currentWeeklyXp)/\(appState.weeklyXpGoal) XP")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.ink)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(PlayfulTokens.track)
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(LinearGradient(colors: [PlayfulTokens.gold, PlayfulTokens.warning], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(progress), height: 12)
                }
            }
            .frame(height: 12)
            
            Text(appState.currentWeeklyXp >= appState.weeklyXpGoal ? "🎉 Goal reached! You crushed your weekly target." : "🎯 Reach 200 XP by Sunday to claim the Weekly Champion badge.")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(PlayfulTokens.inkSecondary)
        }
        .padding(18)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    // MARK: - Daily Quests Section
    private var dailyQuestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Quests")
                .font(PlayfulTokens.titleFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            ForEach(appState.challenges.filter { $0.isDaily }) { challenge in
                challengeRow(challenge)
            }
        }
    }
    
    // MARK: - Friend Quests Section
    private var friendQuestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Friend & Collaborative Quests")
                .font(PlayfulTokens.titleFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            ForEach(appState.challenges.filter { !$0.isDaily && $0.friendPartnerName != nil }) { challenge in
                challengeRow(challenge)
            }
        }
    }
    
    private func challengeRow(_ challenge: ChallengeItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: challenge.icon)
                        .foregroundStyle(PlayfulTokens.accent)
                    Text(challenge.title)
                        .font(PlayfulTokens.headlineFont)
                        .foregroundStyle(PlayfulTokens.ink)
                }
                
                Spacer()
                
                Text("+\(challenge.xpReward) XP")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.gold)
            }
            
            Text(challenge.description)
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.inkSecondary)
            
            HStack {
                Text("Progress: \(challenge.currentProgress)/\(challenge.targetProgress)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(challenge.isCompleted ? PlayfulTokens.positive : PlayfulTokens.inkSecondary)
                
                Spacer()
                
                if challenge.isCompleted {
                    Text("COMPLETED 🎉")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.positive)
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
}
