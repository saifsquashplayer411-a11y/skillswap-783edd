import SwiftUI

// MARK: - Skill Category
enum SkillCategory: String, CaseIterable, Identifiable, Codable {
    case creative = "Creative & Arts"
    case tech = "Tech & Coding"
    case languages = "Languages"
    case sports = "Sports & Fitness"
    case academics = "Academics"
    case music = "Music & Audio"
    case life = "Life Skills"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .creative: return "paintbrush.fill"
        case .tech: return "laptopcomputer"
        case .languages: return "globe.americas.fill"
        case .sports: return "basketball.fill"
        case .academics: return "character.book.closed.fill"
        case .music: return "guitars.fill"
        case .life: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .creative: return Color(red: 0.95, green: 0.38, blue: 0.58)
        case .tech: return Color(red: 0.11, green: 0.69, blue: 0.96)
        case .languages: return Color(red: 0.31, green: 0.78, blue: 0.47)
        case .sports: return Color(red: 1.00, green: 0.55, blue: 0.00)
        case .academics: return Color(red: 0.58, green: 0.37, blue: 0.95)
        case .music: return Color(red: 1.00, green: 0.78, blue: 0.00)
        case .life: return Color(red: 0.20, green: 0.70, blue: 0.85)
        }
    }
}

// MARK: - Skill Definition
struct SkillItem: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var category: SkillCategory
    var icon: String
    var sampleLessonCount: Int
    
    static let catalog: [SkillItem] = [
        // Creative
        SkillItem(id: "video_edit", name: "Video Editing", category: .creative, icon: "video.badge.plus", sampleLessonCount: 4),
        SkillItem(id: "drawing", name: "Digital Drawing", category: .creative, icon: "pencil.tip.crop.circle", sampleLessonCount: 3),
        SkillItem(id: "photography", name: "Photo Composition", category: .creative, icon: "camera.fill", sampleLessonCount: 3),
        SkillItem(id: "animation", name: "2D Animation", category: .creative, icon: "sparkles.tv", sampleLessonCount: 2),
        
        // Tech
        SkillItem(id: "swift_coding", name: "Swift & iOS", category: .tech, icon: "swift", sampleLessonCount: 5),
        SkillItem(id: "python", name: "Python Basics", category: .tech, icon: "terminal.fill", sampleLessonCount: 4),
        SkillItem(id: "web_dev", name: "HTML & CSS", category: .tech, icon: "chevron.left.forwardslash.chevron.right", sampleLessonCount: 3),
        SkillItem(id: "game_dev", name: "Roblox Game Dev", category: .tech, icon: "gamecontroller.fill", sampleLessonCount: 3),
        
        // Sports
        SkillItem(id: "basketball", name: "Basketball Shooting", category: .sports, icon: "basketball.fill", sampleLessonCount: 3),
        SkillItem(id: "skateboarding", name: "Skateboarding Basics", category: .sports, icon: "figure.skateboarding", sampleLessonCount: 2),
        SkillItem(id: "soccer", name: "Soccer Juggling", category: .sports, icon: "soccerball", sampleLessonCount: 3),
        SkillItem(id: "calisthenics", name: "Pull-ups & Core", category: .sports, icon: "figure.strengthtraining.traditional", sampleLessonCount: 2),
        
        // Languages
        SkillItem(id: "spanish", name: "Conversational Spanish", category: .languages, icon: "bubble.left.and.bubble.right.fill", sampleLessonCount: 4),
        SkillItem(id: "japanese", name: "Japanese Hiragana", category: .languages, icon: "character.bubble.fill", sampleLessonCount: 3),
        SkillItem(id: "french", name: "French Slang & Pronunciation", category: .languages, icon: "text.bubble.fill", sampleLessonCount: 2),
        SkillItem(id: "asl", name: "ASL Sign Basics", category: .languages, icon: "hand.raised.fill", sampleLessonCount: 3),
        
        // Music
        SkillItem(id: "guitar", name: "Acoustic Guitar", category: .music, icon: "guitars.fill", sampleLessonCount: 4),
        SkillItem(id: "piano", name: "Piano Chords", category: .music, icon: "pianokeys", sampleLessonCount: 3),
        SkillItem(id: "beatmaking", name: "GarageBand Beats", category: .music, icon: "waveform.path.badge.plus", sampleLessonCount: 3),
        SkillItem(id: "singing", name: "Vocal Warmups", category: .music, icon: "mic.fill", sampleLessonCount: 2),
        
        // Academics
        SkillItem(id: "algebra", name: "Algebra & Precalc", category: .academics, icon: "function", sampleLessonCount: 3),
        SkillItem(id: "chemistry", name: "Chem Reactions", category: .academics, icon: "atom", sampleLessonCount: 2),
        SkillItem(id: "essay_writing", name: "Essay Hook Writing", category: .academics, icon: "doc.text.fill", sampleLessonCount: 3),
        
        // Life Skills
        SkillItem(id: "cooking", name: "Quick 15-Min Meals", category: .life, icon: "fork.knife", sampleLessonCount: 4),
        SkillItem(id: "budgeting", name: "Teen Budgeting & Saving", category: .life, icon: "creditcard.fill", sampleLessonCount: 2),
        SkillItem(id: "public_speaking", name: "Presentation Confidence", category: .life, icon: "person.wave.2.fill", sampleLessonCount: 2)
    ]
}

