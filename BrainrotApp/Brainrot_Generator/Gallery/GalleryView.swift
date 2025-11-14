import SwiftUI
import UIKit

struct GalleryView: View {
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var contentStore: GeneratedContentStore
    @State private var detailImage: GeneratedImage?
    @State private var selectedFilter: GalleryFilter = .all
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]
    
    private var filteredGallery: [GeneratedImage] {
        switch selectedFilter {
        case .all:
            return contentStore.gallery
        case .favorites:
            return contentStore.favorites
        }
    }
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                
                filterButtons
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                
                if filteredGallery.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text(selectedFilter == .all ? L10n.Gallery.emptyTitle : "No favorites yet")
                            .font(AppFont.nippoMedium(18))
                            .foregroundColor(.black)
                        Text(selectedFilter == .all ? L10n.Gallery.emptySubtitle : "Tap the heart on a creation to add it to favorites.")
                            .font(AppFont.nippoMedium(14))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(filteredGallery) { item in
                                GalleryCardView(item: item)
                                    .onTapGesture {
                                        detailImage = item
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
        }
    }
    
    private var header: some View {
        ZStack {
            HStack {
                navigationButton(action: { dismiss() })
                Spacer()
            }
            
            Text(L10n.Gallery.title)
                .font(AppFont.nippoMedium(34))
                .fontWeight(.black)
                .foregroundColor(.black)
        }
    }
    
    private var filterButtons: some View {
        HStack(spacing: 10) {
            FilterCapsuleButton(
                title: "All",
                isSelected: selectedFilter == .all
            ) {
                selectedFilter = .all
            }
            
            FilterCapsuleButton(
                title: "Favourite",
                isSelected: selectedFilter == .favorites
            ) {
                selectedFilter = .favorites
            }
            
            Spacer()
        }
    }
    
    private func navigationButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.40))
                    .frame(width: 40, height: 40)
                    .offset(y: 5)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image("back_arrow_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
            .previewDevice("iPhone 14 Pro")
            .environmentObject(GeneratedContentStore())
            .environmentObject(LocalizationManager.shared)
    }
}

private enum GalleryFilter {
    case all
    case favorites
}

private struct FilterCapsuleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let gradient = LinearGradient(
        colors: [Color(hex: "#D7263D"), Color(hex: "#F2C94C")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.nippoMedium(14))
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? gradient : LinearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing))
                        .overlay(
                            Capsule()
                                .stroke(Color.black, lineWidth: 3)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct GalleryCardView: View {
    let item: GeneratedImage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(uiImage: item.image)
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
                    .font(AppFont.nippoMedium(16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppFont.nippoMedium(14))
                        .foregroundColor(.black.opacity(0.75))
                }
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
