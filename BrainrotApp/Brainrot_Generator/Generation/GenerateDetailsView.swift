import SwiftUI

struct SelectionOption: Hashable {
    let displayTitle: String
    let promptValue: String
}

// MARK: - Screen
struct GenerateDetailsView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    let keywords: [String]
    let onGenerate: (GenerationRequest) -> Void
    // Selections (all single-select, independent)
    @State private var selectedGenderIndex: Int = 0
    @State private var selectedMoodIndex: Int = 0
    @State private var accentStrength: Double = 0.45
    @State private var selectedOutfit: Int = 0
    @State private var selectedAspect: Aspect = .oneOne

    // Display data
    private let genderOptions: [SelectionOption] = [
        .init(displayTitle: L10n.GenerateDetails.genderMale, promptValue: "Male"),
        .init(displayTitle: L10n.GenerateDetails.genderFemale, promptValue: "Female"),
        .init(displayTitle: L10n.GenerateDetails.genderMixed, promptValue: "Mixed"),
        .init(displayTitle: L10n.GenerateDetails.genderChaos, promptValue: "Chaos")
    ]
    private let moodOptions: [SelectionOption] = [
        .init(displayTitle: L10n.GenerateDetails.moodRomantic, promptValue: "Romantic"),
        .init(displayTitle: L10n.GenerateDetails.moodMafia, promptValue: "Mafia Drama"),
        .init(displayTitle: L10n.GenerateDetails.moodCafe, promptValue: "Cafe Gossip"),
        .init(displayTitle: L10n.GenerateDetails.moodTiktok, promptValue: "Tiktok-Rot")
    ]
    private let outfitItems: [OutfitItem] = [
        .init(image: "outfit_vintage", displayTitle: L10n.GenerateDetails.outfitVintage, promptValue: "Vintage"),
        .init(image: "outfit_modern", displayTitle: L10n.GenerateDetails.outfitModern, promptValue: "Modern"),
        .init(image: "outfit_meme", displayTitle: L10n.GenerateDetails.outfitMeme, promptValue: "Meme-Core")
    ]

    @Environment(\.dismiss) private var dismiss

    // Colors (no custom hex helpers to avoid ambiguity)
    private let bgColor   = Theme.background
    private let pinkColor = SwiftUI.Color(red: 215/255, green: 38/255,  blue: 61/255) // #D7263D
    private let yellow    = SwiftUI.Color(red: 242/255, green: 201/255,  blue:  76/255) // #F2C94C

    var body: some View {
        SwiftUI.ZStack {
            // Background (explicit SwiftUI.Rectangle)
            SwiftUI.Rectangle()
                .fill(bgColor)
                .ignoresSafeArea()

            SwiftUI.ScrollView {   // <-- fully-qualified to avoid symbol shadowing
                SwiftUI.VStack(alignment: .leading, spacing: 18) {

                    // Header Row (Back + Title)
                    SwiftUI.HStack(alignment: .top, spacing: 12) {
                        BackButton { dismiss() }
                            .alignmentGuide(.top) { d in d[.top] - 4 }

                        SwiftUI.Text(L10n.GenerateDetails.headerTitle)
                            .font(AppFont.nippoMedium(32))
                            .fontWeight(.black)
                            .foregroundColor(.black)
                            .lineSpacing(2)
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SwiftUI.Spacer(minLength: 0)
                            .frame(width: 40)
                    }
                    .padding(.top, 6)

                    // Gender / Vibe (single select)
                    SectionLabel(L10n.GenerateDetails.sectionGender)
                    Pill2x2Section(
                        options: genderOptions,
                        selectedIndex: $selectedGenderIndex,
                        selectionColor: pinkColor
                    )

                    // Mood Selector (single select)
                    SectionLabel(L10n.GenerateDetails.sectionMood)
                    Pill2x2Section(
                        options: moodOptions,
                        selectedIndex: $selectedMoodIndex,
                        selectionColor: pinkColor
                    )

                    // Accent Strength
                    SectionLabel(L10n.GenerateDetails.sectionAccent)
                    AccentSlider(value: $accentStrength)

                    // Outfit Style (horizontal cards, single select)
                    SectionLabel(L10n.GenerateDetails.sectionOutfit)
                    OutfitRow(
                        items: outfitItems,
                        selectedIndex: $selectedOutfit,
                        yellow: yellow,
                        selectionColor: pinkColor
                    )

                    // Aspect Ratio (up to 16:9)
                    SectionLabel(L10n.GenerateDetails.sectionAspect)
                    AspectRow(selected: $selectedAspect, selectionColor: pinkColor)

                    // Generate Button
                    GenerateButton(title: L10n.Common.generate) {
                        let request = GenerationRequest(
                            keywords: keywords,
                            gender: genderOptions[selectedGenderIndex],
                            mood: moodOptions[selectedMoodIndex],
                            accentStrength: accentStrength,
                            outfit: outfitItems[selectedOutfit].selection,
                            aspect: selectedAspect
                        )
                        onGenerate(request)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 8)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Models
enum Aspect: String, CaseIterable, Identifiable {
    case oneOne = "1:1"
    case fourThree = "4:3"
    case twoThree = "2:3"
    case threeTwo = "3:2"
    case sixteenNine = "16:9"
    var id: String { rawValue }
}

private struct OutfitItem {
    let image: String
    let displayTitle: String
    let promptValue: String
    
    var selection: SelectionOption {
        SelectionOption(displayTitle: displayTitle, promptValue: promptValue)
    }
}

struct GenerationRequest: Hashable {
    let keywords: [String]
    let gender: SelectionOption
    let mood: SelectionOption
    let accentStrength: Double
    let outfit: SelectionOption
    let aspect: Aspect
    
    func composedPrompt() -> String {
        let fusedCharacters = fusedKeywordPhrase()
        let accentDescriptor = accentIntensityDescriptor()
        let moodDescriptor = mood.promptValue.lowercased()

        return """
        Create a surreal and chaotic 'brain rot' hybrid creature design that is a literal fusion of \(fusedCharacters).
        Do NOT make it look like a normal person — it should be a creature or hybrid lifeform where the anatomy and features of each element are physically merged together.
        For example, parts of the body, texture, and shape should clearly show details from both \(fusedCharacters).
        
        Gender style: \(gender.promptValue). Mood: \(mood.promptValue). Accent strength: \(accentDescriptor). Outfit style: \(outfit.promptValue).
        The overall vibe is absurdist and over-saturated, combining animal, object, and human chaos in one.
        Ultra-detailed, hyper-colorful, cinematic lighting, stylized 4K render, in the art style of 'brain rot meme universe'.
        Setting: a hyper-digital \(moodDescriptor) environment loaded with neon signage, floating emojis, stickers, graffiti text, and glitch effects.
        Aspect ratio: \(aspect.rawValue)
                The fusion should feel bizarre, vibrant, meme-like, and overloaded with digital brainrot energy — glowing emojis, chaotic lighting, colorful cyber aesthetics, viral meme stickers, digital screens and emojis floating around.

        
        """
    }

    
    var displayTitle: String {
        let joined = keywords.joined(separator: ", ").capitalized
        return joined.isEmpty ? L10n.GenerateDetails.defaultTitle : joined
    }
    
    var summary: String {
        L10n.GenerateDetails.summary(mood: mood.displayTitle, outfit: outfit.displayTitle, aspect: aspect.rawValue)
    }
    
    var negativePrompt: String {
        """
        avoid plain humans, avoid realistic human faces, avoid normal people, avoid photorealism,
        avoid fashion poses, avoid clean studio portraits, avoid animals alone, avoid realistic anatomy,
        focus on hybrid fusion, make the creature surreal, weird, exaggerated, stylized, meme-like
        """
    }
    
    private func fusedKeywordPhrase() -> String {
        let cleaned = keywords
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !cleaned.isEmpty else {
            return L10n.GenerateDetails.defaultCharacter
        }
        
        if cleaned.count == 1 {
            return cleaned[0]
        }
        
        if cleaned.count == 2 {
            return "\(cleaned[0]) and \(cleaned[1])"
        }
        
        let allButLast = cleaned.dropLast().joined(separator: ", ")
        if let last = cleaned.last {
            return "\(allButLast), and \(last)"
        }
        return cleaned.joined(separator: ", ")
    }
    
    private func accentIntensityDescriptor() -> String {
        switch accentStrength {
        case ..<0.3:
            return "mild"
        case 0.3..<0.7:
            return "balanced"
        default:
            return "over the top"
        }
    }
}

// MARK: - Components

// Section Title
private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        SwiftUI.Text(text)
            .font(AppFont.nippoMedium(15))
            .fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.top, 2)
    }
}

// Back Button (cartoon style)
private struct BackButton: View {
    var action: () -> Void

    var body: some View {
        SwiftUI.Button(action: action) {
            SwiftUI.ZStack {
                SwiftUI.RoundedRectangle(cornerRadius: 10)
                    .fill(SwiftUI.Color.black.opacity(0.40))
                    .frame(width: 40, height: 40)
                    .offset(y: 5)

                SwiftUI.RoundedRectangle(cornerRadius: 10)
                    .fill(SwiftUI.Color.white)
                    .overlay(
                        SwiftUI.RoundedRectangle(cornerRadius: 10)
                            .stroke(SwiftUI.Color.black, lineWidth: 4)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        SwiftUI.Image(systemName: "chevron.left")
                            .font(AppFont.nippoMedium(16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// Pink selection pill with cartoon shadow
private struct SelectPill: View {
    let title: String
    let isSelected: Bool
    let selectionColor: SwiftUI.Color

    var body: some View {
        SwiftUI.ZStack {
            SwiftUI.RoundedRectangle(cornerRadius: 18)
                .fill(SwiftUI.Color.black.opacity(0.40))
                .frame(height: 56)
                .offset(y: 5)

            SwiftUI.RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? selectionColor : SwiftUI.Color.white)
                .overlay(
                    SwiftUI.RoundedRectangle(cornerRadius: 18)
                        .stroke(SwiftUI.Color.black, lineWidth: 4)
                )
                .frame(height: 56)
                .overlay(
                    SwiftUI.Text(title)
                        .font(AppFont.nippoMedium(16))
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .black)
                )
        }
    }
}

// 2x2 pills section
private struct Pill2x2Section: View {
    let options: [SelectionOption]
    @Binding var selectedIndex: Int
    let selectionColor: SwiftUI.Color

    var body: some View {
        SwiftUI.VStack(spacing: 12) {
            SwiftUI.HStack(spacing: 12) {
                ForEach(0..<min(2, options.count), id: \.self) { i in
                    SwiftUI.Button {
                        selectedIndex = i
                    } label: {
                        SelectPill(title: options[i].displayTitle, isSelected: selectedIndex == i, selectionColor: selectionColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            SwiftUI.HStack(spacing: 12) {
                ForEach(2..<min(4, options.count), id: \.self) { i in
                    SwiftUI.Button {
                        selectedIndex = i
                    } label: {
                        SelectPill(title: options[i].displayTitle, isSelected: selectedIndex == i, selectionColor: selectionColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// Accent Strength slider block
private struct AccentSlider: View {
    @Binding var value: Double

    var body: some View {
        SwiftUI.ZStack {
            SwiftUI.RoundedRectangle(cornerRadius: 20)
                .fill(SwiftUI.Color.black.opacity(0.40))
                .frame(height: 64)
                .offset(y: 5)

            SwiftUI.RoundedRectangle(cornerRadius: 20)
                .fill(SwiftUI.Color.white)
                .overlay(
                    SwiftUI.RoundedRectangle(cornerRadius: 20)
                        .stroke(SwiftUI.Color.black, lineWidth: 5)
                )
                .frame(height: 64)
                .overlay(sliderContent)
        }
    }

    private var sliderContent: some View {
        SwiftUI.VStack(spacing: 8) {
            SwiftUI.Slider(value: $value, in: 0...1)
                .tint(SwiftUI.Color.blue)
                .padding(.horizontal, 16)
            SwiftUI.HStack {
                SwiftUI.Text(L10n.GenerateDetails.sliderLow)
                SwiftUI.Spacer()
                SwiftUI.Text(L10n.GenerateDetails.sliderHigh)
            }
            .font(AppFont.nippoMedium(13))
            .foregroundColor(SwiftUI.Color.black.opacity(0.65))
            .padding(.horizontal, 12)
        }
    }
}

// Outfit horizontal row
private struct OutfitRow: View {
    let items: [OutfitItem]
    @Binding var selectedIndex: Int
    let yellow: SwiftUI.Color
    let selectionColor: SwiftUI.Color

    var body: some View {
        SwiftUI.ScrollView(.horizontal, showsIndicators: false) {
            SwiftUI.HStack(spacing: 29) {
                ForEach(items.indices, id: \.self) { i in
                    let selected = (i == selectedIndex)
                    SwiftUI.ZStack {
                        SwiftUI.RoundedRectangle(cornerRadius: 16)
                            .fill(SwiftUI.Color.black.opacity(0.40))
                            .frame(width: 100, height: 136)
                            .offset(y: 5)

                        SwiftUI.VStack(spacing: 6) {
                            SwiftUI.Image(items[i].image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 88)
                                .clipShape(SwiftUI.RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    SwiftUI.RoundedRectangle(cornerRadius: 12)
                                        .stroke(SwiftUI.Color.black, lineWidth: 3)
                                )

                            SwiftUI.Text(items[i].displayTitle)
                                .font(AppFont.nippoMedium(13))
                                .fontWeight(.semibold)
                                .foregroundColor(selected ? .white : .black)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(6)
                        .background(
                            SwiftUI.RoundedRectangle(cornerRadius: 16)
                                .fill(yellow)
                                .overlay(
                                    SwiftUI.RoundedRectangle(cornerRadius: 16)
                                        .stroke(selected ? selectionColor : SwiftUI.Color.black, lineWidth: 4)
                                )
                        )
                        .frame(width: 100, height: 136)
                    }
                    .onTapGesture { selectedIndex = i }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
        }
    }
}

// Aspect Ratio chips
private struct AspectRow: View {
    @Binding var selected: Aspect
    let selectionColor: SwiftUI.Color

    var body: some View {
        SwiftUI.HStack(spacing: 10) {
            ForEach([Aspect.oneOne, .fourThree, .twoThree, .threeTwo, .sixteenNine]) { a in
                AspectChip(title: a.rawValue, isSelected: a == selected, selectionColor: selectionColor)
                    .onTapGesture { selected = a }
            }
            SwiftUI.Spacer(minLength: 0)
        }
    }
}

private struct AspectChip: View {
    let title: String
    let isSelected: Bool
    let selectionColor: SwiftUI.Color

    var body: some View {
        SwiftUI.ZStack {
            SwiftUI.RoundedRectangle(cornerRadius: 16)
                .fill(SwiftUI.Color.black.opacity(0.40))
                .frame(height: 44)
                .offset(y: 5)

            SwiftUI.RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? selectionColor : SwiftUI.Color.white)
                .overlay(
                    SwiftUI.RoundedRectangle(cornerRadius: 16)
                        .stroke(SwiftUI.Color.black, lineWidth: 4)
                )
                .frame(width: 66, height: 44)
                .overlay(
                    SwiftUI.Text(title)
                        .font(AppFont.nippoMedium(14))
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .black)
                )
        }
    }
}

// Generate Button
private struct GenerateButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        SwiftUI.Button(action: action) {
            SwiftUI.ZStack {
                SwiftUI.RoundedRectangle(cornerRadius: 24)
                    .fill(SwiftUI.Color.black.opacity(0.40))
                    .frame(height: 56)
                    .offset(y: 5)

                SwiftUI.Image("btn_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 56)
                    .clipShape(SwiftUI.RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        SwiftUI.RoundedRectangle(cornerRadius: 24)
                            .stroke(SwiftUI.Color.black, lineWidth: 4)
                    )

                SwiftUI.Text(title)
                    .font(AppFont.nippoMedium(20))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.65), radius: 0, x: 0, y: 3)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct GenerateDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateDetailsView(keywords: ["Preview"], onGenerate: { _ in })
            .previewDisplayName("Generate Details")
            .environmentObject(LocalizationManager.shared)
    }
}

