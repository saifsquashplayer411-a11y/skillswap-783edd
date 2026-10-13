import SwiftUI

/// Premium Upgrade Screen for SkillSwap Pro:
/// Removes all ads, awards 2x XP boost, unlimited streak freezes, and unlocks exclusive mentor perks.
struct SkillSwapProPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var subManager = SubscriptionManager.shared
    @EnvironmentObject var appState: AppState
    
    @State private var selectedPlan: String = "monthly" // "monthly" or "annual"
    @State private var isProcessing: Bool = false
    @State private var showSuccessAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                PlayfulTokens.ground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Hero Badge
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [PlayfulTokens.gold, PlayfulTokens.goldDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: PlayfulTokens.gold.opacity(0.4), radius: 12, x: 0, y: 6)
                                
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 40, weight: .heavy))
                                    .foregroundStyle(Color.white)
                            }
                            
                            Text("SkillSwap PRO")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundStyle(PlayfulTokens.ink)
                            
                            Text("Elevate your learning journey with zero ads, double XP, and unlimited streak protection.")
                                .font(PlayfulTokens.bodyFont)
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 16)
                        
                        // Current Status Card if already subscribed
                        if subManager.isProSubscribed {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(PlayfulTokens.positive)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("SkillSwap Pro Active")
                                        .font(PlayfulTokens.headlineFont)
                                        .foregroundStyle(PlayfulTokens.ink)
                                    Text("All ads removed • 2x XP boost active")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundStyle(PlayfulTokens.inkSecondary)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(PlayfulTokens.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(PlayfulTokens.positive, lineWidth: 1.5)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Pro Benefits List
                        VStack(spacing: 12) {
                            ForEach(subManager.proBenefits) { benefit in
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(PlayfulTokens.accentSoft)
                                            .frame(width: 42, height: 42)
                                        Image(systemName: benefit.icon)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundStyle(PlayfulTokens.accent)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(benefit.title)
                                            .font(PlayfulTokens.headlineFont)
                                            .foregroundStyle(PlayfulTokens.ink)
                                        Text(benefit.description)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(PlayfulTokens.inkSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(PlayfulTokens.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(PlayfulTokens.border, lineWidth: 1)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Plan Selection Cards
                        if !subManager.isProSubscribed {
                            VStack(spacing: 10) {
                                // Annual Plan (Best Value)
                                Button {
                                    selectedPlan = "annual"
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text("Annual Plan")
                                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                                    .foregroundStyle(PlayfulTokens.ink)
                                                
                                                Text("SAVE 45%")
                                                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                                                    .foregroundStyle(Color.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(PlayfulTokens.positive)
                                                    .clipShape(Capsule())
                                            }
                                            Text("$19.99/year ($1.66/month) • 7-day free trial")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundStyle(PlayfulTokens.inkSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedPlan == "annual" ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(selectedPlan == "annual" ? PlayfulTokens.accent : PlayfulTokens.inkDisabled)
                                    }
                                    .padding(16)
                                    .background(PlayfulTokens.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(selectedPlan == "annual" ? PlayfulTokens.accent : PlayfulTokens.border, lineWidth: selectedPlan == "annual" ? 2 : 1)
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                // Monthly Plan
                                Button {
                                    selectedPlan = "monthly"
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Monthly Plan")
                                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                                .foregroundStyle(PlayfulTokens.ink)
                                            Text("$2.99/month • Cancel anytime")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundStyle(PlayfulTokens.inkSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedPlan == "monthly" ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(selectedPlan == "monthly" ? PlayfulTokens.accent : PlayfulTokens.inkDisabled)
                                    }
                                    .padding(16)
                                    .background(PlayfulTokens.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(selectedPlan == "monthly" ? PlayfulTokens.accent : PlayfulTokens.border, lineWidth: selectedPlan == "monthly" ? 2 : 1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            
                            // Upgrade CTA Button
                            Button {
                                upgradeNow()
                            } label: {
                                HStack(spacing: 8) {
                                    if isProcessing {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 16, weight: .heavy))
                                        Text(selectedPlan == "annual" ? "Start 7-Day Free Trial" : "Upgrade to Pro — $2.99/mo")
                                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                                    }
                                }
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(LinearGradient(colors: [PlayfulTokens.accent, PlayfulTokens.accentSecondary], startPoint: .leading, endPoint: .trailing))
                                .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous))
                                .shadow(color: PlayfulTokens.accent.opacity(0.35), radius: 8, x: 0, y: 4)
                            }
                            .disabled(isProcessing)
                            .padding(.horizontal, 20)
                            
                            // Restore & Legal Terms
                            HStack(spacing: 16) {
                                Button("Restore Purchases") {
                                    subManager.restorePurchases()
                                    appState.activeToastMessage = "Purchases Restored! Pro active."
                                    dismiss()
                                }
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                                
                                Text("•")
                                    .foregroundStyle(PlayfulTokens.inkDisabled)
                                
                                Button("Terms & Safety") {
                                    // Open terms
                                }
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(PlayfulTokens.inkSecondary)
                            }
                            .padding(.bottom, 24)
                        } else {
                            // Subscribed management
                            Button("Manage Subscription") {
                                dismiss()
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.accent)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("SkillSwap Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func upgradeNow() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isProcessing = false
            let planDesc = selectedPlan == "annual" ? "SkillSwap Pro Annual" : "SkillSwap Pro Monthly"
            subManager.upgradeToPro(tier: planDesc)
            appState.currentUser.streakDays += 1
            appState.streakFreezesAvailable += 5
            appState.activeToastMessage = "Welcome to SkillSwap Pro! ⚡️ Ads removed."
            dismiss()
        }
    }
}
