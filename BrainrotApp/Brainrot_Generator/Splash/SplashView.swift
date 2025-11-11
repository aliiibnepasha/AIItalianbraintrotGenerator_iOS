import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void = {}
    
    @State private var animateText: Bool = false
    
    var body: some View {
        ZStack {
            
            // ✅ Background Image (from Assets)
            Image("splash_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // ✅ Animated Text
            Text("ITALIAN\nBRAINROT")
                .font(.system(size: 48, weight: .black))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 4, x: 3, y: 3)
                .scaleEffect(animateText ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.45).delay(0.2), value: animateText)
        }
        .onAppear {
            animateText = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onFinished()
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .previewDevice("iPhone 14 Pro")
    }
}

