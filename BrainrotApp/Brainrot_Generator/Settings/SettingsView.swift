import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var contentStore: GeneratedContentStore
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.openURL) private var openURL
    
    @State private var showLanguagePicker: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showGallery: Bool = false
    
    private let settingsOptions: [SettingsOption] = [
        .init(kind: .language),
        .init(kind: .termsOfService),
        .init(kind: .privacyPolicy),
        .init(kind: .creations)
    ]
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text(L10n.Settings.title)
                            .font(AppFont.nippoMedium(32))
                            .fontWeight(.black)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 18)
                        
                        PremiumBanner()
                        .onTapGesture {
                            showPaywall = true
                        }
                        
                        VStack(spacing: 14) {
                            ForEach(settingsOptions) { option in
                                SettingsButton(
                                    title: option.title,
                                    description: option.kind == .language ? L10n.Language.displayName(for: localizationManager.languageCode) : nil,
                                    action: buttonAction(for: option.kind)
                                )
                            }
                        }
                        .padding(.top, 4)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationDestination(isPresented: $showLanguagePicker) {
                LanguageSelectionView(selectedLanguageCode: Binding(
                    get: { localizationManager.languageCode },
                    set: { localizationManager.setLanguage($0) }
                ))
                    .environmentObject(contentStore)
                    .environmentObject(localizationManager)
            }
            .navigationDestination(isPresented: $showGallery) {
                GalleryView()
                    .environmentObject(contentStore)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private func buttonAction(for kind: SettingsOption.Kind) -> (() -> Void)? {
        switch kind {
        case .language:
            return { showLanguagePicker = true }
        case .termsOfService:
            return { openURL(AppLinks.termsOfService) }
        case .privacyPolicy:
            return { openURL(AppLinks.privacyPolicy) }
        case .creations:
            return { showGallery = true }
        default:
            return nil
        }
    }
}

private struct SettingsOption: Identifiable {
    enum Kind: Hashable {
        case language
        case termsOfService
        case privacyPolicy
        case creations
    }
    
    let kind: Kind
    var id: Kind { kind }
    
    var title: String {
        switch kind {
        case .language: return L10n.Settings.language
        case .termsOfService: return L10n.Settings.termsOfService
        case .privacyPolicy: return L10n.Common.privacyPolicy
        case .creations: return L10n.Settings.creations
        }
    }
}

// MARK: - Components

private struct PremiumBanner: View {
    @State private var pulse = false
    @State private var float = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.black.opacity(0.45))
                .frame(height: 90)
                .offset(y: 4)
            
            Image("premium_banner")
                .resizable()
                .scaledToFill()
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.black, lineWidth: 4)
                )
                .overlay(
                    HStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#F2C94C"),
                                            Color(hex: "#F2994A")
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 4)
                                )
                                .frame(width: 56, height: 56)
                                .scaleEffect(pulse ? 1.08 : 0.95)
                            
                            Image(systemName: "crown.fill")
                                .font(AppFont.nippoMedium(28))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .offset(y: pulse ? -4 : -2)
                                .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 2)
                        }
                        
                        Text(L10n.Common.getPremium)
                            .font(AppFont.nippoMedium(23))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.45), radius: 0, x: 0, y: 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(pulse ? 1 : 0.92)
                        
                        Image("shark_1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 82)
                            .rotationEffect(.degrees(float ? 4 : -3))
                            .offset(y: float ? -4 : 4)
                    }
                    .padding(.horizontal, 20)
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                float = true
            }
        }
    }
}

private struct SettingsButton: View {
    let title: String
    let description: String?
    let action: (() -> Void)?
    
    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    buttonContent
                }
                .buttonStyle(.plain)
            } else {
                buttonContent
            }
        }
    }
    
    private var buttonContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.40))
                .frame(height: 60)
                .offset(y: 6)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 4)
                )
                .frame(height: 60)
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(AppFont.nippoMedium(17))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            if let description {
                                Text(description)
                                    .font(AppFont.nippoMedium(12))
                                    .foregroundColor(.black.opacity(0.55))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 22)
                )
        }
    }
    
    init(title: String, description: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.action = action
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .background(Theme.background)
            .environmentObject(GeneratedContentStore())
            .environmentObject(LocalizationManager.shared)
            .environmentObject(PurchaseManager.shared)
            .environmentObject(UsageManager())
    }
}


