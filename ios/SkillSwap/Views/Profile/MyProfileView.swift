import SwiftUI

struct MyProfileView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var showCreateLessonSheet: Bool = false
    @State private var showEditSkillsSheet: Bool = false
    @State private var showProPaywallSheet: Bool = false
    @State private var showAdPrivacySheet: Bool = false
    @State private var selectedLessonForDetail: Lesson? = nil
    
    var myCreatedLessons: [Lesson] {
        appState.lessons.filter { $0.authorId == appState.currentUser.id || $0.isUserCreated }
    }
    
    var currentLevelDef: LevelDefinition {
        LevelDefinition.current(for: appState.currentUser.xp)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PlayfulTokens.ground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // User Identity & Level Hero Card
                        profileHeroCard
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Teach & Learn Skill Credits Economy Card
                        skillCreditsCard
                            .padding(.horizontal, 20)
                        
                        // Level Progression Meter
                        levelProgressionCard
                            .padding(.horizontal, 20)
                        
                        // My Skills (Teach vs Learn)
                        mySkillsCard
                            .padding(.horizontal, 20)
                        
                        // Badges Collection Grid
                        badgesCollectionCard
                            .padding(.horizontal, 20)
                        
                        // My Lessons Created / Taught
                        myCreatedLessonsSection
                            .padding(.horizontal, 20)
                        
                        // SkillSwap Pro Membership Banner / Status
                        membershipStatusBanner
                            .padding(.horizontal, 20)
                        
                        // Advertising & Privacy Settings Shortcut
                        privacySettingsButton
                            .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateLessonSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Teach")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                        }
                        .foregroundStyle(PlayfulTokens.accent)
                    }
                }
            }
            .sheet(isPresented: $showCreateLessonSheet) {
                CreateLessonSheet()
            }
            .sheet(isPresented: $showEditSkillsSheet) {
                EditSkillsSheet()
            }
            .sheet(isPresented: $showProPaywallSheet) {
                SkillSwapProPaywallView()
            }
            .sheet(isPresented: $showAdPrivacySheet) {
                AdSettingsSheet()
            }
            .navigationDestination(item: $selectedLessonForDetail) { lesson in
                LessonDetailView(lesson: lesson)
            }
        }
    }
    
    // MARK: - Profile Hero Card
    private var profileHeroCard: some View {
        VStack(spacing: 14) {
            UserAvatarView(emoji: appState.currentUser.avatarEmoji, colorHex: appState.currentUser.avatarColorHex, size: 76)
            
            VStack(spacing: 4) {
                Text(appState.currentUser.name)
                    .font(PlayfulTokens.titleFont)
                    .foregroundStyle(PlayfulTokens.ink)
                
                Text(appState.currentUser.handle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            Text(appState.currentUser.bio)
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.ink)
                .multilineTextAlignment(.center)
            
            // Quick Stats Strip
            HStack(spacing: 16) {
                statBox(title: "Total XP", value: "\(appState.currentUser.xp)", icon: "bolt.fill", color: PlayfulTokens.gold)
                statBox(title: "Streak", value: "\(appState.currentUser.streakDays)d", icon: "flame.fill", color: PlayfulTokens.warning)
                statBox(title: "Completed", value: "\(appState.currentUser.lessonsCompletedCount)", icon: "checkmark.seal.fill", color: PlayfulTokens.positive)
                statBox(title: "Taught", value: "\(appState.currentUser.lessonsTaughtCount)", icon: "graduationcap.fill", color: PlayfulTokens.accent)
            }
        }
        .padding(20)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
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
    
    // MARK: - Skill Credits Card
    private var skillCreditsCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PlayfulTokens.goldSoft)
                    .frame(width: 50, height: 50)
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(PlayfulTokens.goldDeep)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(appState.currentUser.skillCredits) Skill Credits Available")
                    .font(PlayfulTokens.headlineFont)
                    .foregroundStyle(PlayfulTokens.ink)
                Text("Teach a lesson (+1 Credit) • Learn a lesson (costs 1)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            Spacer()
            
            Button {
                showCreateLessonSheet = true
            } label: {
                Text("Teach")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(PlayfulTokens.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    // MARK: - Level Progression Card
    private var levelProgressionCard: some View {
        let curr = currentLevelDef
        let nextXp = curr.nextLevelXp
        let prevXp = curr.xpRequired
        let progressRange = max(1, nextXp - prevXp)
        let currentProgress = max(0, appState.currentUser.xp - prevXp)
        let ratio = min(1.0, Double(currentProgress) / Double(progressRange))
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: curr.iconName)
                        .foregroundStyle(PlayfulTokens.gold)
                    Text("Level \(curr.level): \(curr.title)")
                        .font(PlayfulTokens.headlineFont)
                        .foregroundStyle(PlayfulTokens.ink)
                }
                
                Spacer()
                
                Text("\(appState.currentUser.xp)/\(nextXp) XP")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(PlayfulTokens.track)
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(LinearGradient(colors: [PlayfulTokens.accent, PlayfulTokens.gold], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(ratio), height: 12)
                }
            }
            .frame(height: 12)
            
            Text("Earn +\(nextXp - appState.currentUser.xp) XP to unlock next level badge!")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(PlayfulTokens.inkSecondary)
        }
        .padding(16)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    // MARK: - My Skills Card
    private var mySkillsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Skills")
                    .font(PlayfulTokens.titleFont)
                    .foregroundStyle(PlayfulTokens.ink)
                
                Spacer()
                
                Button {
                    showEditSkillsSheet = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.accent)
                }
            }
            
            // Skills I Teach
            VStack(alignment: .leading, spacing: 6) {
                Text("I CAN TEACH")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
                
                FlowLayout(spacing: 6) {
                    ForEach(appState.currentUser.teachSkills, id: \.self) { id in
                        if let s = SkillItem.catalog.first(where: { $0.id == id }) {
                            SkillChip(skill: s, isSelected: true, showCategoryIcon: true)
                        }
                    }
                }
            }
            
            Divider()
            
            // Skills I Want to Learn
            VStack(alignment: .leading, spacing: 6) {
                Text("I WANT TO LEARN")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
                
                FlowLayout(spacing: 6) {
                    ForEach(appState.currentUser.learnSkills, id: \.self) { id in
                        if let s = SkillItem.catalog.first(where: { $0.id == id }) {
                            SkillChip(skill: s, isSelected: false, showCategoryIcon: true)
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
    
    // MARK: - Badges Collection
    private var badgesCollectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Badges & Milestones")
                    .font(PlayfulTokens.titleFont)
                    .foregroundStyle(PlayfulTokens.ink)
                
                Spacer()
                
                Text("\(appState.badges.filter { $0.isUnlocked }.count)/\(appState.badges.count)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.gold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 75))], spacing: 14) {
                ForEach(appState.badges) { badge in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(badge.isUnlocked ? PlayfulTokens.goldSoft : PlayfulTokens.surfaceRaised)
                                .frame(width: 52, height: 52)
                            
                            Image(systemName: badge.icon)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(badge.isUnlocked ? PlayfulTokens.goldDeep : PlayfulTokens.inkDisabled)
                        }
                        .overlay {
                            Circle()
                                .strokeBorder(badge.isUnlocked ? PlayfulTokens.gold : PlayfulTokens.border, lineWidth: badge.isUnlocked ? 2 : 1)
                        }
                        
                        Text(badge.title)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(badge.isUnlocked ? PlayfulTokens.ink : PlayfulTokens.inkDisabled)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
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
    
    // MARK: - Created Lessons Section
    private var myCreatedLessonsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Lessons I Teach")
                    .font(PlayfulTokens.titleFont)
                    .foregroundStyle(PlayfulTokens.ink)
                
                Spacer()
                
                Button {
                    showCreateLessonSheet = true
                } label: {
                    Text("+ New Lesson")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(PlayfulTokens.accent)
                }
            }
            
            if myCreatedLessons.isEmpty {
                VStack(spacing: 8) {
                    Text("You haven't published a lesson yet")
                        .font(PlayfulTokens.headlineFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    Text("Share a 10-minute skill guide with your peers to earn Skill Credits!")
                        .font(PlayfulTokens.captionFont)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(PlayfulTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
            } else {
                ForEach(myCreatedLessons) { lesson in
                    LessonRowCard(lesson: lesson) {
                        selectedLessonForDetail = lesson
                    }
                }
            }
        }
    }
    
    // MARK: - Pro Membership & Status Banner
    private var membershipStatusBanner: some View {
        let isPro = SubscriptionManager.shared.isProSubscribed
        return Button {
            showProPaywallSheet = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isPro ? PlayfulTokens.goldSoft : PlayfulTokens.accentSoft)
                        .frame(width: 44, height: 44)
                    Image(systemName: isPro ? "bolt.fill" : "sparkles")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(isPro ? PlayfulTokens.goldDeep : PlayfulTokens.accent)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(isPro ? "SkillSwap Pro Member" : "Upgrade to SkillSwap Pro")
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                        if isPro {
                            Text("PRO")
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(PlayfulTokens.goldDeep)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(isPro ? "Zero ads • 2x XP boost • Streak protection" : "Remove all ads, get 2x XP boost, and unlock mentor perks")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(PlayfulTokens.inkDisabled)
            }
            .padding(14)
            .background(PlayfulTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                    .strokeBorder(isPro ? PlayfulTokens.gold : PlayfulTokens.border, lineWidth: isPro ? 1.5 : 1)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Ad Privacy & Safety Settings
    private var privacySettingsButton: some View {
        Button {
            showAdPrivacySheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(PlayfulTokens.positive)
                
                Text("Teen Privacy & Ad Controls")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(PlayfulTokens.ink)
                
                Spacer()
                
                Text("Protected")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(PlayfulTokens.positive)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(PlayfulTokens.inkDisabled)
            }
            .padding(14)
            .background(PlayfulTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                    .strokeBorder(PlayfulTokens.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Create Lesson Sheet
struct CreateLessonSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var selectedSkillId: String = "swift_coding"
    @State private var estimatedMinutes: Int = 15
    @State private var step1Title: String = "Setup & Getting Ready"
    @State private var step1Instruction: String = "Open the project and get your tools in place."
    @State private var step2Title: String = "Core Practice Drills"
    @State private var step2Instruction: String = "Follow the main action technique for 5 repetitions."
    @State private var challengePrompt: String = "Practice 1 full round without stopping!"
    @State private var challengeHint: String = "Check your form or syntax for errors."
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Lesson Details")) {
                    TextField("Lesson Title (e.g. Swift State Basics)", text: $title)
                    
                    Picker("Skill", selection: $selectedSkillId) {
                        ForEach(SkillItem.catalog) { skill in
                            Text(skill.name).tag(skill.id)
                        }
                    }
                    
                    Stepper("Estimated Time: \(estimatedMinutes) min", value: $estimatedMinutes, in: 5...60, step: 5)
                }
                
                Section(header: Text("Step 1")) {
                    TextField("Step 1 Title", text: $step1Title)
                    TextField("Step 1 Instruction", text: $step1Instruction)
                }
                
                Section(header: Text("Step 2")) {
                    TextField("Step 2 Title", text: $step2Title)
                    TextField("Step 2 Instruction", text: $step2Instruction)
                }
                
                Section(header: Text("Peer Challenge")) {
                    TextField("Challenge Description", text: $challengePrompt)
                    TextField("Completion Hint", text: $challengeHint)
                }
                
                Section {
                    Button {
                        guard !title.isEmpty else { return }
                        let steps = [
                            LessonStep(stepNumber: 1, title: step1Title, instruction: step1Instruction, tip: "Take your time"),
                            LessonStep(stepNumber: 2, title: step2Title, instruction: step2Instruction, tip: "Consistency is key")
                        ]
                        appState.publishLesson(
                            title: title,
                            skillId: selectedSkillId,
                            estimatedMinutes: estimatedMinutes,
                            steps: steps,
                            challengePrompt: challengePrompt,
                            challengeHint: challengeHint
                        )
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Publish Lesson (+1 Credit & +75 XP) 🚀")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundStyle(PlayfulTokens.accent)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Create Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Edit Skills Sheet
struct EditSkillsSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var teachSkills: Set<String> = []
    @State private var learnSkills: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Teach Skills
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Skills I Can Teach (select at least 1)")
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 8) {
                            ForEach(SkillItem.catalog) { skill in
                                let isSel = teachSkills.contains(skill.id)
                                Button {
                                    if isSel { teachSkills.remove(skill.id) } else { teachSkills.insert(skill.id) }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: skill.icon)
                                        Text(skill.name)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(isSel ? PlayfulTokens.accent : PlayfulTokens.surfaceRaised)
                                    .foregroundStyle(isSel ? Color.white : PlayfulTokens.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Learn Skills
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Skills I Want to Learn")
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 8) {
                            ForEach(SkillItem.catalog) { skill in
                                let isSel = learnSkills.contains(skill.id)
                                Button {
                                    if isSel { learnSkills.remove(skill.id) } else { learnSkills.insert(skill.id) }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: skill.icon)
                                        Text(skill.name)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(isSel ? PlayfulTokens.purple : PlayfulTokens.surfaceRaised)
                                    .foregroundStyle(isSel ? Color.white : PlayfulTokens.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Edit Skills")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                teachSkills = Set(appState.currentUser.teachSkills)
                learnSkills = Set(appState.currentUser.learnSkills)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.currentUser.teachSkills = Array(teachSkills)
                        appState.currentUser.learnSkills = Array(learnSkills)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.accent)
                }
            }
        }
    }
}
