import SwiftUI

struct GeneratingView: View {
    // MARK: - Animation State
    @State private var backRotation: Double = 0
    @State private var middleRotation: Double = 0
    @State private var topRotation: Double = 0
    
    // MARK: - Configuration
    private let backgroundImage = "generating_bg"
    private let backCardImage = "generating_card_back"
    private let middleCardImage = "generating_card_middle"
    private let topCardImage = "generating_card_front"
    private let centerArtworkImage = "generating_main"
    
    var body: some View {
        ZStack {
            // Background
            Image(backgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                cardsStack
                
                generatingCapsule
            }
            .padding(.horizontal, 32)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: startAnimations)
    }
    
    // MARK: - Components
    
    private var cardsStack: some View {
        ZStack {
            RotatingCard(imageName: backCardImage,
                         rotation: backRotation,
                         size: 320)
            
            RotatingCard(imageName: middleCardImage,
                         rotation: middleRotation,
                         size: 310)
            
            RotatingCard(imageName: topCardImage,
                         rotation: topRotation,
                         size: 240)
            
            Image(centerArtworkImage)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 18)
    }
    
    private var generatingCapsule: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.black.opacity(0.45))
                .frame(height: 64)
                .offset(y: 5)
            
            Image("btn_bg")
                .resizable()
                .scaledToFill()
                .frame(height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.black, lineWidth: 4)
                )
                .overlay(
                    Text("Generating.....")
                        .font(AppFont.nippoMedium(20))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 3)
                )
        }
        .frame(width: 260)
    }
    
    // MARK: - Animation
    
    private func startAnimations() {
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            backRotation = -360
        }
        withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
            middleRotation = 360
        }
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            topRotation = -360
        }
        
    }
}

private struct RotatingCard: View {
    let imageName: String
    let rotation: Double
    let size: CGFloat
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
    }
}

struct GeneratingView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratingView()
            .previewDevice("iPhone 14 Pro")
    }
}


