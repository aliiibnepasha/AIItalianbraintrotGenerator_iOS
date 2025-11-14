import SwiftUI

struct Intro3View: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    var onGetStarted: () -> Void = {}
    
    @State private var animateSticker = false      // ✅ animation trigger
    
    var body: some View {
        ZStack {
            
            // Background
            Image("Intro3_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                
                Spacer().frame(height: 40)
                
                // ✅ Character + Sticker Group
                ZStack(alignment: .topLeading) {
                    
                    Image("character_intro2")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260)
                    
                    Image("hey_me")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .padding(.leading, -50)
                        .padding(.top, -30)
                        .scaleEffect(animateSticker ? 1 : 0.1)
                        .opacity(animateSticker ? 1 : 0)
                        .offset(x: animateSticker ? 0 : 40,
                                y: animateSticker ? 0 : 40)
                        .animation(.spring(response: 0.6,
                                           dampingFraction: 0.55,
                                           blendDuration: 0.2)
                                  .delay(0.25), value: animateSticker)
                    
                    Image("Tea_girl")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 280)
                        .padding(.top, 25)
                }
                
                // ✅ Title with thick cartoon shadow
                IntroTitleText(text: L10n.Intro.Three.title, fontSize: 30)
                .padding(.top, 12)
                .padding(.horizontal, 20)
                .padding(.bottom, 19)
                
                // ✅ Get Started Button
                Button(action: {
                    onGetStarted()   // ✅ navigate
                }) {
                    ZStack {
                        Image("btn_bg")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                        
                        Text(L10n.Intro.Three.getStarted)
                                .font(AppFont.nippoMedium(20))
                                .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 85)
            }
            .padding(.leading, 20)
        }
        .onAppear {
            animateSticker = true
        }
    }
}

struct Intro3View_Previews: PreviewProvider {
    static var previews: some View {
        Intro3View()
            .previewDevice("iPhone 14 Pro Max")
            .environmentObject(LocalizationManager.shared)
    }
}

