import SwiftUI
import FirebaseAuth

// MARK: - Home Screen (Root)
struct HomeView: View {
    @EnvironmentObject private var usageManager: UsageManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var contentStore = GeneratedContentStore()
    @State private var promptText: String = ""
    @State private var selectedKeywords: [String] = []
    @State private var selectedTab: BottomTab = .home
    @State private var navigationPath: [HomeRoute] = []
    @State private var showPaywall: Bool = false
    @State private var hasAuthenticated: Bool = false
    @State private var detailImage: GeneratedImage?
    @State private var showKeywordAlert = false
    @State private var generationErrorMessage: String?
    @State private var showGenerationError = false
    
    private let generationService = ImageGenerationService()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if selectedTab == .home {
                    NavigationStack(path: $navigationPath) {
                        HomeContentView(
                            contentStore: contentStore,
                            usageManager: usageManager,
                            promptText: $promptText,
                            selectedKeywords: $selectedKeywords,
                            detailImage: $detailImage,
                            onGenerate: {
                                if usageManager.canGenerate {
                                    navigationPath.append(.generateDetails)
                                } else {
                                    showPaywall = true
                                }
                            },
                            onRequireKeywords: { showKeywordAlert = true },
                            onTapPro: { showPaywall = true },
                            onRequireSubscription: { showPaywall = true }
                        )
                        .navigationDestination(for: HomeRoute.self) { route in
                            switch route {
                            case .generateDetails:
                                GenerateDetailsView(
                                    keywords: selectedKeywords,
                                    onGenerate: startGeneration
                                )
                                .environmentObject(contentStore)
                                .environmentObject(usageManager)
                            case .generateProgress:
                                GeneratingView()
                                    .environmentObject(usageManager)
                            case .generatedResult(let image):
                                GeneratedResultView(
                                    image: image,
                                    onClose: {
                                        navigationPath.removeAll()
                                    },
                                    onGenerateAgain: {
                                        if usageManager.canGenerate {
                                            navigationPath.removeAll()
                                            navigationPath.append(.generateDetails)
                                        } else {
                                            showPaywall = true
                                        }
                                    }
                                )
                                .environmentObject(contentStore)
                                .environmentObject(usageManager)
                            }
                        }
                        .sheet(item: $detailImage) { image in
                            ImageDetailView(
                                image: image,
                                onClose: { detailImage = nil },
                                onDelete: {
                                    contentStore.delete(image)
                                    detailImage = nil
                                }
                            )
                            .environmentObject(contentStore)
                            .environmentObject(usageManager)
                        }
                        .sheet(isPresented: $showPaywall) {
                            PaywallView()
                        }
                        .toolbar(.hidden, for: .navigationBar)
                    }
                } else {
                    SettingsView()
                        .padding(.top, 10)
                        .environmentObject(contentStore)
                        .environmentObject(usageManager)
                }
                
                // CUSTOM TAB BAR
                CustomTabBarView(selected: $selectedTab)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedTab) { newValue in
            if newValue != .home {
                navigationPath.removeAll()
            }
        }
        .task {
            await ensureAnonymousSignIn()
        }
        .alert(L10n.Home.alertMissingKeywords, isPresented: $showKeywordAlert) {
            Button(L10n.Common.ok, role: .cancel) {}
        }
        .alert(L10n.Home.alertGenerationFailed, isPresented: $showGenerationError, presenting: generationErrorMessage) { _ in
            Button(L10n.Common.ok, role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }
}

private extension HomeView {
    func startGeneration(with request: GenerationRequest) {
        guard usageManager.canGenerate else {
            showPaywall = true
            return
        }
        navigationPath.append(.generateProgress)
        
        Task {
            do {
                let uiImage = try await generationService.generateImage(
                    prompt: request.composedPrompt(),
                    negativePrompt: request.negativePrompt
                )
                
                await MainActor.run {
                    do {
                        let generated = try contentStore.saveGeneration(
                            image: uiImage,
                            title: request.displayTitle,
                            subtitle: request.summary
                        )
                        
                        Task {
                            do {
                                try await usageManager.consumeCreditIfAvailable()
                            } catch {
                                await MainActor.run {
                                    generationErrorMessage = error.localizedDescription
                                    showGenerationError = true
                                }
                            }
                        }
                        
                        if navigationPath.last == .generateProgress {
                            navigationPath.removeLast()
                        }
                        navigationPath.append(.generatedResult(generated))
                        promptText = ""
                        selectedKeywords.removeAll()
                    } catch {
                        if navigationPath.last == .generateProgress {
                            navigationPath.removeLast()
                        }
                        generationErrorMessage = error.localizedDescription
                        showGenerationError = true
                    }
                }
            } catch {
                await MainActor.run {
                    if navigationPath.last == .generateProgress {
                        navigationPath.removeLast()
                    }
                    generationErrorMessage = error.localizedDescription
                    showGenerationError = true
                }
            }
        }
    }
}

