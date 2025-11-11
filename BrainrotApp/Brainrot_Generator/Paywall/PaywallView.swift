import SwiftUI

struct PaywallView: View {
    
    // MARK: - State
    @State private var enableFreeTrial: Bool = false
    @State private var selectedPlan: Plan = .monthly
    
    // MARK: - Constants
    private let backgroundColor = Color(hex: "#E5F974")
    private let characterImageName = "paywall_hero"
    @State private var animateHero: Bool = false
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    ZStack(alignment: .bottom) {
                        heroSection
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                        
                        Text("Unlock Brainrot\nPremium")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 4)
                            .padding(.bottom, 80)
                    }
                    .padding(.bottom, -30)

                    benefitsList
                        .padding(.top, -70)
                    
                    trialToggle
                    
                    planOptions
                    
                    subscribeButton
                    
                    legalFooter
                    
                    footnotes
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            animateHero = true
        }
    }
    
    // MARK: - Hero
    
    private var heroSection: some View {
        Image(characterImageName)
            .resizable()
            .scaledToFit()
            .frame(height: 430)
            .scaleEffect(animateHero ? 1.0 : 0.0)
            .opacity(animateHero ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.05), value: animateHero)
    }
    
    // MARK: - Benefits
    
    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(PlanBenefit.allCases, id: \.self) { benefit in
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.black, Color.white)
                    
                    Text(benefit.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Free Trial Toggle
    
    private var trialToggle: some View {
        HStack(spacing: 16) {
            Text("Not sure yet? Enable free trial")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { enableFreeTrial.toggle() }) {
                ZStack(alignment: enableFreeTrial ? .trailing : .leading) {
                    Capsule()
                        .fill(enableFreeTrial ? Color(hex: "#D7263D") : Color(hex: "#B0B0B0"))
                        .overlay(
                            Capsule()
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .frame(width: 78, height: 36)
                    
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .frame(width: 32, height: 32)
                        .padding(2)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: enableFreeTrial)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.black, lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 6)
        )
    }
    
    // MARK: - Plan Options
    
    private var planOptions: some View {
        VStack(spacing: 16) {
            PlanOptionView(
                title: "1 Week, $9.99",
                subtitle: nil,
                badge: nil,
                isSelected: selectedPlan == .weekly,
                selectionColor: selectedPlan == .weekly ? Color(hex: "#D7263D") : Color.black
            )
            .onTapGesture { selectedPlan = .weekly }
            
            PlanOptionView(
                title: "1 Month, $19.99",
                subtitle: "Only $4.50 / week",
                badge: "Best value",
                isSelected: selectedPlan == .monthly,
                selectionColor: selectedPlan == .monthly ? Color(hex: "#D7263D") : Color.black
            )
            .onTapGesture { selectedPlan = .monthly }
        }
    }
    
    // MARK: - Subscribe Button
    
    private var subscribeButton: some View {
        Button(action: {
            // TODO: subscribe action
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black.opacity(0.45))
                    .frame(height: 64)
                    .offset(y: 5)
                
                Image("btn_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .overlay(
                        Text("Subscribe")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 3)
                    )
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Legal Copy
    
    private var legalFooter: some View {
        Text("By continuing, you agree to Privacy Policy\nand Terms & Condition")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.black.opacity(0.7))
            .multilineTextAlignment(.center)
    }
    
    private var footnotes: some View {
        HStack(spacing: 18) {
            Button("Restore", action: {})
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
            
            Button("Terms of Use", action: {})
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
            
            Button("Privacy Policy", action: {})
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Models

private enum Plan: String {
    case weekly
    case monthly
}

private enum PlanBenefit: CaseIterable {
    case fasterResults
    case unlockPremium
    case unlimitedMemes
    case nonstopChaos
    
    var title: String {
        switch self {
        case .fasterResults: return "Faster Results"
        case .unlockPremium: return "Unlock premium features"
        case .unlimitedMemes: return "Unlimited Meme Generations"
        case .nonstopChaos: return "Non-Stop Chaos At Your Fingertips"
        }
    }
}

// MARK: - Subviews

private struct PlanOptionView: View {
    let title: String
    let subtitle: String?
    let badge: String?
    let isSelected: Bool
    let selectionColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let badge {
                Text(badge.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#F2C94C"))
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    )
            }
            
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                        .frame(width: 28, height: 28)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "#27AE60"))
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(isSelected ? selectionColor : Color.black, lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 6)
        )
    }
}

// MARK: - Toggle Style

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .previewDevice("iPhone 14 Pro")
    }
}


