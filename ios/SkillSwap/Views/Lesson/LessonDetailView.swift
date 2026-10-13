import SwiftUI

struct LessonDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let lesson: Lesson
    
    // Step completion tracking
    @State private var completedStepIds: Set<String> = []
    @State private var challengeCompleted: Bool = false
    @State private var userFeedbackRating: Int = 5
    @State private var showCelebrationModal: Bool = false
    @State private var feedbackSubmitted: Bool = false
    
    var allStepsDone: Bool {
        completedStepIds.count == lesson.steps.count && challengeCompleted
    }
    
    var body: some View {
        ZStack {
            PlayfulTokens.ground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Lesson Hero Header Card
                    heroCard
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Instructions / Steps Section
                    stepsSection
                        .padding(.horizontal, 20)
                    
                    // Completion Challenge Box
                    challengeBox
                        .padding(.horizontal, 20)
                    
                    // Rating / Feedback Box (if already done)
                    if lesson.isCompletedByCurrentUser || feedbackSubmitted {
                        completedFeedbackBox
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 80)
                }
            }
            
            // Bottom Action Bar
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    if lesson.isCompletedByCurrentUser || feedbackSubmitted {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(PlayfulTokens.positive)
                            Text("Lesson Completed (+\(lesson.xpReward + 10) XP earned)")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundStyle(PlayfulTokens.positive)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(PlayfulTokens.surface)
                        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                                .strokeBorder(PlayfulTokens.positive, lineWidth: 1.5)
                        }
                    } else {
                        Button {
                            completeThisLesson()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: allStepsDone ? "checkmark.circle.fill" : "lock.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(allStepsDone ? "Mark Complete & Earn +\(lesson.xpReward) XP" : "Complete Steps (\(completedStepIds.count)/\(lesson.steps.count))")
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(allStepsDone ? PlayfulTokens.positive : PlayfulTokens.inkDisabled)
                            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                            .overlay(alignment: .bottom) {
                                if allStepsDone {
                                    RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                                        .stroke(Color(red: 0.20, green: 0.65, blue: 0.35), lineWidth: 3)
                                }
                            }
                        }
                        .disabled(!allStepsDone)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            
            // Celebration Modal Overlay
            if showCelebrationModal {
                celebrationOverlay
            }
        }
        .navigationTitle(lesson.skillName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Hero Card
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: lesson.category.iconName)
                        .foregroundStyle(lesson.category.color)
                    Text(lesson.category.rawValue.uppercased())
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(lesson.category.color)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(PlayfulTokens.gold)
                    Text("+\(lesson.xpReward) XP")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.ink)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PlayfulTokens.goldSoft)
                .clipShape(Capsule())
            }
            
            Text(lesson.title)
                .font(PlayfulTokens.titleFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            Text(lesson.description)
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.inkSecondary)
            
            Divider()
            
            // Meta Row
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Text(lesson.authorAvatar)
                    Text("Taught by \(lesson.authorName)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(PlayfulTokens.ink)
                }
                
                Spacer()
                
                Label("\(lesson.estimatedMinutes) min", systemImage: "clock.fill")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
                
                Label("\(lesson.completedByCount) learners", systemImage: "person.2.fill")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
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
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Steps Section
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Step-by-Step Guide")
                    .font(PlayfulTokens.titleFont)
                    .foregroundStyle(PlayfulTokens.ink)
                Spacer()
                Text("\(completedStepIds.count)/\(lesson.steps.count) checked")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.accent)
            }
            
            VStack(spacing: 12) {
                ForEach(lesson.steps) { step in
                    let isDone = completedStepIds.contains(step.id) || lesson.isCompletedByCurrentUser
                    
                    Button {
                        if !lesson.isCompletedByCurrentUser {
                            if completedStepIds.contains(step.id) {
                                completedStepIds.remove(step.id)
                            } else {
                                completedStepIds.insert(step.id)
                            }
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 14) {
                            // Step Checkbox Icon
                            ZStack {
                                Circle()
                                    .fill(isDone ? PlayfulTokens.positive : PlayfulTokens.surfaceRaised)
                                    .frame(width: 32, height: 32)
                                
                                if isDone {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundStyle(Color.white)
                                } else {
                                    Text("\(step.stepNumber)")
                                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                                        .foregroundStyle(PlayfulTokens.inkSecondary)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundStyle(PlayfulTokens.ink)
                                
                                Text(step.instruction)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(PlayfulTokens.ink)
                                    .multilineTextAlignment(.leading)
                                
                                if let tip = step.tip {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(PlayfulTokens.gold)
                                        Text("Pro Tip: \(tip)")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                            .foregroundStyle(PlayfulTokens.inkSecondary)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(isDone ? PlayfulTokens.surface : PlayfulTokens.surfaceRaised.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                                .strokeBorder(isDone ? PlayfulTokens.positive.opacity(0.4) : PlayfulTokens.border, lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Challenge Box
    private var challengeBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(PlayfulTokens.accent)
                Text("PRACTICE CHALLENGE")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            Text(lesson.challengePrompt)
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(PlayfulTokens.gold)
                Text("Completion Goal: \(lesson.challengeSolutionHint)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            Button {
                challengeCompleted.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: challengeCompleted || lesson.isCompletedByCurrentUser ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(challengeCompleted || lesson.isCompletedByCurrentUser ? PlayfulTokens.accent : PlayfulTokens.inkSecondary)
                    
                    Text(challengeCompleted || lesson.isCompletedByCurrentUser ? "I completed the practice challenge!" : "Tap when you finish the practice challenge")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(PlayfulTokens.ink)
                }
                .padding(.top, 6)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(PlayfulTokens.accentSoft.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.accent.opacity(0.4), lineWidth: 1.5)
        }
    }
    
    // MARK: - Completed Feedback Box
    private var completedFeedbackBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rate this peer lesson")
                .font(PlayfulTokens.headlineFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        userFeedbackRating = star
                    } label: {
                        Image(systemName: star <= userFeedbackRating ? "star.fill" : "star")
                            .font(.system(size: 24))
                            .foregroundStyle(PlayfulTokens.gold)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Text("\(userFeedbackRating)/5 Stars")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
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
    
    // MARK: - Celebration Overlay
    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Celebration Icon
                ZStack {
                    Circle()
                        .fill(PlayfulTokens.goldSoft)
                        .frame(width: 80, height: 80)
                    Text("🎉")
                        .font(.system(size: 42))
                }
                
                VStack(spacing: 6) {
                    Text("Lesson Complete!")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.ink)
                    
                    Text("You leveled up your skills and earned rewards:")
                        .font(PlayfulTokens.bodyFont)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Reward Badges Box
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("+\(lesson.xpReward + 10)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(PlayfulTokens.gold)
                        Text("XP Earned")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(PlayfulTokens.surfaceRaised)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(PlayfulTokens.warning)
                            Text("\(appState.currentUser.streakDays)d")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(PlayfulTokens.ink)
                        }
                        Text("Streak Active")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(PlayfulTokens.surfaceRaised)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                // Done Button
                Button {
                    showCelebrationModal = false
                    feedbackSubmitted = true
                    dismiss()
                } label: {
                    Text("Awesome! 🚀")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(PlayfulTokens.accent)
                        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                        .overlay(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                                .stroke(PlayfulTokens.accentSecondaryDeep, lineWidth: 3)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(PlayfulTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 28)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
    }
    
    private func completeThisLesson() {
        appState.completeLesson(lesson, rating: userFeedbackRating)
        showCelebrationModal = true
    }
}