// MARK: - Home Content Wrapper
private struct HomeContentView: View {
    @ObservedObject var contentStore: GeneratedContentStore
    @ObservedObject var usageManager: UsageManager
    @Binding var promptText: String
    @Binding var selectedKeywords: [String]
    @Binding var detailImage: GeneratedImage?
    let onGenerate: () -> Void
    let onRequireKeywords: () -> Void
    let onTapPro: () -> Void
    let onRequireSubscription: () -> Void
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(
                    used: usageManager.quota.used,
                    total: usageManager.quota.total,
                    isLoading: usageManager.isLoading,
                    onTapPro: onTapPro
                )
                
                InputBoxView(text: $promptText, keywords: $selectedKeywords)
                
                GenerateButtonView(title: L10n.Common.generate, isDisabled: usageManager.isLoading) {
                    if selectedKeywords.isEmpty {
                        onRequireKeywords()
                    } else if !usageManager.canGenerate {
                        onRequireSubscription()
                    } else {
                        onGenerate()
                    }
                }
                .padding(.top, 2)
                
                // Last Generated
                Text(L10n.Home.lastGenerated)
                    .font(AppFont.nippoMedium(16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 6)
                
                if let last = contentStore.lastGenerated {
                    LastGeneratedCardView(
                        image: last,
                        onTap: { detailImage = last }
                    )
                    .padding(.bottom, 4)
                } else {
                    Text(L10n.Home.lastGeneratedEmpty)
                        .font(AppFont.nippoMedium(14))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.bottom, 4)
                }
                
                // Favorites
                Text(L10n.Home.favorites)
                    .font(AppFont.nippoMedium(16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 4)
                
                if contentStore.favorites.isEmpty {
                    Text(L10n.Home.favoritesEmpty)
                        .font(AppFont.nippoMedium(14))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.bottom, 72)
                } else {
                    FavoritesGridView(items: contentStore.favorites) { item in
                        detailImage = item
                    }
                    .padding(.bottom, 72)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

// MARK: - Header
private struct HeaderView: View {
    let used: Int
    let total: Int
    let isLoading: Bool
    let onTapPro: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(L10n.Home.headerTitle)
                .font(AppFont.nippoMedium(32))
                .fontWeight(.black)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 12)
            
            UsageCapsuleView(used: used, total: total, isLoading: isLoading)
            
            Button(action: onTapPro) {
                Image("pro_badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
        }
    }
}

private struct UsageCapsuleView: View {
    let used: Int
    let total: Int
    let isLoading: Bool
    
    private let gradient = LinearGradient(
        colors: [Color(hex: "#D7263D"), Color(hex: "#F2C94C")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        let safeTotal = max(total, 1)
        let displayText = isLoading
            ? L10n.Home.quotaLoading
            : "\(min(used, safeTotal))/\(safeTotal) \(L10n.Home.quotaLabel)"
        
        HStack(spacing: 6) {
            ZStack {
                Image(systemName: "hand.raised.fill")
                    .font(AppFont.nippoMedium(13))
                    .foregroundColor(.white.opacity(0.9))
                Image(systemName: "crown.fill")
                    .font(AppFont.nippoMedium(10))
                    .offset(y: -9)
                    .foregroundColor(.white)
            }
            .frame(width: 24, height: 24)
            
            Text(displayText)
                .font(AppFont.nippoMedium(13))
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                )
        )
        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Input Box ✅ FINAL SHADOW FIX
private struct InputBoxView: View {
    @Binding var text: String
    @Binding var keywords: [String]
    
    @State private var currentInput: String = ""
    @FocusState private var isFocused: Bool
    
    private let gradient = LinearGradient(
        colors: [Color(hex: "#D7263D"), Color(hex: "#F2C94C")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // Shadow Layer (behind and offset)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.40))
                .frame(height: 160)
                .offset(y: 7)
            
            // Main Frame
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 5)
                )
                .frame(height: 160)
            
            VStack(alignment: .leading, spacing: 10) {
                
                if !keywords.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(keywords, id: \.self) { keyword in
                                HStack(spacing: 6) {
                                    Text(keyword.capitalized)
                                        .font(AppFont.nippoMedium(13))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Button {
                                        removeKeyword(keyword)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(AppFont.nippoMedium(11))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white.opacity(0.9))
                                            .padding(.leading, 2)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(gradient)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.black.opacity(0.35), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                
                TextField(
                    keywords.isEmpty && currentInput.isEmpty ? L10n.Home.placeholder : "",
                    text: $currentInput,
                    onCommit: commitCurrentInput
                )
                .font(AppFont.nippoMedium(15))
                .foregroundColor(.black)
                .focused($isFocused)
                .submitLabel(.done)
                .onChange(of: isFocused) { newValue in
                    if newValue == false {
                        commitCurrentInput()
                    }
                }
                .onChange(of: currentInput) { newValue in
                    handleInputChange(newValue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .frame(height: 160)
        .accessibilityIdentifier("promptInputBox")
        .onAppear {
            seedFromPrompt()
        }
    }
    
    private func handleInputChange(_ value: String) {
        if value.contains(",") || value.hasSuffix(" ") {
            commitCurrentInput()
        }
    }
    
    private func commitCurrentInput() {
        let cleaned = currentInput
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: " ")
        
        let parts = cleaned
            .split(whereSeparator: { $0.isWhitespace })
            .map { String($0) }
            .filter { !$0.isEmpty }
        
        guard !parts.isEmpty else {
            currentInput = ""
            return
        }
        
        parts.forEach { part in
            if !keywords.contains(part) {
                keywords.append(part)
            }
        }
        
        currentInput = ""
        updatePromptText()
    }
    
    private func removeKeyword(_ keyword: String) {
        keywords.removeAll { $0 == keyword }
        updatePromptText()
    }
    
    private func updatePromptText() {
        text = keywords.joined(separator: ", ")
    }
    
    private func seedFromPrompt() {
        guard !text.isEmpty, keywords.isEmpty else { return }
        let initial = text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        keywords.append(contentsOf: initial)
        updatePromptText()
    }
}

// MARK: - Generate Button ✅ FINAL SHADOW FIX
private struct GenerateButtonView: View {
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Shadow layer behind
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.40))
                    .frame(height: 56)
                    .offset(y: 7)
                
                // Main button
                Image("btn_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black, lineWidth: 4)
                    )
                
                // Button text
                Text(title)
                    .font(AppFont.nippoMedium(20))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.65), radius: 0, x: 0, y: 3)
            }
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Last Generated Card ✅ FINAL SHADOW FIX
private struct LastGeneratedCardView: View {
    let image: GeneratedImage
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            
            // Shadow layer behind
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.40))
                .frame(height: 84)
                .offset(y: 7)
            
