import SwiftUI

struct IntroTitleText: View {
    let text: String
    var fontSize: CGFloat = 28
    var animationDelay: Double = 0.15
    
    @State private var scale: CGFloat = 0.85
    @State private var bounce: CGFloat = 0
    @State private var fade: Double = 0
    
    private var font: Font {
        AppFont.nippoMedium(fontSize)
    }
    
    private var outlineOffsets: [CGPoint] {
        [
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
    }
    
    var body: some View {
        ZStack {
            ForEach(outlineOffsets, id: \.self) { offset in
                Text(text)
                    .font(font)
                    .fontWeight(.black)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .offset(x: offset.x, y: offset.y)
                    .opacity(fade)
                    .scaleEffect(scale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(animationDelay), value: scale)
                    .animation(.easeOut(duration: 0.25).delay(animationDelay), value: fade)
            }
            
            Text(text)
                .font(font)
                .fontWeight(.black)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .opacity(fade)
                .scaleEffect(scale + bounce)
                .animation(.spring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.1).delay(animationDelay), value: bounce)
                .animation(.easeOut(duration: 0.25).delay(animationDelay), value: fade)
        }
        .onAppear {
            withAnimation {
                fade = 1
            }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.6).delay(animationDelay)) {
                scale = 1
                bounce = 0.05
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(animationDelay + 0.3)) {
                bounce = 0
            }
        }
    }
}



