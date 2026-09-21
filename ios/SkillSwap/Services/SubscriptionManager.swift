import SwiftUI
import Combine

/// Manages SkillSwap Pro premium state, Superwall placements registration,
/// and premium perks (ad removal, 2x XP boost, unlimited streak freezes, custom badge flair).
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isProSubscribed: Bool = false
    @Published var subscriptionTier: String = "Free"
    @Published var renewalDate: Date? = nil
    
    // Pro Tier Benefits
    let proBenefits: [ProBenefit] = [
        ProBenefit(icon: "shield.slash.fill", title: "100% Ad-Free Experience", description: "Enjoy uninterrupted learning and swapping with zero banner or interstitial ads."),
        ProBenefit(icon: "bolt.badge.clock.fill", title: "2x XP Boost", description: "Earn double XP on all completed lessons, daily challenges, and teaching sessions."),
        ProBenefit(icon: "snowflake", title: "Unlimited Streak Freezes", description: "Never lose your hard-earned learning streak when life gets busy."),
        ProBenefit(icon: "sparkles.rectangle.stack.fill", title: "Pro Mentor Badge & Flair", description: "Exclusive profile highlight, custom avatar aura, and priority match recommendations."),
        ProBenefit(icon: "arrow.triangle.2.circlepath.circle.fill", title: "Unlimited Skill Credits", description: "Never run out of credits to start any lesson anytime.")
    ]
    
    struct ProBenefit: Identifiable {
        var id = UUID()
        var icon: String
        var title: String
        var description: String
    }
    
    init() {
        // Default starts as free
    }
    
    /// Registers placement with Superwall / handles paywall trigger
    func triggerPaywall(placement: String, onDismiss: (() -> Void)? = nil) {
        // Superwall placement registration
        // In local/offline mode, we provide direct UI fallback
        onDismiss?()
    }
    
    /// Upgrades the user locally to SkillSwap Pro
    func upgradeToPro(tier: String = "SkillSwap Pro Monthly ($2.99/mo)") {
        self.isProSubscribed = true
        self.subscriptionTier = tier
        self.renewalDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
    }
    
    /// Restores prior purchase
    func restorePurchases() {
        // Mock restore verification
        self.isProSubscribed = true
        self.subscriptionTier = "SkillSwap Pro (Restored)"
        self.renewalDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
    }
    
    /// Cancels Pro subscription
    func cancelSubscription() {
        self.isProSubscribed = false
        self.subscriptionTier = "Free"
        self.renewalDate = nil
    }
}