            // Main card
            HStack(spacing: 12) {
                Image(uiImage: image.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 3)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(image.title)
                        .font(AppFont.nippoMedium(16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    if let subtitle = image.subtitle {
                        Text(subtitle)
                            .font(AppFont.nippoMedium(13))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("arrow_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 4)
                    )
            )
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Favorites Grid ✅ FINAL SHADOW FIX
private struct FavoritesGridView: View {
    let items: [GeneratedImage]
    let onSelect: (GeneratedImage) -> Void

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items) { item in
                FavoriteItemView(item: item, onTap: { onSelect(item) })
            }
        }
    }
}

private struct FavoriteItemView: View {
    let item: GeneratedImage
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            
            // Shadow behind frame
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.40))
                .frame(height: 220)
                .offset(y: 7)
            
            VStack(alignment: .leading, spacing: 8) {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 3)
                    )
                
                Text(item.title)
                    .font(AppFont.nippoMedium(15))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(AppFont.nippoMedium(13))
                        .foregroundColor(.black.opacity(0.75))
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#F2C94C"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 4)
                    )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 220, alignment: .top)
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Custom Tab Bar
private enum BottomTab { case home, settings }

private enum HomeRoute: Hashable {
    case generateDetails
    case generateProgress
    case generatedResult(GeneratedImage)
}

// MARK: - Firebase Anonymous Auth
private extension HomeView {
    func ensureAnonymousSignIn() async {
        guard !hasAuthenticated else { return }
        do {
            let user: FirebaseAuth.User
            if let existing = Auth.auth().currentUser {
                user = existing
            } else {
                let result = try await Auth.auth().signInAnonymously()
                user = result.user
            }
            await usageManager.configure(for: user.uid)
            hasAuthenticated = true
        } catch {
            print("⚠️ Failed to sign in anonymously: \(error.localizedDescription)")
        }
    }
}

private extension View {
    func hideKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
}

private struct CustomTabBarView: View {
    @Binding var selected: BottomTab
    
    var body: some View {
        VStack(spacing: 0) {
            
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 0.6)
            
            HStack {
                TabButton(
                    icon: "icon_home",
                    title: L10n.Home.tabHome,
                    isSelected: selected == .home
                ) { selected = .home }
                
                Spacer()
                
                TabButton(
                    icon: "icon_settings",
                    title: L10n.Home.tabSettings,
                    isSelected: selected == .settings
                ) { selected = .settings }
            }
            .padding(.horizontal, 28)
            .frame(height: 54)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .background(Color.white)
    }
}

private struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22)
                    .opacity(isSelected ? 1.0 : 0.55)
                
                Text(title)
                    .font(AppFont.nippoMedium(11))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .black : .black.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Utility
extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 8: (a, r, g, b) = (int >> 24, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
            case 6: (a, r, g, b) = (255, int >> 16, (int >> 8) & 0xff, int & 0xff)
            default:(a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

enum Theme {
    static let background = Color(hex: "#FBEEE3")
}

enum AppFont {
    static func nippoMedium(_ size: CGFloat) -> Font {
        Font.custom("Nippo-Medium", size: size)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

