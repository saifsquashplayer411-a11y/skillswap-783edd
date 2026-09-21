import SwiftUI

@main
struct SkillSwapApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainRootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
        }
    }
}

struct MainRootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                HomeFeedView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                DiscoverView()
                    .tabItem {
                        Label("Discover", systemImage: "sparkle.magnifyingglass")
                    }
                    .tag(1)
                
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(2)
                
                MyProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
                    .tag(3)
            }
            .tint(PlayfulTokens.accent)
            
            // Celebration Toast Overlay
            if let celebration = appState.activeCelebration {
                celebrationBanner(celebration)
            }
            
            // General Toast
            if let toast = appState.activeToastMessage {
                toastBanner(toast)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { !appState.hasCompletedOnboarding },
            set: { appState.hasCompletedOnboarding = !$0 }
        )) {
            OnboardingView()
                .environmentObject(appState)
        }
    }
    
    private func celebrationBanner(_ event: AppState.CelebrationEvent) -> some View {
        VStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(PlayfulTokens.goldSoft)
                        .frame(width: 44, height: 44)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(PlayfulTokens.goldDeep)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(PlayfulTokens.headlineFont)
                        .foregroundStyle(PlayfulTokens.ink)
                    Text(event.subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        appState.activeCelebration = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(PlayfulTokens.inkDisabled)
                }
            }
            .padding(14)
            .background(PlayfulTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PlayfulTokens.radiusCard, style: .continuous)
                    .strokeBorder(PlayfulTokens.gold, lineWidth: 2)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 16)
            .padding(.top, 50)
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation {
                    appState.activeCelebration = nil
                }
            }
        }
    }
    
    private func toastBanner(_ msg: String) -> some View {
        VStack {
            Spacer()
            Text(msg)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(PlayfulTokens.ink)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .padding(.bottom, 70)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    appState.activeToastMessage = nil
                }
            }
        }
    }
}
