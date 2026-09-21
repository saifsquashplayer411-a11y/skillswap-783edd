import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var step: Int = 0
    
    // Step 0: Name & Emoji
    @State private var name: String = "Jordan Lee"
    @State private var handle: String = "@jordan_builds"
    @State private var selectedEmoji: String = "⚡️"
    
    // Step 1: Skills I can teach
    @State private var selectedTeachSkills: Set<String> = ["swift_coding", "video_edit"]
    
    // Step 2: Skills I want to learn
    @State private var selectedLearnSkills: Set<String> = ["basketball", "guitar", "spanish"]
    
    // Step 3: Interests & Safety Pledge
    @State private var selectedInterests: Set<String> = ["App Design", "Basketball", "Indie Music"]
    @State private var agreedToSafetyPledge: Bool = true
    
    let emojiOptions = ["⚡️", "🎨", "🏀", "🎸", "💻", "🌮", "🚀", "🔥", "🎧", "📸"]
    let interestOptions = ["App Design", "Basketball", "Indie Music", "Gaming", "Languages", "Filmmaking", "Drawing", "Fitness", "Science"]
    
    var body: some View {
        ZStack {
            PlayfulTokens.ground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Progress Bar
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(index <= step ? PlayfulTokens.accent : PlayfulTokens.track)
                            .frame(height: 6)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Content Views by Step
                TabView(selection: $step) {
                    step0View.tag(0)
                    step1View.tag(1)
                    step2View.tag(2)
                    step3View.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: step)
                
                // Bottom Button Action Bar
                VStack(spacing: 12) {
                    Button {
                        if step < 3 {
                            withAnimation { step += 1 }
                        } else {
                            finishOnboarding()
                        }
                    } label: {
                        HStack {
                            Text(step == 3 ? "Start Swapping Skills! 🚀" : "Continue")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .heavy))
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
                    
                    if step > 0 {
                        Button {
                            withAnimation { step -= 1 }
                        } label: {
                            Text("Back")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Step 0: Name & Identity
    private var step0View: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Welcome to SkillSwap! ⚡️")
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                        .multilineTextAlignment(.center)
                    
                    Text("Learn practical skills from peers and teach what you know to level up together.")
                        .font(PlayfulTokens.bodyFont)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Avatar Picker
                VStack(spacing: 12) {
                    UserAvatarView(emoji: selectedEmoji, colorHex: "#1CB0F6", size: 84)
                    
                    Text("Choose your avatar emoji:")
                        .font(PlayfulTokens.captionFont)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button {
                                    selectedEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 48, height: 48)
                                        .background(selectedEmoji == emoji ? PlayfulTokens.accentSoft : PlayfulTokens.surfaceRaised)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .strokeBorder(selectedEmoji == emoji ? PlayfulTokens.accent : PlayfulTokens.border, lineWidth: 2)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(16)
                .background(PlayfulTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                        .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
                }
                
                // Form Fields
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Display Name")
                            .font(PlayfulTokens.captionFont)
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                        
                        TextField("e.g. Jordan Lee", text: $name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .padding(14)
                            .background(PlayfulTokens.surfaceRaised)
                            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Handle")
                            .font(PlayfulTokens.captionFont)
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                        
                        TextField("@handle", text: $handle)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .padding(14)
                            .background(PlayfulTokens.surfaceRaised)
                            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
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
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Step 1: Skills I Can Teach
    private var step1View: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("What can you teach? 🎓")
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    
                    Text("Select 1-3 skills you're confident sharing with other teens.")
                        .font(PlayfulTokens.bodyFont)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Skill Selector Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                    ForEach(SkillItem.catalog) { skill in
                        let isSelected = selectedTeachSkills.contains(skill.id)
                        Button {
                            if isSelected {
                                selectedTeachSkills.remove(skill.id)
                            } else {
                                selectedTeachSkills.insert(skill.id)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: skill.icon)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(isSelected ? Color.white : skill.category.color)
                                
                                Text(skill.name)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(isSelected ? PlayfulTokens.accent : PlayfulTokens.surface)
                            .foregroundStyle(isSelected ? Color.white : PlayfulTokens.ink)
                            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                                    .strokeBorder(isSelected ? PlayfulTokens.accentSecondaryDeep : PlayfulTokens.border, lineWidth: 1.5)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Step 2: Skills I Want to Learn
    private var step2View: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("What do you want to learn? 🚀")
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    
                    Text("SkillSwap will find Perfect Matches who teach these exact skills.")
                        .font(PlayfulTokens.bodyFont)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Skill Selector Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                    ForEach(SkillItem.catalog) { skill in
                        let isSelected = selectedLearnSkills.contains(skill.id)
                        Button {
                            if isSelected {
                                selectedLearnSkills.remove(skill.id)
                            } else {
                                selectedLearnSkills.insert(skill.id)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: skill.icon)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(isSelected ? Color.white : skill.category.color)
                                
                                Text(skill.name)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(isSelected ? PlayfulTokens.purple : PlayfulTokens.surface)
                            .foregroundStyle(isSelected ? Color.white : PlayfulTokens.ink)
                            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                                    .strokeBorder(isSelected ? PlayfulTokens.purple : PlayfulTokens.border, lineWidth: 1.5)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Step 3: Interests & Safety Pledge
    private var step3View: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Interests & Safe Space 🛡️")
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    
                    Text("Final step before finding your peer matches.")
                        .font(PlayfulTokens.bodyFont)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                .padding(.top, 20)
                
                // Interest Chips
                VStack(alignment: .leading, spacing: 10) {
                    Text("Pick some shared interests:")
                        .font(PlayfulTokens.headlineFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(interestOptions, id: \.self) { interest in
                            let isSelected = selectedInterests.contains(interest)
                            Button {
                                if isSelected {
                                    selectedInterests.remove(interest)
                                } else {
                                    selectedInterests.insert(interest)
                                }
                            } label: {
                                Text(interest)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? PlayfulTokens.accent : PlayfulTokens.surfaceRaised)
                                    .foregroundStyle(isSelected ? Color.white : PlayfulTokens.ink)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
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
                
                // Safety Pledge Box
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(PlayfulTokens.accent)
                        Text("SkillSwap Teen Community Pledge")
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        safetyBullet("🤝 Be respectful, supportive, and patient with peer learners.")
                        safetyBullet("🚫 No sharing external links, social handles, or private contact info.")
                        safetyBullet("🛡️ Easy 1-tap report and block if you ever feel uncomfortable.")
                    }
                    
                    Toggle(isOn: $agreedToSafetyPledge) {
                        Text("I agree to follow the safety guidelines")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.ink)
                    }
                    .tint(PlayfulTokens.accent)
                    .padding(.top, 4)
                }
                .padding(16)
                .background(PlayfulTokens.accentSoft.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                        .strokeBorder(PlayfulTokens.accent.opacity(0.3), lineWidth: 1.5)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func safetyBullet(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(PlayfulTokens.ink)
    }
    
    private func finishOnboarding() {
        appState.currentUser.name = name.isEmpty ? "Jordan Lee" : name
        appState.currentUser.handle = handle.isEmpty ? "@jordan_builds" : handle
        appState.currentUser.avatarEmoji = selectedEmoji
        appState.currentUser.teachSkills = Array(selectedTeachSkills)
        appState.currentUser.learnSkills = Array(selectedLearnSkills)
        appState.currentUser.interests = Array(selectedInterests)
        appState.hasCompletedOnboarding = true
    }
}
