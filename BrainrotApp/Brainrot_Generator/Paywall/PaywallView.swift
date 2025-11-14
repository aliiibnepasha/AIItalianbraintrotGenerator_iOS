import SwiftUI

struct PaywallView: View {
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var usageManager: UsageManager
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    // MARK: - State
    @State private var selectedPlan: SubscriptionPlan = .monthly
    @State private var isPurchasing: Bool = false
    @State private var purchaseErrorMessage: String?
    @State private var showPurchaseError: Bool = false
    
    // MARK: - Constants
    private let backgroundColor = Color(hex: "#E5F974")
    private let characterImageName = "paywall_hero"
    @State private var animateHero: Bool = false
    @State private var titleScale: CGFloat = 0.85
    @State private var titleBounce: CGFloat = 0
    @State private var titleFade: Double = 0
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            
                VStack(spacing: 24) {
                    ZStack(alignment: .bottom) {
                        heroSection
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                        
                        paywallTitle
                            .padding(.bottom, 80)
                    }
                    .padding(.bottom, -30)

                    benefitsList
                        .padding(.top, -70)
                    
                    planOptions
                    
                    subscribeButton
                        .padding(.top, -8)
                    
                    legalFooter
                        .padding(.top, -12)
                    
                    footnotes
                        .padding(.top, -8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            
            
            // Close Button - Top Left
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(AppFont.nippoMedium(18))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 35, height: 35)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            animateHero = true
        }
        .task {
            await purchaseManager.ensureProducts(for: Array(SubscriptionPlan.allCases))
        }
        .alert(purchaseErrorMessage ?? PurchaseError.unknown.localizedDescription,
               isPresented: $showPurchaseError) {
            Button(L10n.Common.ok, role: .cancel) {}
        }
    }
    
    // MARK: - Hero
    
    private var heroSection: some View {
        Image(characterImageName)
            .resizable()
            .scaledToFit()
            .frame(height: 350)
            .scaleEffect(animateHero ? 1.0 : 0.0)
            .opacity(animateHero ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.05), value: animateHero)
    }
    
    // MARK: - Paywall Title
    
    private var paywallTitle: some View {
        let text = L10n.Paywall.heroTitle
        let fontSize: CGFloat = 36
        
        let outlineOffsets: [CGPoint] = [
            CGPoint(x: -3, y: -3),
            CGPoint(x: 3, y: -3),
            CGPoint(x: -3, y: 3),
            CGPoint(x: 3, y: 3),
            CGPoint(x: 0, y: -3),
            CGPoint(x: 0, y: 3),
            CGPoint(x: -4, y: 0),
            CGPoint(x: 4, y: 0),
            CGPoint(x: 0, y: 4),
            CGPoint(x: 0, y: 5),
            CGPoint(x: 0, y: 6)
        ]
        
        return ZStack {
            // Black outline layers
            ForEach(outlineOffsets, id: \.self) { offset in
                Text(text)
                    .font(AppFont.nippoMedium(fontSize))
                    .fontWeight(.black)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .offset(x: offset.x, y: offset.y)
                    .opacity(titleFade)
                    .scaleEffect(titleScale)
            }
            
            // White main text
            Text(text)
                .font(AppFont.nippoMedium(fontSize))
                .fontWeight(.black)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .opacity(titleFade)
                .scaleEffect(titleScale + titleBounce)
        }
        .onAppear {
            withAnimation {
                titleFade = 1
            }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.6).delay(0.15)) {
                titleScale = 1
                titleBounce = 0.05
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.45)) {
                titleBounce = 0
            }
        }
    }
    
    // MARK: - Benefits
    
    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(PlanBenefit.allCases.enumerated()), id: \.element) { index, benefit in
                BenefitRowView(
                    benefit: benefit,
                    delay: Double(index) * 0.08
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
    }
    
    private struct BenefitRowView: View {
        let benefit: PlanBenefit
        let delay: Double
        @State private var isVisible: Bool = false
        
        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 22, height: 22)
                        .scaleEffect(isVisible ? 1.0 : 0.0)
                        .opacity(isVisible ? 1.0 : 0.0)
                    
                    Image(systemName: "checkmark")
                        .font(AppFont.nippoMedium(14))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .scaleEffect(isVisible ? 1.0 : 0.0)
                        .opacity(isVisible ? 1.0 : 0.0)
                }
                
                Text(benefit.title)
                    .font(AppFont.nippoMedium(16))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .offset(x: isVisible ? 0 : -20)
                    .opacity(isVisible ? 1.0 : 0.0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                    isVisible = true
                }
            }
        }
    }
    
    // MARK: - Plan Options
    
    private var planOptions: some View {
        VStack(spacing: 16) {
            PlanOptionView(
                title: planTitle(for: .weekly, fallback: L10n.Paywall.weeklyPlan),
                subtitle: nil,
                badge: nil,
                isSelected: selectedPlan == .weekly,
                selectionColor: selectedPlan == .weekly ? Color(hex: "#D7263D") : Color.black
            )
            .onTapGesture { selectedPlan = .weekly }
            
            PlanOptionView(
                title: planTitle(for: .monthly, fallback: L10n.Paywall.monthlyPlan),
                subtitle: L10n.Paywall.monthlySubtitle,
                badge: L10n.Paywall.bestValueBadge,
                isSelected: selectedPlan == .monthly,
                selectionColor: selectedPlan == .monthly ? Color(hex: "#D7263D") : Color.black
            )
            .onTapGesture { selectedPlan = .monthly }
        }
    }
    
    // MARK: - Subscribe Button
    
    private var subscribeButton: some View {
        Button(action: { Task { await purchaseSelectedPlan() } }) {
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
                        Text(L10n.Paywall.subscribe)
                            .font(AppFont.nippoMedium(20))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 3)
                    )
                
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
        .opacity(isPurchasing ? 0.75 : 1.0)
    }
    
    // MARK: - Legal Copy
    
    private var legalFooter: some View {
        Text(L10n.Paywall.legal)
            .font(AppFont.nippoMedium(12))
            .foregroundColor(.black.opacity(0.7))
            .multilineTextAlignment(.center)
    }
    
    private var footnotes: some View {
        HStack(spacing: 18) {
            Button(L10n.Paywall.restore, action: {})
                .font(AppFont.nippoMedium(12))
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Button(L10n.Paywall.terms) {
                openURL(AppLinks.termsOfService)
            }
                .font(AppFont.nippoMedium(12))
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Button(L10n.Paywall.privacy) {
                openURL(AppLinks.privacyPolicy)
            }
                .font(AppFont.nippoMedium(12))
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
    
    private func planTitle(for plan: SubscriptionPlan, fallback: String) -> String {
        let parts = splitPlanLabel(fallback)
        let price = purchaseManager.product(for: plan)?.displayPrice ?? parts.price
        if let price, !price.isEmpty {
            return "\(parts.title), \(price)"
        } else {
            return parts.title
        }
    }
    
    private func splitPlanLabel(_ label: String) -> (title: String, price: String?) {
        let components = label.split(separator: ",", maxSplits: 1)
        let title = components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? label
        let price = components.count > 1 ? components[1].trimmingCharacters(in: .whitespacesAndNewlines) : nil
        return (title, price)
    }
    
    private func purchaseSelectedPlan() async {
        if isPurchasing { return }
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            _ = try await purchaseManager.purchase(plan: selectedPlan)
            try await usageManager.applySubscription(selectedPlan)
            await MainActor.run {
                dismiss()
            }
        } catch PurchaseError.userCancelled {
            // no-op
        } catch {
            purchaseErrorMessage = error.localizedDescription
            showPurchaseError = true
        }
    }
}

// MARK: - Models

private enum PlanBenefit: CaseIterable {
    case fasterResults
    case unlockPremium
    case unlimitedMemes
    case nonstopChaos
    
    var title: String {
        switch self {
        case .fasterResults: return L10n.Paywall.benefitFasterResults
        case .unlockPremium: return L10n.Paywall.benefitUnlockPremium
        case .unlimitedMemes: return L10n.Paywall.benefitUnlimitedMemes
        case .nonstopChaos: return L10n.Paywall.benefitNonstopChaos
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
                    .font(AppFont.nippoMedium(12))
                    .fontWeight(.bold)
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
                        .font(AppFont.nippoMedium(18))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.nippoMedium(13))
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
                                    .font(AppFont.nippoMedium(12))
                                    .fontWeight(.bold)
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
            .environmentObject(LocalizationManager.shared)
            .environmentObject(PurchaseManager.shared)
            .environmentObject(UsageManager())
    }
}


