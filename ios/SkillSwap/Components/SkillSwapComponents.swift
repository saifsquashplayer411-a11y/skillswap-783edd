import SwiftUI

// MARK: - User Avatar View
struct UserAvatarView: View {
    let emoji: String
    let colorHex: String
    var size: CGFloat = 56
    var showBorder: Bool = true
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: colorHex) ?? PlayfulTokens.accent)
                .frame(width: size, height: size)
            
            Text(emoji)
                .font(.system(size: size * 0.52))
        }
        .overlay {
            if showBorder {
                Circle()
                    .strokeBorder(Color.white, lineWidth: size > 40 ? 3 : 2)
                    .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
            }
        }
    }
}

// MARK: - Skill Tag Chip
struct SkillChip: View {
    let skill: SkillItem
    var isSelected: Bool = false
    var showCategoryIcon: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 6) {
                if showCategoryIcon {
                    Image(systemName: skill.icon)
                        .font(.system(size: 13, weight: .bold))
                }
                Text(skill.name)
                    .font(PlayfulTokens.captionFont)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? PlayfulTokens.accent : PlayfulTokens.surfaceRaised)
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

// MARK: - Perfect Match Badge Pill
struct PerfectMatchPill: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .heavy))
            Text("PERFECT MATCH")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(0.6)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(PlayfulTokens.gold)
        .foregroundStyle(PlayfulTokens.ink)
        .clipShape(Capsule())
    }
}

// MARK: - Match Card (Duolingo Tactile Style)
struct PeerMatchCard: View {
    let user: UserProfile
    let matchQuality: (score: Int, isPerfectMatch: Bool, teachMatch: SkillItem?, learnMatch: SkillItem?)
    var onConnect: () -> Void
    var onTapProfile: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: Avatar, Names, Level Pill
            HStack(alignment: .top, spacing: 12) {
                Button(action: onTapProfile) {
                    UserAvatarView(emoji: user.avatarEmoji, colorHex: user.avatarColorHex, size: 52)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(user.name)
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                        
                        if matchQuality.isPerfectMatch {
                            PerfectMatchPill()
                        }
                    }
                    
                    Text(user.handle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                }
                
                Spacer()
                
                // Level Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(PlayfulTokens.gold)
                    Text("Lvl \(user.level)")
                        .font(PlayfulTokens.captionFont)
                        .foregroundStyle(PlayfulTokens.ink)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PlayfulTokens.surfaceRaised)
                .clipShape(Capsule())
            }
            
            // Skill Swap Comparison Banner
            HStack(spacing: 0) {
                // Left: They Teach
                VStack(alignment: .leading, spacing: 4) {
                    Text("THEY TEACH")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: matchQuality.teachMatch?.icon ?? "graduationcap.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(PlayfulTokens.accent)
                        Text(matchQuality.teachMatch?.name ?? "Skills")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.ink)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Swap Icon Divider
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(PlayfulTokens.gold)
                    .padding(.horizontal, 10)
                
                // Right: You Teach
                VStack(alignment: .trailing, spacing: 4) {
                    Text("YOU TEACH")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                    
                    HStack(spacing: 4) {
                        Text(matchQuality.learnMatch?.name ?? "Skills")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.ink)
                            .lineLimit(1)
                        Image(systemName: matchQuality.learnMatch?.icon ?? "sparkles")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(PlayfulTokens.purple)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(10)
            .background(matchQuality.isPerfectMatch ? PlayfulTokens.goldSoft.opacity(0.5) : PlayfulTokens.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
            
            // Bio Preview
            Text(user.bio)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(PlayfulTokens.ink)
                .lineLimit(2)
            
            // Connect Button (Tactile 4pt Bottom Rim Style)
            HStack(spacing: 10) {
                Button(action: onTapProfile) {
                    Text("View Profile")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(PlayfulTokens.surfaceRaised)
                        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                }
                .buttonStyle(.plain)
                
                Button(action: onConnect) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text("Connect & Swap")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(PlayfulTokens.accent)
                    .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                    .overlay(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                            .stroke(PlayfulTokens.accentSecondaryDeep, lineWidth: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(PlayfulTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                .strokeBorder(matchQuality.isPerfectMatch ? PlayfulTokens.gold : PlayfulTokens.border, lineWidth: matchQuality.isPerfectMatch ? 2 : 1.5)
        }
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Lesson Row Card
struct LessonRowCard: View {
    let lesson: Lesson
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Skill Category Box
                ZStack {
                    RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                        .fill(lesson.category.color.opacity(0.15))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: lesson.category.iconName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(lesson.category.color)
                }
                
                // Lesson Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(lesson.skillName.uppercased())
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .tracking(0.6)
                            .foregroundStyle(lesson.category.color)
                        
                        if lesson.isCompletedByCurrentUser {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10, weight: .bold))
                                Text("DONE")
                                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(PlayfulTokens.positive.opacity(0.2))
                            .foregroundStyle(PlayfulTokens.positive)
                            .clipShape(Capsule())
                        }
                    }
                    
                    Text(lesson.title)
                        .font(PlayfulTokens.headlineFont)
                        .foregroundStyle(PlayfulTokens.ink)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        Label("\(lesson.estimatedMinutes) min", systemImage: "clock.fill")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                        
                        Label("+\(lesson.xpReward) XP", systemImage: "bolt.fill")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.gold)
                        
                        HStack(spacing: 3) {
                            Text(lesson.authorAvatar)
                            Text(lesson.authorName)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(PlayfulTokens.inkDisabled)
            }
            .padding(14)
            .background(PlayfulTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                    .strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
            }
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Safety Banner (Teen Friendly Guardrails)
struct SafetyBannerView: View {
    var onLearnMore: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(PlayfulTokens.accent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Safe & Moderated Teen Space")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(PlayfulTokens.ink)
                Text("Pre-approved icebreakers • No external links • Instant report & block")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(PlayfulTokens.accentSoft.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                .strokeBorder(PlayfulTokens.accent.opacity(0.3), lineWidth: 1.5)
        }
    }
}

// MARK: - Helper Extension for Color Hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        let r, g, b, a: Double
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
