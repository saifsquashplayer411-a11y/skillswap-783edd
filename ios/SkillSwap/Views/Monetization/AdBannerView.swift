import SwiftUI

/// A clean, non-intrusive contextual ad banner designed specifically with teen privacy safeguards in mind.
/// Strictly non-personalized, labeled with clear ad disclosures, and dismissible / upgradable to remove.
struct AdBannerView: View {
    @ObservedObject var adManager = AdManager.shared
    @ObservedObject var subManager = SubscriptionManager.shared
    
    @State private var showAdPrivacySheet: Bool = false
    @State private var showProUpgradeSheet: Bool = false
    
    var body: some View {
        if adManager.shouldShowAd(isPremium: subManager.isProSubscribed) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    // Ad Transparency Badge
                    HStack(spacing: 3) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                        Text("SPONSORED")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .tracking(0.5)
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(PlayfulTokens.surfaceRaised)
                    .clipShape(Capsule())
                    
                    // Teen Safe Tag
                    HStack(spacing: 3) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 9))
                            .foregroundStyle(PlayfulTokens.positive)
                        Text("TEEN-SAFE & NON-TARGETED")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.positive)
                    }
                    
                    Spacer()
                    
                    // Privacy & Consent Settings Button
                    Button {
                        showAdPrivacySheet = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                            .padding(4)
                    }
                }
                
                HStack(spacing: 12) {
                    // Ad Icon
                    ZStack {
                        Circle()
                            .fill(PlayfulTokens.accentSoft)
                            .frame(width: 40, height: 40)
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(PlayfulTokens.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(adManager.activeAdHeadline)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.ink)
                            .lineLimit(1)
                        
                        Text("\(adManager.activeAdSponsor) • \(adManager.activeAdCategory)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Call to Action
                    Button {
                        // Safe educational link / info sheet
                        showAdPrivacySheet = true
                    } label: {
                        Text(adManager.activeAdCallToAction)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundStyle(PlayfulTokens.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(PlayfulTokens.accentSoft)
                            .clipShape(Capsule())
                    }
                }
                
                // Upgrade Prompt Micro-bar
                HStack {
                    Text("Want an ad-free learning experience?")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                    
                    Spacer()
                    
                    Button {
                        showProUpgradeSheet = true
                    } label: {
                        Text("Remove Ads with Pro ⚡️")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(PlayfulTokens.goldDeep)
                    }
                }
                .padding(.top, 2)
            }
            .padding(12)
            .background(PlayfulTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(PlayfulTokens.border, lineWidth: 1)
            }
            .sheet(isPresented: $showAdPrivacySheet) {
                AdSettingsSheet()
            }
            .sheet(isPresented: $showProUpgradeSheet) {
                SkillSwapProPaywallView()
            }
        }
    }
}
