import SwiftUI

/// Interactive help chat assistant
struct HelpChatView: View {
    @EnvironmentObject var store: SequencerStore
    @State private var messages: [HelpMessage] = []
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    @State private var showTopicBrowser: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            helpHeader
            
            // Tab bar
            tabBar
            
            if showTopicBrowser {
                // Topic browser
                topicBrowserView
            } else {
                // Chat interface
                chatInterface
            }
        }
        .frame(width: DS.Size.inspectorWidth + 60)
        .background(DS.Color.background)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(width: DS.Stroke.hairline),
            alignment: .leading
        )
        .onAppear {
            if messages.isEmpty {
                addWelcomeMessage()
            }
        }
    }
    
    // MARK: - Header
    
    private var helpHeader: some View {
        HStack {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(DS.Color.led)
            
            Text("HJÄLP & GUIDE")
                .font(DS.Font.monoS)
                .foregroundStyle(DS.Color.textSecondary)
            
            Spacer()
            
            Button(action: { store.showHelp = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DS.Color.textMuted)
            }
            .frame(width: 28, height: 28)
        }
        .padding(.horizontal, DS.Space.m)
        .padding(.vertical, DS.Space.s)
        .background(DS.Color.surface)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(height: DS.Stroke.hairline),
            alignment: .bottom
        )
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "CHAT", icon: "bubble.left.fill", isSelected: !showTopicBrowser) {
                showTopicBrowser = false
            }
            
            tabButton(title: "ÄMNEN", icon: "book.fill", isSelected: showTopicBrowser) {
                showTopicBrowser = true
            }
        }
        .background(DS.Color.surface)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(height: DS.Stroke.hairline),
            alignment: .bottom
        )
    }
    
    private func tabButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Space.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(DS.Font.monoXS)
            }
            .foregroundStyle(isSelected ? DS.Color.textPrimary : DS.Color.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Space.s)
            .background(isSelected ? DS.Color.surface2 : Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Chat Interface
    
    private var chatInterface: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: DS.Space.m) {
                        ForEach(messages) { message in
                            MessageBubble(message: message, onTopicTap: { topicID in
                                showTopic(topicID)
                            })
                            .id(message.id)
                        }
                        
                        if isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding(DS.Space.m)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Quick actions
            quickActionsBar
            
            // Input field
            chatInputField
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Space.xs) {
                quickActionChip("🚀 Komma igång") {
                    askQuestion("Hur kommer jag igång?")
                }
                quickActionChip("🎹 Stegsekvensering") {
                    askQuestion("Hur fungerar stegsekvensering?")
                }
                quickActionChip("⚡ CV-utgångar") {
                    askQuestion("Hur använder jag CV-utgångar?")
                }
                quickActionChip("📊 ADSR") {
                    askQuestion("Vad är ADSR?")
                }
                quickActionChip("⌨️ Genvägar") {
                    askQuestion("Vilka tangentbordsgenvägar finns?")
                }
            }
            .padding(.horizontal, DS.Space.m)
            .padding(.vertical, DS.Space.s)
        }
        .background(DS.Color.surface)
    }
    
    private func quickActionChip(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(DS.Font.monoXS)
                .foregroundStyle(DS.Color.textSecondary)
                .padding(.horizontal, DS.Space.s)
                .padding(.vertical, DS.Space.xs)
                .background(
                    Capsule()
                        .fill(DS.Color.surface2)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Input Field
    
    private var chatInputField: some View {
        HStack(spacing: DS.Space.s) {
            TextField("Ställ en fråga...", text: $inputText)
                .font(DS.Font.monoS)
                .textFieldStyle(.plain)
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(inputText.isEmpty ? DS.Color.textMuted : DS.Color.led)
            }
            .disabled(inputText.isEmpty)
            .buttonStyle(.plain)
        }
        .padding(DS.Space.m)
        .background(DS.Color.surface)
        .overlay(
            Rectangle()
                .fill(DS.Color.etchedLine)
                .frame(height: DS.Stroke.hairline),
            alignment: .top
        )
    }
    
    // MARK: - Topic Browser
    
    private var topicBrowserView: some View {
        ScrollView {
            VStack(spacing: DS.Space.s) {
                ForEach(HelpContent.allTopics) { topic in
                    TopicCard(topic: topic) {
                        showTopicBrowser = false
                        showTopic(topic.id)
                    }
                }
            }
            .padding(DS.Space.m)
        }
    }
    
    // MARK: - Actions
    
    private func addWelcomeMessage() {
        let welcome = HelpMessage(
            content: """
            Hej! 👋 Jag är din hjälpassistent.
            
            Jag kan hjälpa dig med:
            • Hur sekvensern fungerar
            • CV-utgångar och modulärsyntar
            • ADSR-enveloper
            • Felsökning
            
            Ställ en fråga eller välj ett snabbämne nedan!
            """,
            isUser: false
        )
        messages.append(welcome)
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = HelpMessage(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let query = inputText
        inputText = ""
        
        // Simulate typing
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTyping = false
            respondToQuery(query)
        }
    }
    
    private func askQuestion(_ question: String) {
        inputText = question
        sendMessage()
    }
    
    private func respondToQuery(_ query: String) {
        // Check for quick answer first
        if let quickAnswer = HelpContent.quickAnswer(for: query) {
            let response = HelpMessage(content: quickAnswer, isUser: false)
            messages.append(response)
            return
        }
        
        // Search for relevant topics
        let results = HelpContent.search(query)
        
        if let bestMatch = results.first {
            var response = "Här är vad jag hittade om \"\(bestMatch.title)\":\n\n"
            
            if let firstSection = bestMatch.content.first {
                response += firstSection.body
                
                if let tip = firstSection.tip {
                    response += "\n\n💡 Tips: \(tip)"
                }
            }
            
            let message = HelpMessage(
                content: response,
                isUser: false,
                relatedTopicID: bestMatch.id
            )
            messages.append(message)
            
            // Add follow-up suggestion
            if results.count > 1 {
                let followUp = HelpMessage(
                    content: "Relaterade ämnen: " + results.prefix(3).map { $0.title }.joined(separator: ", "),
                    isUser: false
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    messages.append(followUp)
                }
            }
        } else {
            let fallback = HelpMessage(
                content: """
                Jag hittade inget direkt svar på det. Prova att:
                
                • Omformulera frågan
                • Bläddra i ämneslistan
                • Fråga något mer specifikt
                
                Populära ämnen: CV-utgångar, ADSR, Stegsekvensering
                """,
                isUser: false
            )
            messages.append(fallback)
        }
    }
    
    private func showTopic(_ topicID: String) {
        guard let topic = HelpContent.allTopics.first(where: { $0.id == topicID }) else { return }
        
        var content = "📖 **\(topic.title)**\n\n"
        
        for section in topic.content {
            if let heading = section.heading {
                content += "**\(heading)**\n"
            }
            content += section.body + "\n\n"
            
            if let tip = section.tip {
                content += "💡 \(tip)\n\n"
            }
            if let warning = section.warning {
                content += "⚠️ \(warning)\n\n"
            }
        }
        
        let message = HelpMessage(content: content, isUser: false, relatedTopicID: topicID)
        messages.append(message)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: HelpMessage
    let onTopicTap: (String) -> Void
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: DS.Space.xs) {
                Text(message.content)
                    .font(DS.Font.monoS)
                    .foregroundStyle(DS.Color.textPrimary)
                    .multilineTextAlignment(message.isUser ? .trailing : .leading)
                
                // Show "Read more" for topics
                if let topicID = message.relatedTopicID {
                    Button(action: { onTopicTap(topicID) }) {
                        HStack(spacing: 4) {
                            Text("Läs mer")
                                .font(DS.Font.monoXS)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(DS.Color.led)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DS.Space.m)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m)
                    .fill(message.isUser ? DS.Color.surface2 : DS.Color.surface)
            )
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotIndex = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(DS.Color.textMuted)
                        .frame(width: 6, height: 6)
                        .opacity(dotIndex == index ? 1 : 0.3)
                }
            }
            .padding(DS.Space.m)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m)
                    .fill(DS.Color.surface)
            )
            
            Spacer()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                dotIndex = (dotIndex + 1) % 3
            }
        }
    }
}

// MARK: - Topic Card

struct TopicCard: View {
    let topic: HelpTopic
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.Space.m) {
                Image(systemName: topic.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(DS.Color.led)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.title)
                        .font(DS.Font.monoS)
                        .foregroundStyle(DS.Color.textPrimary)
                    
                    Text(topic.summary)
                        .font(DS.Font.monoXS)
                        .foregroundStyle(DS.Color.textMuted)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(DS.Color.textMuted)
            }
            .padding(DS.Space.m)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.m)
                    .fill(DS.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.m)
                            .stroke(DS.Color.etchedLine, lineWidth: DS.Stroke.hairline)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HelpChatView()
        .environmentObject(SequencerStore())
}