// MARK: - Lesson Step & Lesson
struct LessonStep: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var stepNumber: Int
    var title: String
    var instruction: String
    var tip: String?
}

struct Lesson: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var skillId: String
    var skillName: String
    var category: SkillCategory
    var authorId: String
    var authorName: String
    var authorAvatar: String
    var estimatedMinutes: Int
    var xpReward: Int
    var creditCost: Int
    var description: String
    var steps: [LessonStep]
    var challengePrompt: String
    var challengeSolutionHint: String
    var completedByCount: Int
    var rating: Double
    var isUserCreated: Bool = false
    var isCompletedByCurrentUser: Bool = false
    var userRating: Int? = nil
}

// MARK: - User Profile
struct UserProfile: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var handle: String
    var bio: String
    var avatarColorHex: String
    var avatarEmoji: String
    var level: Int
    var levelTitle: String
    var xp: Int
    var streakDays: Int
    var skillCredits: Int
    var teachSkills: [String] // skill IDs
    var learnSkills: [String] // skill IDs
    var interests: [String]
    var isCurrentUser: Bool = false
    var badgesEarned: [String] // badge IDs
    var lessonsTaughtCount: Int
    var lessonsCompletedCount: Int
    var ratingsCount: Int
    var averageRating: Double
}

// MARK: - Gamification: Level & Badge
struct LevelDefinition {
    let level: Int
    let title: String
    let xpRequired: Int
    let nextLevelXp: Int
    let iconName: String
    
    static let ladder: [LevelDefinition] = [
        LevelDefinition(level: 1, title: "Beginner", xpRequired: 0, nextLevelXp: 150, iconName: "sparkles"),
        LevelDefinition(level: 2, title: "Explorer", xpRequired: 150, nextLevelXp: 350, iconName: "map.fill"),
        LevelDefinition(level: 3, title: "Learner", xpRequired: 350, nextLevelXp: 650, iconName: "book.fill"),
        LevelDefinition(level: 4, title: "Skilled", xpRequired: 650, nextLevelXp: 1050, iconName: "star.fill"),
        LevelDefinition(level: 5, title: "Mentor", xpRequired: 1050, nextLevelXp: 1600, iconName: "person.2.fill"),
        LevelDefinition(level: 6, title: "Expert", xpRequired: 1600, nextLevelXp: 2500, iconName: "crown.fill")
    ]
    
    static func current(for xp: Int) -> LevelDefinition {
        let sorted = ladder.sorted { $0.xpRequired < $1.xpRequired }
        var current = sorted.first!
        for item in sorted {
            if xp >= item.xpRequired {
                current = item
            }
        }
        return current
    }
}

struct BadgeItem: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var category: String
    var isUnlocked: Bool
    var unlockedDate: String?
    
    static let allBadges: [BadgeItem] = [
        BadgeItem(id: "first_lesson", title: "First Lesson", description: "Complete your first lesson", icon: "graduationcap.fill", category: "Learning", isUnlocked: true, unlockedDate: "Yesterday"),
        BadgeItem(id: "perfect_match", title: "Skill Swapper", description: "Connect with a Perfect Skill Match", icon: "arrow.triangle.swap", category: "Social", isUnlocked: true, unlockedDate: "2 days ago"),
        BadgeItem(id: "streak_3", title: "3-Day Streak", description: "Keep learning for 3 days in a row", icon: "flame.fill", category: "Streak", isUnlocked: true, unlockedDate: "Today"),
        BadgeItem(id: "streak_7", title: "7-Day Streak", description: "Reach a 7-day learning streak", icon: "flame.circle.fill", category: "Streak", isUnlocked: false),
        BadgeItem(id: "teacher", title: "Teacher", description: "Create and publish your first lesson", icon: "pencil.and.outline", category: "Teaching", isUnlocked: false),
        BadgeItem(id: "helper_10", title: "Helpful Hand", description: "Answer 10 chat questions or give feedback", icon: "hands.sparkles.fill", category: "Community", isUnlocked: false),
        BadgeItem(id: "skill_collector", title: "Skill Collector", description: "Learn 5 different skills", icon: "star.circle.fill", category: "Mastery", isUnlocked: false),
        BadgeItem(id: "credit_master", title: "Credit Savvy", description: "Earn 5 Skill Credits from teaching", icon: "diamond.fill", category: "Economy", isUnlocked: false)
    ]
}

// MARK: - Daily & Weekly Challenges
struct ChallengeItem: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var description: String
    var xpReward: Int
    var currentProgress: Int
    var targetProgress: Int
    var isDaily: Bool
    var isCompleted: Bool
    var icon: String
    var friendPartnerName: String? = nil
}

// MARK: - Messaging
struct ChatMessage: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var senderId: String
    var senderName: String
    var text: String
    var timestamp: Date
    var isFromCurrentUser: Bool
    var isPreApprovedStarter: Bool = false
}

struct Conversation: Identifiable, Codable, Hashable {
    var id: String
    var partnerId: String
    var partnerName: String
    var partnerAvatarColor: String
    var partnerAvatarEmoji: String
    var partnerLevel: Int
    var mutualTeachSkill: String
    var mutualLearnSkill: String
    var messages: [ChatMessage]
    var isBlocked: Bool = false
    var isReported: Bool = false
    var lastUpdated: Date
    
    var lastMessageText: String {
        messages.last?.text ?? "Started a skill swap conversation"
    }
}
