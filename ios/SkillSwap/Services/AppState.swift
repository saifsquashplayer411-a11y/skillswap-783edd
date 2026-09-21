import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    // MARK: - App Flags
    @Published var hasCompletedOnboarding: Bool = true
    @Published var selectedTab: Int = 0
    
    // MARK: - User State
    @Published var currentUser: UserProfile
    @Published var streakFreezesAvailable: Int = 1
    @Published var weeklyXpGoal: Int = 200
    @Published var currentWeeklyXp: Int = 145
    
    // MARK: - App Data
    @Published var sampleUsers: [UserProfile] = []
    @Published var lessons: [Lesson] = []
    @Published var challenges: [ChallengeItem] = []
    @Published var badges: [BadgeItem] = []
    @Published var conversations: [Conversation] = []
    
    // MARK: - Toast / Celebration Event
    @Published var activeCelebration: CelebrationEvent? = nil
    @Published var activeToastMessage: String? = nil
    
    // Pro Subscription State Shortcut
    var isProUser: Bool {
        SubscriptionManager.shared.isProSubscribed
    }
    
    struct CelebrationEvent: Identifiable {
        var id = UUID()
        var title: String
        var subtitle: String
        var xpAwarded: Int
        var creditsAwarded: Int
        var streakUpdated: Int?
        var badgeAwarded: String?
    }
    
    init() {
        // Setup initial current user
        let user = UserProfile(
            id: "current_user",
            name: "Jordan Lee",
            handle: "@jordan_builds",
            bio: "Coding Swift apps & learning basketball shooting! Always down to swap skills 🚀",
            avatarColorHex: "#1CB0F6",
            avatarEmoji: "⚡️",
            level: 3,
            levelTitle: "Learner",
            xp: 420,
            streakDays: 3,
            skillCredits: 2,
            teachSkills: ["swift_coding", "video_edit"],
            learnSkills: ["basketball", "guitar", "spanish"],
            interests: ["App Design", "Basketball", "Indie Music", "Gaming"],
            isCurrentUser: true,
            badgesEarned: ["first_lesson", "perfect_match", "streak_3"],
            lessonsTaughtCount: 1,
            lessonsCompletedCount: 3,
            ratingsCount: 4,
            averageRating: 4.9
        )
        self.currentUser = user
        
        loadInitialData()
    }
    
    // MARK: - Matching Algorithm
    /// Calculates complementary match score and match reasons
    func getMatchQuality(for user: UserProfile) -> (score: Int, isPerfectMatch: Bool, teachMatch: SkillItem?, learnMatch: SkillItem?) {
        guard user.id != currentUser.id else { return (0, false, nil, nil) }
        
        // Complementary match:
        // They teach what current user wants to learn AND they want to learn what current user teaches
        let canTheyTeachMe = user.teachSkills.filter { currentUser.learnSkills.contains($0) }
        let canITeachThem = currentUser.teachSkills.filter { user.learnSkills.contains($0) }
        
        let teachMatchItem = canTheyTeachMe.first.flatMap { id in SkillItem.catalog.first(where: { $0.id == id }) }
        let learnMatchItem = canITeachThem.first.flatMap { id in SkillItem.catalog.first(where: { $0.id == id }) }
        
        let isPerfectMatch = !canTheyTeachMe.isEmpty && !canITeachThem.isEmpty
        
        var score = 0
        if isPerfectMatch {
            score += 100
        }
        score += canTheyTeachMe.count * 30
        score += canITeachThem.count * 20
        
        // Shared interests bonus
        let sharedInterests = Set(currentUser.interests).intersection(Set(user.interests))
        score += sharedInterests.count * 10
        
        return (score, isPerfectMatch, teachMatchItem, learnMatchItem)
    }
    
    var perfectMatches: [UserProfile] {
        sampleUsers.filter { user in
            let match = getMatchQuality(for: user)
            return match.isPerfectMatch
        }.sorted { (u1, u2) -> Bool in
            getMatchQuality(for: u1).score > getMatchQuality(for: u2).score
        }
    }
    
    var recommendedUsers: [UserProfile] {
        sampleUsers.filter { user in
            !user.isCurrentUser
        }.sorted { (u1, u2) -> Bool in
            getMatchQuality(for: u1).score > getMatchQuality(for: u2).score
        }
    }
    
    var recommendedLessons: [Lesson] {
        lessons.sorted { (l1, l2) -> Bool in
            let l1Interested = currentUser.learnSkills.contains(l1.skillId)
            let l2Interested = currentUser.learnSkills.contains(l2.skillId)
            if l1Interested && !l2Interested { return true }
            if !l1Interested && l2Interested { return false }
            return l1.rating > l2.rating
        }
    }
    
    // MARK: - Lesson & Gamification Actions
    func completeLesson(_ lesson: Lesson, rating: Int) {
        // 1. Mark lesson completed
        if let index = lessons.firstIndex(where: { $0.id == lesson.id }) {
            lessons[index].isCompletedByCurrentUser = true
            lessons[index].userRating = rating
            lessons[index].completedByCount += 1
        }
        
        // 2. Award XP (+50 for completion, +10 for feedback)
        let totalXp = lesson.xpReward + 10
        addXP(amount: totalXp)
        
        // 3. Update stats
        currentUser.lessonsCompletedCount += 1
        currentUser.streakDays += 1
        
        // 4. Update challenge progress
        updateChallengeProgress(type: .lesson)
        
        // 5. Check badges
        checkBadges()
        
        // 6. Trigger Celebration Event
        activeCelebration = CelebrationEvent(
            title: "Lesson Completed! 🎉",
            subtitle: "You crushed \(lesson.title). Keep the momentum going!",
            xpAwarded: totalXp,
            creditsAwarded: 0,
            streakUpdated: currentUser.streakDays,
            badgeAwarded: currentUser.streakDays == 7 ? "7-Day Streak" : nil
        )
    }
    
    func publishLesson(title: String, skillId: String, estimatedMinutes: Int, steps: [LessonStep], challengePrompt: String, challengeHint: String) {
        let skill = SkillItem.catalog.first(where: { $0.id == skillId })
        let newLesson = Lesson(
            id: UUID().uuidString,
            title: title,
            skillId: skillId,
            skillName: skill?.name ?? "Skill",
            category: skill?.category ?? .creative,
            authorId: currentUser.id,
            authorName: currentUser.name,
            authorAvatar: currentUser.avatarEmoji,
            estimatedMinutes: estimatedMinutes,
            xpReward: 50,
            creditCost: 1,
            description: "A community lesson created by \(currentUser.name)",
            steps: steps,
            challengePrompt: challengePrompt,
            challengeSolutionHint: challengeHint,
            completedByCount: 0,
            rating: 5.0,
            isUserCreated: true,
            isCompletedByCurrentUser: false
        )
        
        lessons.insert(newLesson, at: 0)
        
        // Teaching reward: +75 XP and +1 Skill Credit
        addXP(amount: 75)
        currentUser.skillCredits += 1
        currentUser.lessonsTaughtCount += 1
        
        // Unlock Teacher badge if not already
        if let idx = badges.firstIndex(where: { $0.id == "teacher" }) {
            badges[idx].isUnlocked = true
            badges[idx].unlockedDate = "Just now"
        }
        
        activeCelebration = CelebrationEvent(
            title: "Lesson Published! 🎓",
            subtitle: "You earned +1 Skill Credit and +75 XP for teaching your peers!",
            xpAwarded: 75,
            creditsAwarded: 1,
            badgeAwarded: "Teacher Badge"
        )
    }
    
    func addXP(amount: Int) {
        // SkillSwap Pro gives a 2x XP multiplier bonus
        let actualXP = isProUser ? (amount * 2) : amount
        currentUser.xp += actualXP
        currentWeeklyXp += actualXP
        
        let newLevelDef = LevelDefinition.current(for: currentUser.xp)
        if newLevelDef.level > currentUser.level {
            currentUser.level = newLevelDef.level
            currentUser.levelTitle = newLevelDef.title
        }
    }
    
    private func updateChallengeProgress(type: ChallengeType) {
        for index in challenges.indices {
            if challenges[index].isDaily && !challenges[index].isCompleted {
                challenges[index].currentProgress += 1
                if challenges[index].currentProgress >= challenges[index].targetProgress {
                    challenges[index].isCompleted = true
                    addXP(amount: challenges[index].xpReward)
                }
            }
        }
    }
    
    enum ChallengeType {
        case lesson
        case chat
        case feedback
    }
    
    func checkBadges() {
        if currentUser.streakDays >= 7 {
            if let idx = badges.firstIndex(where: { $0.id == "streak_7" }) {
                badges[idx].isUnlocked = true
                badges[idx].unlockedDate = "Today"
            }
        }
        if currentUser.skillCredits >= 5 {
            if let idx = badges.firstIndex(where: { $0.id == "credit_master" }) {
                badges[idx].isUnlocked = true
                badges[idx].unlockedDate = "Today"
            }
        }
    }
    
    // MARK: - Messaging Actions
    func startConversation(with user: UserProfile) -> Conversation {
        if let existing = conversations.first(where: { $0.partnerId == user.id }) {
            return existing
        }
        
        let match = getMatchQuality(for: user)
        let mutualTeach = match.teachMatch?.name ?? "Skills"
        let mutualLearn = match.learnMatch?.name ?? "Skills"
        
        let initialMessage = ChatMessage(
            senderId: user.id,
            senderName: user.name,
            text: "Hey \(currentUser.name)! I saw you teach \(mutualLearn). I'd love to swap for some \(mutualTeach) tips!",
            timestamp: Date().addingTimeInterval(-600),
            isFromCurrentUser: false,
            isPreApprovedStarter: true
        )
        
        let newConv = Conversation(
            id: UUID().uuidString,
            partnerId: user.id,
            partnerName: user.name,
            partnerAvatarColor: user.avatarColorHex,
            partnerAvatarEmoji: user.avatarEmoji,
            partnerLevel: user.level,
            mutualTeachSkill: mutualTeach,
            mutualLearnSkill: mutualLearn,
            messages: [initialMessage],
            isBlocked: false,
            isReported: false,
            lastUpdated: Date()
        )
        
        conversations.insert(newConv, at: 0)
        return newConv
    }
    
    func sendMessage(to conversationId: String, text: String, isStarter: Bool = false) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        
        // Teen safety filter check: block URLs / external social links
        let sanitized = sanitizeTeenMessage(text)
        
        let userMsg = ChatMessage(
            senderId: currentUser.id,
            senderName: currentUser.name,
            text: sanitized,
            timestamp: Date(),
            isFromCurrentUser: true,
            isPreApprovedStarter: isStarter
        )
        
        conversations[index].messages.append(userMsg)
        conversations[index].lastUpdated = Date()
        
        // Scripted safe auto-reply after a short delay
        let partnerName = conversations[index].partnerName
        let partnerId = conversations[index].partnerId
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self,
                  let convIdx = self.conversations.firstIndex(where: { $0.id == conversationId }),
                  !self.conversations[convIdx].isBlocked else { return }
            
            let replies = [
                "Awesome! Check out the lesson steps I published, let me know if you want to swap feedback!",
                "That sounds super fun! Let's schedule 15 minutes of practice this week.",
                "Great tip! I'm trying that out right now in my daily practice.",
                "Thanks for reaching out! Practice makes perfect — keep that streak going! 🔥"
            ]
            let replyText = replies.randomElement() ?? replies[0]
            
            let replyMsg = ChatMessage(
                senderId: partnerId,
                senderName: partnerName,
                text: replyText,
                timestamp: Date(),
                isFromCurrentUser: false,
                isPreApprovedStarter: false
            )
            self.conversations[convIdx].messages.append(replyMsg)
            self.conversations[convIdx].lastUpdated = Date()
        }
    }
    
    func blockUser(conversationId: String) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].isBlocked = true
            activeToastMessage = "User has been blocked. They cannot message you."
        }
    }
    
    func reportUser(conversationId: String, reason: String) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].isReported = true
            conversations[index].isBlocked = true
            activeToastMessage = "Report submitted. Thank you for keeping SkillSwap safe."
        }
    }
    
    private func sanitizeTeenMessage(_ input: String) -> String {
        var clean = input
        // Check for disallowed link formats
        if clean.lowercased().contains("http://") || clean.lowercased().contains("https://") || clean.lowercased().contains("www.") || clean.lowercased().contains(".com") {
            clean = "🔒 [External links are not permitted in teen chat for safety]"
        }
        return clean
    }
    
    // MARK: - Initial Seed Data
    private func loadInitialData() {
        // Badges
        self.badges = BadgeItem.allBadges
        
        // Sample Users
        self.sampleUsers = [
            UserProfile(
                id: "user_alex",
                name: "Alex Rivera",
                handle: "@alex_edits",
                bio: "Video editing wizard (Premiere & CapCut). Want to learn basketball shooting fundamentals! 🏀🎬",
                avatarColorHex: "#9B51E0",
                avatarEmoji: "🎬",
                level: 4,
                levelTitle: "Skilled",
                xp: 780,
                streakDays: 6,
                skillCredits: 4,
                teachSkills: ["video_edit", "animation"],
                learnSkills: ["basketball", "guitar"],
                interests: ["Basketball", "App Design", "Indie Music"],
                isCurrentUser: false,
                badgesEarned: ["first_lesson", "streak_3", "teacher", "credit_master"],
                lessonsTaughtCount: 3,
                lessonsCompletedCount: 7,
                ratingsCount: 12,
                averageRating: 4.95
            ),
            UserProfile(
                id: "user_sam",
                name: "Sam Chen",
                handle: "@sam_hoops",
                bio: "Varsity point guard 🏀. Can teach you catch-and-shoot mechanics! Want to learn Swift coding.",
                avatarColorHex: "#FF9600",
                avatarEmoji: "🏀",
                level: 4,
                levelTitle: "Skilled",
                xp: 820,
                streakDays: 8,
                skillCredits: 3,
                teachSkills: ["basketball", "calisthenics"],
                learnSkills: ["swift_coding", "video_edit"],
                interests: ["Basketball", "Gaming", "App Design"],
                isCurrentUser: false,
                badgesEarned: ["first_lesson", "streak_3", "streak_7", "teacher"],
                lessonsTaughtCount: 4,
                lessonsCompletedCount: 5,
                ratingsCount: 15,
                averageRating: 4.9
            ),
            UserProfile(
                id: "user_maya",
                name: "Maya Patel",
                handle: "@maya_strings",
                bio: "Acoustic & electric guitar player for 4 years 🎸. Looking for conversational Spanish partners!",
                avatarColorHex: "#FFC800",
                avatarEmoji: "🎸",
                level: 3,
                levelTitle: "Learner",
                xp: 510,
                streakDays: 4,
                skillCredits: 2,
                teachSkills: ["guitar", "beatmaking"],
                learnSkills: ["spanish", "drawing"],
                interests: ["Indie Music", "Languages", "Gaming"],
                isCurrentUser: false,
                badgesEarned: ["first_lesson", "streak_3", "teacher"],
                lessonsTaughtCount: 2,
                lessonsCompletedCount: 4,
                ratingsCount: 8,
                averageRating: 4.85
            ),
            UserProfile(
                id: "user_diego",
                name: "Diego Morales",
                handle: "@diego_habla",
                bio: "Native Spanish speaker from CDMX 🇲🇽. Happy to practice conversational Spanish for Python basics!",
                avatarColorHex: "#58CC02",
                avatarEmoji: "🌮",
                level: 5,
                levelTitle: "Mentor",
                xp: 1120,
                streakDays: 14,
                skillCredits: 6,
                teachSkills: ["spanish", "cooking"],
                learnSkills: ["python", "swift_coding"],
                interests: ["Languages", "Gaming", "App Design"],
                isCurrentUser: false,
                badgesEarned: ["first_lesson", "streak_3", "streak_7", "teacher", "helper_10"],
                lessonsTaughtCount: 8,
                lessonsCompletedCount: 9,
                ratingsCount: 22,
                averageRating: 5.0
            ),
            UserProfile(
                id: "user_chloe",
                name: "Chloe Vance",
                handle: "@chloe_sketches",
                bio: "Digital illustration in Procreate & anime character design. Need help with Algebra & essay hooks!",
                avatarColorHex: "#EB5757",
                avatarEmoji: "🎨",
                level: 3,
                levelTitle: "Learner",
                xp: 490,
                streakDays: 5,
                skillCredits: 1,
                teachSkills: ["drawing", "photography"],
                learnSkills: ["algebra", "essay_writing"],
                interests: ["Creative", "Gaming"],
                isCurrentUser: false,
                badgesEarned: ["first_lesson", "streak_3", "teacher"],
                lessonsTaughtCount: 2,
                lessonsCompletedCount: 3,
                ratingsCount: 6,
                averageRating: 4.7
            )
        ]
        
        // Lessons
        self.lessons = [
            Lesson(
                id: "lesson_bball_1",
                title: "Catch-and-Shoot Fundamentals",
                skillId: "basketball",
                skillName: "Basketball Shooting",
                category: .sports,
                authorId: "user_sam",
                authorName: "Sam Chen",
                authorAvatar: "🏀",
                estimatedMinutes: 15,
                xpReward: 50,
                creditCost: 1,
                description: "Master clean hand placement, BEEF shooting form (Balance, Eyes, Elbow, Follow-through), and consistent foot alignment.",
                steps: [
                    LessonStep(stepNumber: 1, title: "Base & Foot Alignment", instruction: "Position your shooting-side foot 2 inches forward. Keep feet shoulder-width apart with knees slightly bent for power.", tip: "Point your toes slightly toward 10 o'clock for smoother elbow alignment."),
                    LessonStep(stepNumber: 2, title: "The 90-Degree L & Pocket", instruction: "Hold the ball with your shooting hand's fingertips (not palm). Your forearm and upper arm should form a clean 90-degree angle.", tip: "There should be visible daylight under your shooting palm."),
                    LessonStep(stepNumber: 3, title: "Guide Hand Discipline", instruction: "Place non-shooting hand lightly on the side of the ball. It only stabilizes — do not push with your guide thumb upon release.", tip: "Keep your guide hand frozen like a stop sign as the ball leaves."),
                    LessonStep(stepNumber: 4, title: "High Release & Goose Neck", instruction: "Extend upward through your legs and snap your wrist high above your eyes. Hold your wrist snap until the ball hits the net.", tip: "Think of reaching your fingers into the top cookie jar.")
                ],
                challengePrompt: "Practice 15 one-handed form shots from 4 feet away. Pay close attention to holding your follow-through freeze for 1 full second after every shot.",
                challengeSolutionHint: "If the ball has clean backspin and swishes consistently from 4ft, you are ready to mark complete!",
                completedByCount: 42,
                rating: 4.9,
                isCompletedByCurrentUser: false
            ),
            Lesson(
                id: "lesson_edit_1",
                title: "TikTok & Reel Beat-Drop Syncing",
                skillId: "video_edit",
                skillName: "Video Editing",
                category: .creative,
                authorId: "user_alex",
                authorName: "Alex Rivera",
                authorAvatar: "🎬",
                estimatedMinutes: 12,
                xpReward: 50,
                creditCost: 1,
                description: "Learn how to use audio waveform markers to cut high-energy clips exactly on the bass hits for maximum engagement.",
                steps: [
                    LessonStep(stepNumber: 1, title: "Audio Waveform Inspection", instruction: "Import your trending audio track. Zoom into the timeline until you clearly see high transient spikes representing the kick drum and snare.", tip: "Use headphones for precise audio cue placement."),
                    LessonStep(stepNumber: 2, title: "Dropping Beat Markers", instruction: "Tap 'M' or the marker button while listening at normal speed. Mark the 4 main beat drops where the visual scene should transition.", tip: "Place markers slightly ahead (1 frame) to match human visual reaction speed."),
                    LessonStep(stepNumber: 3, title: "Trimming to Markers", instruction: "Snap your video clip cut points directly to the audio markers. Ensure dynamic camera motion leads into the cut.", tip: "Match cut directions: if clip 1 moves left, start clip 2 moving left."),
                    LessonStep(stepNumber: 4, title: "Micro Speed Ramps", instruction: "Add a 1.5x speed ramp on the last 5 frames before each beat drop, then 0.8x for 3 frames after to punch the impact.", tip: "Keep audio speed pitch-locked so it doesn't sound distorted.")
                ],
                challengePrompt: "Cut a 6-second sequence of 3 clips synced exactly to a 3-beat rhythm in your favorite editing app or on-device camera clips.",
                challengeSolutionHint: "Verify playback: the visual transition should feel rhythmic and seamless without any awkward pauses.",
                completedByCount: 68,
                rating: 4.95,
                isCompletedByCurrentUser: false
            ),
            Lesson(
                id: "lesson_guitar_1",
                title: "Smooth G-C-D Chord Transitions",
                skillId: "guitar",
                skillName: "Acoustic Guitar",
                category: .music,
                authorId: "user_maya",
                authorName: "Maya Patel",
                authorAvatar: "🎸",
                estimatedMinutes: 20,
                xpReward: 50,
                creditCost: 1,
                description: "The secret anchor-finger technique that unlocks hundreds of popular pop and indie songs without awkward pauses.",
                steps: [
                    LessonStep(stepNumber: 1, title: "The Ring Finger Anchor", instruction: "Place your 3rd finger on the 3rd fret of the B string. In the modern G and Cadd9 shapes, this finger never moves!", tip: "Press firmly near the fret wire, not in the middle."),
                    LessonStep(stepNumber: 2, title: "The G to Cadd9 Pivot", instruction: "Move only your index and middle fingers down one string set together as a unit. Keep the ring and pinky locked in place.", tip: "Practice moving them together in the air before landing."),
                    LessonStep(stepNumber: 3, title: "Sliding into D Major", instruction: "Pivot from Cadd9 into standard D major by lifting middle/index and anchoring ring finger in place.", tip: "Mute the low E string with your thumb or don't strum it."),
                    LessonStep(stepNumber: 4, title: "The 60 BPM Metronome Test", instruction: "Strum 4 downstrokes on each chord: G (4 beats) → Cadd9 (4 beats) → D (4 beats) → G (4 beats) without stopping the strumming hand.", tip: "The right hand never stops, even if the chord change is late.")
                ],
                challengePrompt: "Complete 1 full minute of non-stop 4/4 strumming cycling G to Cadd9 to D with clean sound on every string.",
                challengeSolutionHint: "Listen for buzzing: if a note sounds dull, adjust your finger closer to the metal fret.",
                completedByCount: 31,
                rating: 4.88,
                isCompletedByCurrentUser: false
            ),
            Lesson(
                id: "lesson_spanish_1",
                title: "Conversational Spanish Slang & Chill Phrases",
                skillId: "spanish",
                skillName: "Conversational Spanish",
                category: .languages,
                authorId: "user_diego",
                authorName: "Diego Morales",
                authorAvatar: "🌮",
                estimatedMinutes: 10,
                xpReward: 50,
                creditCost: 1,
                description: "Sound like a natural speaker among peers: learn '¿Qué onda?', '¡Qué chido!', 'No hay bronca', and real conversational rhythm.",
                steps: [
                    LessonStep(stepNumber: 1, title: "Modern Greetings", instruction: "Instead of formal '¿Cómo está usted?', use '¿Qué onda?' (What's up?) or '¿Qué tal?' with friends.", tip: "Deliver with an upbeat upward inflection on the second word."),
                    LessonStep(stepNumber: 2, title: "Expressing Excitement & Cool", instruction: "Use '¡Qué chido!' or '¡Qué genial!' when a friend shows you something cool. '¡Está padrísimo!' means it's super cool.", tip: "Say it with genuine energy!"),
                    LessonStep(stepNumber: 3, title: "Casual Agreement & Chill", instruction: "Say 'No hay bronca' (No problem / no worries) or 'De una' (Totally / let's do it).", tip: "Great response when someone asks for a quick skill swap."),
                    LessonStep(stepNumber: 4, title: "Saying See Ya Later", instruction: "Finish your conversation with 'Nos vemos al rato' (See you later on) or 'Cuídate mucho' (Take care).", tip: "Much more natural than textbook 'Adiós'.")
                ],
                challengePrompt: "Practice saying a 3-sentence casual mini-dialogue out loud combining a greeting, excitement phrase, and sign-off.",
                challengeSolutionHint: "Example: '¡Hola Sam! ¿Qué onda? Tu lección de básquet estuvo súper chida. ¡Nos vemos al rato!'",
                completedByCount: 54,
                rating: 5.0,
                isCompletedByCurrentUser: false
            )
        ]
        
        // Challenges
        self.challenges = [
            ChallengeItem(
                id: "daily_1",
                title: "Daily Skill Practice",
                description: "Complete 1 short 10-minute lesson today",
                xpReward: 50,
                currentProgress: 0,
                targetProgress: 1,
                isDaily: true,
                isCompleted: false,
                icon: "sparkles"
            ),
            ChallengeItem(
                id: "weekly_xp",
                title: "Weekly XP Target",
                description: "Earn 200 XP from lessons, teaching, and feedback",
                xpReward: 100,
                currentProgress: 145,
                targetProgress: 200,
                isDaily: false,
                isCompleted: false,
                icon: "flame.fill"
            ),
            ChallengeItem(
                id: "friend_quest_1",
                title: "Friend Quest with Sam",
                description: "Can you and Sam both complete a lesson this week?",
                xpReward: 75,
                currentProgress: 1,
                targetProgress: 2,
                isDaily: false,
                isCompleted: false,
                icon: "person.2.fill",
                friendPartnerName: "Sam Chen"
            )
        ]
        
        // Initial Seed Conversation
        let samUser = sampleUsers[1]
        let initialConv = Conversation(
            id: "conv_sam",
            partnerId: samUser.id,
            partnerName: samUser.name,
            partnerAvatarColor: samUser.avatarColorHex,
            partnerAvatarEmoji: samUser.avatarEmoji,
            partnerLevel: samUser.level,
            mutualTeachSkill: "Basketball Shooting",
            mutualLearnSkill: "Swift & iOS Coding",
            messages: [
                ChatMessage(
                    senderId: samUser.id,
                    senderName: samUser.name,
                    text: "Hey Jordan! I saw you build Swift apps on iOS. I'd love to swap tips for some basketball shooting form drills!",
                    timestamp: Date().addingTimeInterval(-3600 * 2),
                    isFromCurrentUser: false,
                    isPreApprovedStarter: true
                ),
                ChatMessage(
                    senderId: currentUser.id,
                    senderName: currentUser.name,
                    text: "Hey Sam! Definitely, let's swap. Check out my basic Swift UI overview, and I'll jump into your catch-and-shoot guide!",
                    timestamp: Date().addingTimeInterval(-3600 * 1),
                    isFromCurrentUser: true,
                    isPreApprovedStarter: true
                ),
                ChatMessage(
                    senderId: samUser.id,
                    senderName: samUser.name,
                    text: "Sounds great! Take your time with step 2 (the 90-degree shooting pocket). That's where all the consistency comes from 🔥",
                    timestamp: Date().addingTimeInterval(-1800),
                    isFromCurrentUser: false,
                    isPreApprovedStarter: false
                )
            ],
            isBlocked: false,
            isReported: false,
            lastUpdated: Date().addingTimeInterval(-1800)
        )
        self.conversations = [initialConv]
    }
}
