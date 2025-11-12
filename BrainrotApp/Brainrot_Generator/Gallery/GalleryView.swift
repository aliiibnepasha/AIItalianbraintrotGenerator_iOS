import SwiftUI
import UIKit

struct GalleryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var contentStore: GeneratedContentStore
    @State private var detailImage: GeneratedImage?
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                header
                    .padding(.top, 8)
                
                if contentStore.gallery.isEmpty {
                    VStack(spacing: 12) {
                        Text("Your creations will appear here")
                            .font(AppFont.nippoMedium(18))
                            .foregroundColor(.black)
                        Text("Generate an image to see it in your gallery.")
                            .font(AppFont.nippoMedium(14))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(contentStore.gallery) { item in
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
        HStack {
            navigationButton(action: { dismiss() })
            
            Spacer()
            
            Text("Gallery")
                .font(AppFont.nippoMedium(34))
                .fontWeight(.black)
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
                            .font(AppFont.nippoMedium(16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
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
