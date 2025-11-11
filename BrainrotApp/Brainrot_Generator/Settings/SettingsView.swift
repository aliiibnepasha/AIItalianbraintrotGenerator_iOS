import SwiftUI

struct SettingsView: View {
    
    @State private var selectedLanguage: String = "English"
    @State private var showLanguagePicker: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showGallery: Bool = false
    
    private let buttonTitles: [String] = [
        "Language",
        "Terms Of Service",
        "Privacy Policy",
        "Community Guidelines",
        "Creations"
    ]
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color(hex: "#FBEEE3")
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("Setting")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 18)
                        
                        PremiumBanner()
                        .onTapGesture {
                            showPaywall = true
                        }
                        
                        VStack(spacing: 14) {
                            ForEach(buttonTitles, id: \.self) { title in
                                SettingsButton(title: title,
                                               description: title == "Language" ? selectedLanguage : nil,
                                               action: buttonAction(for: title))
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
                LanguageSelectionView(selectedLanguage: $selectedLanguage)
            }
            .navigationDestination(isPresented: $showGallery) {
                GalleryView()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private func buttonAction(for title: String) -> (() -> Void)? {
        switch title {
        case "Language":
            return { showLanguagePicker = true }
        case "Creations":
            return { showGallery = true }
        default:
            return nil
        }
    }
}

// MARK: - Components

private struct PremiumBanner: View {
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
                                .fill(Color(hex: "#F2C94C"))
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 4)
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                                .offset(y: -2)
                        }
                        
                        Text("Get Premium")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.45), radius: 0, x: 0, y: 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image("shark_1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 82)
                    }
                    .padding(.horizontal, 20)
                )
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
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                            if let description {
                                Text(description)
                                    .font(.system(size: 12, weight: .medium))
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
            .background(Color(hex: "#FBEEE3"))
    }
}


