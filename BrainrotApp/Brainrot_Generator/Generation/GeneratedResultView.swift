import SwiftUI
struct GeneratedResultView: View {
    @EnvironmentObject private var contentStore: GeneratedContentStore
    
    let image: GeneratedImage
    var onClose: () -> Void
    var onGenerateAgain: () -> Void
    
    @State private var shareItems: [Any] = []
    @State private var showShareSheet: Bool = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    header
                    
                    generatedPreview
                    
                    VStack(spacing: 16) {
                        favoriteButton
                        shareButton
                        generateAgainButton
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: shareItems)
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: onClose) {
                headerCloseButton
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Spacer().frame(width: 40)
        }
        .overlay(
            Text("Ai Brainrot")
                .font(AppFont.nippoMedium(28))
                .fontWeight(.black)
                .foregroundColor(.black)
        )
    }
    
    private var headerCloseButton: some View {
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
    
    private var generatedPreview: some View {
        VStack(spacing: 12) {
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
        }
    }
    
    private var shareButton: some View {
        Button {
            shareItems = [image.image]
            DispatchQueue.main.async {
                showShareSheet = true
            }
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
    
    private var generateAgainButton: some View {
        Button(action: onGenerateAgain) {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.black.opacity(0.45))
                    .frame(height: 60)
                    .offset(y: 5)
                
                Image("btn_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .overlay(
                        Text("Generate Again")
                            .font(AppFont.nippoMedium(18))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 3)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

struct GeneratedResultView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleImage = UIImage(named: "generated_placeholder") ?? UIImage()
        let generated = GeneratedImage(image: sampleImage, title: "Preview Character", subtitle: "Mood • Outfit • 1:1", fileName: "preview")
        let store = GeneratedContentStore()
        store.loadPreview([generated])
        return GeneratedResultView(
            image: generated,
            onClose: {},
            onGenerateAgain: {}
        )
        .environmentObject(store)
    }
}

