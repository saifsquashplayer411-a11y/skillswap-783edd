import SwiftUI
import Combine

/// Manages advertising delivery, frequency capping, teen privacy protections, and user consent.
/// Ad networks like Google AdMob require COPPA (tagForChildDirectedTreatment) / GDPR-K / Under-age-of-consent tags.
@MainActor
class AdManager: ObservableObject {
    static let shared = AdManager()
    
    // MARK: - Ad Configuration & Privacy Flags
    @Published var adsEnabled: Bool = true
    @Published var teenProtectionMode: Bool = true // COPPA & under-18 protections: zero behavioral tracking
    @Published var nonPersonalizedAdsOnly: Bool = true // Guaranteed non-targeted ads only
    @Published var adConsentGranted: Bool = true
    @Published var adFrequencyCapMinutes: Int = 10
    
    // Simulated Ad Network State
    @Published var isAdLoaded: Bool = true
    @Published var activeAdHeadline: String = "Teen Tech Hackathon 2025"
    @Published var activeAdSponsor: String = "Youth Code League"
    @Published var activeAdCategory: String = "Educational & Coding Workshops"
    @Published var activeAdCallToAction: String = "Learn More"
    
    private var lastInterstitialShownTime: Date? = nil
    
    // Sample Contextual (Non-targeted, Teen-safe) Ads Catalog
    struct TeenSafeAd: Identifiable {
        var id = UUID()
        var sponsor: String
        var headline: String
        var subtitle: String
        var iconName: String
        var ctaText: String
        var category: String
    }
    
    let contextualAdsCatalog: [TeenSafeAd] = [
        TeenSafeAd(
            sponsor: "Youth Code League",
            headline: "Join the 2025 Teen Hackathon",
            subtitle: "Build apps, win prizes, and collaborate with creators your age.",
            iconName: "laptopcomputer",
            ctaText: "Explore",
            category: "Education & Tech"
        ),
        TeenSafeAd(
            sponsor: "SkillForge Design",
            headline: "Free Digital Sketching Starter Pack",
            subtitle: "Get free brushes and color palettes for iPad creators.",
            iconName: "paintbrush.pointed.fill",
            ctaText: "Get Pack",
            category: "Creative Arts"
        ),
        TeenSafeAd(
            sponsor: "Junior Sports Foundation",
            headline: "Free Basketball Coaching Clinics",
            subtitle: "Improve footwork and jump shot form with certified coaches.",
            iconName: "basketball.fill",
            ctaText: "Find Clinics",
            category: "Sports & Fitness"
        ),
        TeenSafeAd(
            sponsor: "Young Musicians Union",
            headline: "Acoustic & Electric Guitar Tabs",
            subtitle: "1,000+ chord sheets curated for beginner to intermediate players.",
            iconName: "guitars.fill",
            ctaText: "Browse Tabs",
            category: "Music & Audio"
        )
    ]
    
    init() {
        rotateAd()
    }
    
    /// Rotates to a random non-targeted teen-safe educational/creative ad
    func rotateAd() {
        if let randomAd = contextualAdsCatalog.randomElement() {
            self.activeAdSponsor = randomAd.sponsor
            self.activeAdHeadline = randomAd.headline
            self.activeAdCategory = randomAd.category
            self.activeAdCallToAction = randomAd.ctaText
        }
    }
    
    /// Determines whether an ad should be displayed given user subscription and settings
    func shouldShowAd(isPremium: Bool) -> Bool {
        guard !isPremium else { return false }
        guard adsEnabled && adConsentGranted else { return false }
        return true
    }
    
    /// Checks frequency capping before showing an interstitial break
    func canShowInterstitialBreak(isPremium: Bool) -> Bool {
        guard shouldShowAd(isPremium: isPremium) else { return false }
        if let last = lastInterstitialShownTime {
            let elapsed = Date().timeIntervalSince(last)
            return elapsed >= Double(adFrequencyCapMinutes * 60)
        }
        return true
    }
    
    func recordInterstitialShown() {
        lastInterstitialShownTime = Date()
        rotateAd()
    }
}
