import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var searchText: String = ""
    @State private var selectedCategory: SkillCategory? = nil
    @State private var selectedSegment: DiscoverSegment = .all
    
    // Navigation
    @State private var selectedUserForProfile: UserProfile? = nil
    @State private var selectedLessonForDetail: Lesson? = nil
    @State private var activeConversationForChat: Conversation? = nil
    
    enum DiscoverSegment: String, CaseIterable, Identifiable {
        case all = "All"
        case people = "Peers"
        case lessons = "Lessons"
        case challenges = "Challenges"
        
        var id: String { rawValue }
    }
    
    var filteredUsers: [UserProfile] {
        appState.sampleUsers.filter { user in
            guard !user.isCurrentUser else { return false }
            
            // Text search
            let matchesText = searchText.isEmpty ||
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.handle.localizedCaseInsensitiveContains(searchText) ||
                user.bio.localizedCaseInsensitiveContains(searchText)
            
            // Category filter
            var matchesCategory = true
            if let cat = selectedCategory {
                let userSkills = user.teachSkills + user.learnSkills
                let catSkillIds = SkillItem.catalog.filter { $0.category == cat }.map { $0.id }
                matchesCategory = !Set(userSkills).isDisjoint(with: Set(catSkillIds))
            }
            
            return matchesText && matchesCategory
        }
    }
    
    var filteredLessons: [Lesson] {
        appState.lessons.filter { lesson in
            let matchesText = searchText.isEmpty ||
                lesson.title.localizedCaseInsensitiveContains(searchText) ||
                lesson.skillName.localizedCaseInsensitiveContains(searchText) ||
                lesson.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesCat = selectedCategory == nil || lesson.category == selectedCategory
            return matchesText && matchesCat
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PlayfulTokens.ground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Search Bar
                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Category Chip Rail
                        categoryChipRail
                        
                        // Segment Switcher
                        segmentSwitcher
                            .padding(.horizontal, 20)
                        
                        // Results Content
                        resultsSection
                            .padding(.top, 4)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(PlayfulTokens.inkSecondary)
            
            TextField("Search skills, basketball, coding, guitar...", text: $searchText)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
        }
    }
    
    // MARK: - Category Chip Rail
    private var categoryChipRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" Chip
                Button {
                    selectedCategory = nil
                } label: {
                    Text("All Categories")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == nil ? PlayfulTokens.accent : PlayfulTokens.surface)
                        .foregroundStyle(selectedCategory == nil ? Color.white : PlayfulTokens.ink)
                        .clipShape(Capsule())
                        .overlay {
                            Capsule().strokeBorder(selectedCategory == nil ? PlayfulTokens.accentSecondaryDeep : PlayfulTokens.border, lineWidth: 1.5)
                        }
                }
                .buttonStyle(.plain)
                
                ForEach(SkillCategory.allCases) { cat in
                    let isSelected = selectedCategory == cat
                    Button {
                        selectedCategory = isSelected ? nil : cat
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: cat.iconName)
                                .font(.system(size: 11, weight: .bold))
                            Text(cat.rawValue)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? cat.color : PlayfulTokens.surface)
                        .foregroundStyle(isSelected ? Color.white : PlayfulTokens.ink)
                        .clipShape(Capsule())
                        .overlay {
                            Capsule().strokeBorder(isSelected ? cat.color : PlayfulTokens.border, lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Segment Switcher
    private var segmentSwitcher: some View {
        HStack(spacing: 6) {
            ForEach(DiscoverSegment.allCases) { seg in
                let isSelected = selectedSegment == seg
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedSegment = seg
                    }
                } label: {
                    Text(seg.rawValue)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? PlayfulTokens.surface : Color.clear)
                        .foregroundStyle(isSelected ? PlayfulTokens.accent : PlayfulTokens.inkSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: isSelected ? Color.black.opacity(0.06) : Color.clear, radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(PlayfulTokens.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(spacing: 16) {
            switch selectedSegment {
            case .all:
                // Peers Sub-block
                if !filteredUsers.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Featured Teen Peers")
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                            .padding(.horizontal, 20)
                        
                        ForEach(filteredUsers.prefix(2)) { user in
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
                
                // Lessons Sub-block
                if !filteredLessons.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Available Lessons")
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                            .padding(.horizontal, 20)
                        
                        ForEach(filteredLessons) { lesson in
                            LessonRowCard(lesson: lesson) {
                                selectedLessonForDetail = lesson
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
            case .people:
                if filteredUsers.isEmpty {
                    emptyState(title: "No peers found", message: "Try clearing search filters or checking another skill category.")
                } else {
                    ForEach(filteredUsers) { user in
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
                
            case .lessons:
                if filteredLessons.isEmpty {
                    emptyState(title: "No lessons found", message: "Try searching for a different skill or create one yourself from Profile!")
                } else {
                    ForEach(filteredLessons) { lesson in
                        LessonRowCard(lesson: lesson) {
                            selectedLessonForDetail = lesson
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
            case .challenges:
                ForEach(appState.challenges) { challenge in
                    challengeCard(challenge)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func challengeCard(_ challenge: ChallengeItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: challenge.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(PlayfulTokens.gold)
                    Text(challenge.isDaily ? "DAILY QUEST" : "WEEKLY GOAL")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                Spacer()
                Text("+\(challenge.xpReward) XP")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.gold)
            }
            
            Text(challenge.title)
                .font(PlayfulTokens.headlineFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            Text(challenge.description)
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.inkSecondary)
            
            HStack {
                Text("Progress: \(challenge.currentProgress)/\(challenge.targetProgress)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(challenge.isCompleted ? PlayfulTokens.positive : PlayfulTokens.inkSecondary)
                Spacer()
                if challenge.isCompleted {
                    Text("DONE ✅")
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
    
    private func emptyState(title: String, message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(PlayfulTokens.inkDisabled)
            Text(title)
                .font(PlayfulTokens.headlineFont)
                .foregroundStyle(PlayfulTokens.ink)
            Text(message)
                .font(PlayfulTokens.captionFont)
                .foregroundStyle(PlayfulTokens.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}
