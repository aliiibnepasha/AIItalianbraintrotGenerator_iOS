import SwiftUI

struct GalleryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let items: [GalleryItem] = [
        GalleryItem(title: "Tur Tur Tur Sahur", subtitle: "Neo-pop vigilante"),
        GalleryItem(title: "Mamma Mia Chaos", subtitle: "Retro rot vibe"),
        GalleryItem(title: "Shark Drip", subtitle: "Coastal vigilante"),
        GalleryItem(title: "Cafe Gossip", subtitle: "Latte dramatics")
    ]
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#FBEEE3")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                header
                    .padding(.top, 8)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(items) { item in
                            GalleryCardView(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var header: some View {
        HStack {
            navigationButton(action: { dismiss() })
            
            Spacer()
            
            Text("Gallery")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundColor(.black)
            
            Spacer()
            
            Spacer().frame(width: 40)
        }
        .padding(.horizontal, 16)
    }
    
    private func navigationButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.40))
                    .frame(width: 40, height: 40)
                    .offset(y: 5)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

private struct GalleryItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let image: String = "generated_placeholder"
}

private struct GalleryCardView: View {
    let item: GalleryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.black, lineWidth: 4)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(item.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .frame(height: 220, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#F2C94C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 4)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 8)
        )
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
            .previewDevice("iPhone 14 Pro")
    }
}


