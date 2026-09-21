import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedConversation: Conversation? = nil
    
    var activeConversations: [Conversation] {
        appState.conversations.filter { !$0.isBlocked }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PlayfulTokens.ground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Safety Notice Banner
                        SafetyBannerView()
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Conversations List
                        if activeConversations.isEmpty {
                            emptyMessagesView
                        } else {
                            VStack(spacing: 10) {
                                ForEach(activeConversations) { conv in
                                    conversationRow(conv)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedConversation) { conv in
                ChatDetailView(conversation: conv)
            }
        }
    }
    
    private func conversationRow(_ conv: Conversation) -> some View {
        Button {
            selectedConversation = conv
        } label: {
            HStack(spacing: 14) {
                UserAvatarView(emoji: conv.partnerAvatarEmoji, colorHex: conv.partnerAvatarColor, size: 52)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(conv.partnerName)
                            .font(PlayfulTokens.headlineFont)
                            .foregroundStyle(PlayfulTokens.ink)
                        
                        Spacer()
                        
                        Text(timeString(from: conv.lastUpdated))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.inkSecondary)
                    }
                    
                    // Skill Swap Context Subtitle
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(PlayfulTokens.accent)
                        Text("\(conv.mutualTeachSkill) ↔ \(conv.mutualLearnSkill)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.accent)
                    }
                    
                    Text(conv.lastMessageText)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(PlayfulTokens.inkSecondary)
                        .lineLimit(1)
                }
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
    
    private var emptyMessagesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundStyle(PlayfulTokens.inkDisabled)
                .padding(.top, 40)
            
            Text("No Active Chats")
                .font(PlayfulTokens.titleFont)
                .foregroundStyle(PlayfulTokens.ink)
            
            Text("Find a Perfect Skill Match on the Home or Discover tab and hit 'Connect & Swap' to start practicing!")
                .font(PlayfulTokens.bodyFont)
                .foregroundStyle(PlayfulTokens.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Chat Detail View (Safe Moderated Chat)
struct ChatDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let conversation: Conversation
    
    @State private var messageText: String = ""
    @State private var showReportActionSheet: Bool = false
    @State private var showSafetyGuidelinesSheet: Bool = false
    
    let conversationStarters: [String] = [
        "Hey! Want to practice a quick 10-min skill swap?",
        "I just checked out your lesson, it was super helpful!",
        "Any pro tips for a beginner on this step?",
        "When is your favorite time of the day to practice?"
    ]
    
    var liveConv: Conversation {
        appState.conversations.first(where: { $0.id == conversation.id }) ?? conversation
    }
    
    var body: some View {
        ZStack {
            PlayfulTokens.ground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Safety Pinned Bar
                safetyInfoBar
                
                // Messages Scroll
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            // Match Intro Pill
                            matchIntroBanner
                                .padding(.top, 8)
                            
                            ForEach(liveConv.messages) { message in
                                messageBubble(message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: liveConv.messages.count) { _ in
                        if let last = liveConv.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Quick Starters Carousel
                quickStartersRail
                
                // Input Bar (Filtered / Safe)
                chatInputBar
            }
        }
        .navigationTitle(conversation.partnerName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        appState.blockUser(conversationId: conversation.id)
                        dismiss()
                    } label: {
                        Label("Block User", systemImage: "hand.raised.fill")
                    }
                    
                    Button(role: .destructive) {
                        showReportActionSheet = true
                    } label: {
                        Label("Report Conversation", systemImage: "flag.fill")
                    }
                    
                    Button {
                        showSafetyGuidelinesSheet = true
                    } label: {
                        Label("Teen Safety Rules", systemImage: "shield.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(PlayfulTokens.ink)
                }
            }
        }
        .confirmationDialog("Report Safety Concern", isPresented: $showReportActionSheet, titleVisibility: .visible) {
            Button("Inappropriate language", role: .destructive) {
                appState.reportUser(conversationId: conversation.id, reason: "Inappropriate language")
                dismiss()
            }
            Button("Sharing off-platform links", role: .destructive) {
                appState.reportUser(conversationId: conversation.id, reason: "External links")
                dismiss()
            }
            Button("Spam or unhelpful", role: .destructive) {
                appState.reportUser(conversationId: conversation.id, reason: "Spam")
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showSafetyGuidelinesSheet) {
            teenSafetySheet
        }
    }
    
    // MARK: - Safety Info Bar
    private var safetyInfoBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(PlayfulTokens.accent)
            Text("Moderated teen chat • External links & images are restricted")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(PlayfulTokens.ink)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(PlayfulTokens.accentSoft.opacity(0.8))
    }
    
    // MARK: - Match Intro Banner
    private var matchIntroBanner: some View {
        VStack(spacing: 6) {
            Text("Skill Swap Matched 🎉")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(PlayfulTokens.ink)
            
            Text("Swapping \(conversation.mutualTeachSkill) with \(conversation.mutualLearnSkill)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(PlayfulTokens.inkSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(PlayfulTokens.surfaceRaised)
        .clipShape(Capsule())
    }
    
    // MARK: - Message Bubble
    private func messageBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.isFromCurrentUser { Spacer() }
            
            VStack(alignment: msg.isFromCurrentUser ? .trailing : .leading, spacing: 3) {
                Text(msg.text)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(msg.isFromCurrentUser ? Color.white : PlayfulTokens.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(msg.isFromCurrentUser ? PlayfulTokens.accent : PlayfulTokens.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        if !msg.isFromCurrentUser {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(PlayfulTokens.border, lineWidth: 1)
                        }
                    }
                
                Text(timeFormatted(msg.timestamp))
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(PlayfulTokens.inkDisabled)
                    .padding(.horizontal, 4)
            }
            
            if !msg.isFromCurrentUser { Spacer() }
        }
    }
    
    // MARK: - Quick Starters Rail
    private var quickStartersRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(conversationStarters, id: \.self) { starter in
                    Button {
                        appState.sendMessage(to: conversation.id, text: starter, isStarter: true)
                    } label: {
                        Text(starter)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(PlayfulTokens.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(PlayfulTokens.surface)
                            .clipShape(Capsule())
                            .overlay {
                                Capsule().strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(PlayfulTokens.surfaceRaised)
    }
    
    // MARK: - Chat Input Bar
    private var chatInputBar: some View {
        HStack(spacing: 10) {
            TextField("Type a friendly message...", text: $messageText)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(PlayfulTokens.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule().strokeBorder(PlayfulTokens.border, lineWidth: 1.5)
                }
            
            Button {
                guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                appState.sendMessage(to: conversation.id, text: messageText)
                messageText = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(messageText.isEmpty ? PlayfulTokens.inkDisabled : PlayfulTokens.accent)
            }
            .disabled(messageText.isEmpty)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
    
    private var teenSafetySheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                        .font(.system(size: 24))
                        .foregroundStyle(PlayfulTokens.accent)
                    Text("SkillSwap Safety Rules")
                        .font(PlayfulTokens.titleFont)
                        .foregroundStyle(PlayfulTokens.ink)
                }
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    safetyTipRow(icon: "lock.fill", title: "Keep Private Info Private", desc: "Never share home addresses, phone numbers, passwords, or personal social media handles.")
                    safetyTipRow(icon: "bubble.left.and.exclamationmark.bubble.right.fill", title: "Skill-Focused Conversations", desc: "Keep chats centered around learning, practicing, and exchanging tips.")
                    safetyTipRow(icon: "hand.raised.fill", title: "1-Tap Report & Block", desc: "You have complete control to block or report anyone who makes you uncomfortable.")
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Safety Guidelines")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func safetyTipRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(PlayfulTokens.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PlayfulTokens.headlineFont)
                    .foregroundStyle(PlayfulTokens.ink)
                Text(desc)
                    .font(PlayfulTokens.bodyFont)
                    .foregroundStyle(PlayfulTokens.inkSecondary)
            }
        }
        .padding(12)
        .background(PlayfulTokens.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func timeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
