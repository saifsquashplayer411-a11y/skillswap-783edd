import SwiftUI

/// Explains the ad privacy model, COPPA/GDPR-K under-18 protections,
/// guarantees that no sensitive personal data is collected or used for targeted ads,
/// and lets teens & guardians review advertising preferences.
struct AdSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var adManager = AdManager.shared
    @ObservedObject var subManager = SubscriptionManager.shared
    
    @State private var showProSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Teen Advertising Safeguards")) {
                    HStack(spacing: 12) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 24))
                            .foregroundStyle(PlayfulTokens.positive)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zero Sensitive Data Targeting")
                                .font(PlayfulTokens.headlineFont)
                                .foregroundStyle(PlayfulTokens.ink)
                            Text("SkillSwap strictly complies with COPPA, GDPR-K, and youth safety standards. Ads shown are contextual and educational only.")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Privacy Protections")) {
                    Toggle(isOn: $adManager.teenProtectionMode) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Teen Privacy Shield")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text("Enforces Google AdMob COPPA child-directed treatment & under-age consent restrictions.")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                        }
                    }
                    .tint(PlayfulTokens.positive)
                    .disabled(true) // Always enforced on teen app
                    
                    Toggle(isOn: $adManager.nonPersonalizedAdsOnly) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Non-Personalized Ads Only")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text("Disables cross-app tracking, location targeting, and profiling.")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                        }
                    }
                    .tint(PlayfulTokens.accent)
                    .disabled(true) // Always enforced
                    
                    Toggle(isOn: $adManager.adConsentGranted) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Allow Contextual Ads")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text("Shows occasional non-intrusive educational sponsors to support free learning.")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                        }
                    }
                    .tint(PlayfulTokens.accent)
                }
                
                Section(header: Text("Go 100% Ad-Free")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remove all ads permanently with SkillSwap Pro.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                        
                        Button {
                            showProSheet = true
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "sparkles")
                                Text("View SkillSwap Pro Perks ⚡️")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                Spacer()
                            }
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 12)
                            .background(PlayfulTokens.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Ad Privacy & Safety")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
            }
            .sheet(isPresented: $showProSheet) {
                SkillSwapProPaywallView()
            }
        }
    }
}
