import SwiftUI

// MARK: - Screen
struct GenerateDetailsView: View {
    var onGenerate: () -> Void = {}
    // Selections (all single-select, independent)
    @State private var selectedGenderIndex: Int = 0
    @State private var selectedMoodIndex: Int = 0
    @State private var accentStrength: Double = 0.45
    @State private var selectedOutfit: Int = 0
    @State private var selectedAspect: Aspect = .oneOne

    // Display data
    private let genderItems = ["Male", "Female", "Mixed", "Chaos"]
    private let moodItems   = ["Romantic", "Mafia Drama", "Cafe Gossip", "Tiktok-Rot"]
    private let outfitItems: [OutfitItem] = [
        .init(image: "outfit_vintage", title: "Vintage"),
        .init(image: "outfit_modern", title: "Modern"),
        .init(image: "outfit_meme", title: "Meme-Core")
    ]

    @Environment(\.dismiss) private var dismiss

    // Colors (no custom hex helpers to avoid ambiguity)
    private let bgColor   = SwiftUI.Color(red: 251/255, green: 238/255, blue: 227/255) // #FBEEE3
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

                        SwiftUI.Text("Customize\nYour Chaos")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .lineSpacing(2)
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SwiftUI.Spacer(minLength: 0)
                            .frame(width: 40)
                    }
                    .padding(.top, 6)

                    // Gender / Vibe (single select)
                    SectionLabel("Gender / Vibe")
                    Pill2x2Section(
                        titles: genderItems,
                        selectedIndex: $selectedGenderIndex,
                        selectionColor: pinkColor
                    )

                    // Mood Selector (single select)
                    SectionLabel("Mood Selector")
                    Pill2x2Section(
                        titles: moodItems,
                        selectedIndex: $selectedMoodIndex,
                        selectionColor: pinkColor
                    )

                    // Accent Strength
                    SectionLabel("Accent Strength")
                    AccentSlider(value: $accentStrength)

                    // Outfit Style (horizontal cards, single select)
                    SectionLabel("Outfit Style")
                    OutfitRow(
                        items: outfitItems,
                        selectedIndex: $selectedOutfit,
                        yellow: yellow,
                        selectionColor: pinkColor
                    )

                    // Aspect Ratio (up to 16:9)
                    SectionLabel("Aspect Ratio")
                    AspectRow(selected: $selectedAspect, selectionColor: pinkColor)

                    // Generate Button
                    GenerateButton(title: "Generate", action: onGenerate)
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
private enum Aspect: String, CaseIterable, Identifiable {
    case oneOne = "1:1"
    case fourThree = "4:3"
    case twoThree = "2:3"
    case threeTwo = "3:2"
    case sixteenNine = "16:9"
    var id: String { rawValue }
}

private struct OutfitItem {
    let image: String
    let title: String
}

// MARK: - Components

// Section Title
private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        SwiftUI.Text(text)
            .font(.system(size: 15, weight: .bold))
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
                            .font(.system(size: 16, weight: .bold))
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .black)
                )
        }
    }
}

// 2x2 pills section
private struct Pill2x2Section: View {
    let titles: [String]
    @Binding var selectedIndex: Int
    let selectionColor: SwiftUI.Color

    var body: some View {
        SwiftUI.VStack(spacing: 12) {
            SwiftUI.HStack(spacing: 12) {
                ForEach(0..<min(2, titles.count), id: \.self) { i in
                    SwiftUI.Button {
                        selectedIndex = i
                    } label: {
                        SelectPill(title: titles[i], isSelected: selectedIndex == i, selectionColor: selectionColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            SwiftUI.HStack(spacing: 12) {
                ForEach(2..<min(4, titles.count), id: \.self) { i in
                    SwiftUI.Button {
                        selectedIndex = i
                    } label: {
                        SelectPill(title: titles[i], isSelected: selectedIndex == i, selectionColor: selectionColor)
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
                SwiftUI.Text("Mild")
                SwiftUI.Spacer()
                SwiftUI.Text("Over-The Top")
            }
            .font(.system(size: 13, weight: .regular))
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

                            SwiftUI.Text(items[i].title)
                                .font(.system(size: 13, weight: .semibold))
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
                        .font(.system(size: 14, weight: .semibold))
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
                    .font(.system(size: 20, weight: .black, design: .rounded))
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
        GenerateDetailsView()
            .previewDisplayName("Generate Details")
    }
}

