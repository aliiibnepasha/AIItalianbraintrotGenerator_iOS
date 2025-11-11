import SwiftUI

// MARK: - Home Screen (Root)
struct HomeView: View {
    @State private var promptText: String = ""
    @State private var selectedKeywords: [String] = []
    @State private var selectedTab: BottomTab = .home
    @State private var navigationPath: [HomeRoute] = []
    @State private var showPaywall: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color(hex: "#FBEEE3")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if selectedTab == .home {
                    NavigationStack(path: $navigationPath) {
                        HomeContentView(
                            promptText: $promptText,
                            selectedKeywords: $selectedKeywords,
                            onGenerate: { navigationPath.append(.generateDetails) },
                            onTapPro: { showPaywall = true }
                        )
                        .navigationDestination(for: HomeRoute.self) { route in
                            switch route {
                            case .generateDetails:
                                GenerateDetailsView(onGenerate: {
                                    navigationPath.append(.generateProgress)
                                })
                            case .generateProgress:
                                GeneratingView(onFinished: {
                                    navigationPath.append(.generatedResult)
                                })
                            case .generatedResult:
                                GeneratedResultView(
                                    onGenerateAgain: {
                                        navigationPath.removeAll()
                                        navigationPath.append(.generateDetails)
                                    }
                                )
                            }
                        }
                        .sheet(isPresented: $showPaywall) {
                            PaywallView()
                        }
                        .toolbar(.hidden, for: .navigationBar)
                    }
                } else {
                    SettingsView()
                        .padding(.top, 10)
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
    }
}

// MARK: - Home Content Wrapper
private struct HomeContentView: View {
    @Binding var promptText: String
    @Binding var selectedKeywords: [String]
    let onGenerate: () -> Void
    let onTapPro: () -> Void
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(onTapPro: onTapPro)
                
                InputBoxView(text: $promptText, keywords: $selectedKeywords)
                
                GenerateButtonView(title: "Generate", action: onGenerate)
                    .padding(.top, 2)
                
                // Last Generated
                Text("Last Generated")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 6)
                
                LastGeneratedCardView(
                    imageName: "sample_thumb_1",
                    title: "Tur Tur Tur Sahur",
                    subtitle: "Neo-pop vigilante"
                )
                .padding(.bottom, 4)
                
                // Favorites
                Text("Favorites")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 4)
                
                FavoritesGridView()
                    .padding(.bottom, 72)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }
}

// MARK: - Header
private struct HeaderView: View {
    let onTapPro: () -> Void
    var body: some View {
        HStack(alignment: .top) {
            Text("Who will you\nbe today?")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onTapPro) {
                Image("pro_badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
        }
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
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Button {
                                        removeKeyword(keyword)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 11, weight: .bold))
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
                    keywords.isEmpty && currentInput.isEmpty ? "Enter your character name here" : "",
                    text: $currentInput,
                    onCommit: commitCurrentInput
                )
                .font(.system(size: 15))
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
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.65), radius: 0, x: 0, y: 3)
            }
            .frame(height: 56)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Last Generated Card ✅ FINAL SHADOW FIX
private struct LastGeneratedCardView: View {
    var imageName: String
    var title: String
    var subtitle: String
    
    var body: some View {
        ZStack {
            
            // Shadow layer behind
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.40))
                .frame(height: 84)
                .offset(y: 7)
            
            // Main card
            HStack(spacing: 12) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 3)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
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
    }
}

// MARK: - Favorites Grid ✅ FINAL SHADOW FIX
private struct FavoritesGridView: View {
    private let items: [FavoriteItem] = [
        .init(image: "sample_thumb_1", title: "Tur Tur Tur Sahur", subtitle: "Neo-pop vigilante"),
        .init(image: "sample_thumb_2", title: "Tur Tur Tur Sahur", subtitle: "Neo-pop vigilante"),
        .init(image: "sample_thumb_3", title: "Tur Tur Tur Sahur", subtitle: "Neo-pop vigilante"),
        .init(image: "sample_thumb_4", title: "Tur Tur Tur Sahur", subtitle: "Neo-pop vigilante"),
    ]
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items) { item in
                FavoriteItemView(item: item)
            }
        }
    }
}

private struct FavoriteItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let subtitle: String
}

private struct FavoriteItemView: View {
    let item: FavoriteItem
    
    var body: some View {
        ZStack {
            
            // Shadow behind frame
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.40))
                .frame(height: 185)  // approx total
                .offset(y: 7)
            
            VStack(alignment: .leading, spacing: 8) {
                Image(item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 3)
                    )
                
                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(item.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.75))
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#F2C94C"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 4)
                    )
            )
        }
    }
}

// MARK: - Custom Tab Bar
private enum BottomTab { case home, settings }

private enum HomeRoute: Hashable {
    case generateDetails
    case generateProgress
    case generatedResult
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
                    title: "Home",
                    isSelected: selected == .home
                ) { selected = .home }
                
                Spacer()
                
                TabButton(
                    icon: "icon_settings",
                    title: "Setting",
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
                    .font(.system(size: 11, weight: .semibold))
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

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

