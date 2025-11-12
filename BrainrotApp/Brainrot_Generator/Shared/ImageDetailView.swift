import SwiftUI
import UIKit

struct ImageDetailView: View {
    @EnvironmentObject private var contentStore: GeneratedContentStore
    
    let image: GeneratedImage
    var onClose: () -> Void
    var onDelete: (() -> Void)?
    
    @State private var shareItems: [Any] = []
    @State private var showShareSheet: Bool = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                header
                    .padding(.top, 16)
                
                Image(uiImage: image.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.black, lineWidth: 6)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 14)
                    .padding(.horizontal, 24)
                
                if !image.title.isEmpty {
                    VStack(spacing: 4) {
                        Text(image.title)
                            .font(AppFont.nippoMedium(20))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        if let subtitle = image.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(AppFont.nippoMedium(15))
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                actionButtons
                    .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: shareItems)
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.45))
                        .frame(width: 40, height: 40)
                        .offset(y: 4)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 4)
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(AppFont.nippoMedium(16))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            favoriteButton
            shareButton
            deleteButton
        }
        .frame(maxWidth: .infinity)
    }
    
    private var favoriteButton: some View {
        Button {
            contentStore.toggleFavorite(image)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.black.opacity(0.45))
                    .frame(height: 60)
                    .offset(y: 5)
                
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(hex: "#F2C94C"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 8) {
                            Image(systemName: contentStore.isFavorite(image) ? "heart.fill" : "heart")
                                .foregroundColor(.black)
                            Text(contentStore.isFavorite(image) ? "Favorited" : "Favorite")
                                .font(AppFont.nippoMedium(18))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                    )
            }
        }
        .buttonStyle(.plain)
    }
    
    private var shareButton: some View {
        Button {
            shareItems = [image.image]
            DispatchQueue.main.async {
                showShareSheet = true
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.black.opacity(0.45))
                    .frame(height: 60)
                    .offset(y: 5)
                
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.black)
                            Text("Share")
                                .font(AppFont.nippoMedium(18))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                    )
            }
        }
        .buttonStyle(.plain)
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            onDelete?()
            onClose()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.black.opacity(0.45))
                    .frame(height: 60)
                    .offset(y: 5)
                
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(hex: "#D7263D"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .frame(height: 60)
                    .overlay(
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                            Text("Delete")
                                .font(AppFont.nippoMedium(18))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
        .buttonStyle(.plain)
    }
}


