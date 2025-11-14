import SwiftUI

struct Intro1View: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    var onNext: () -> Void = {}
    
    @State private var animateSticker = false
    
    var body: some View {
        ZStack {

            // Background
            Image("intro_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {

                Spacer().frame(height: 40)

                // ✅ Character + Sticker Group
                ZStack(alignment: .topLeading) {

                    // Character / Yellow oval
                    Image("character_intro")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260)

                    // ✅ Sticker with animation
                    Image("mamma_mia")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .padding(.leading, -50)
                        .padding(.top, -30)
                        .scaleEffect(animateSticker ? 1 : 0.1)       // scale 0 → 1
                        .opacity(animateSticker ? 1 : 0)             // fade in
                        .offset(x: animateSticker ? 0 : 40,          // slight movement
                                y: animateSticker ? 0 : 40)
                        .animation(.spring(response: 0.6,
                                           dampingFraction: 0.55,
                                           blendDuration: 0.2)
                                  .delay(0.3), value: animateSticker)
                }

                IntroTitleText(text: L10n.Intro.One.title, fontSize: 30)
                .padding(.top, 12)
                .padding(.horizontal, 20)
                .padding(.bottom, 19)

                // ✅ Next Button
                Button {
                    onNext()
                } label: {
                    ZStack {
                        Image("btn_bg")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)

                        Text(L10n.Intro.next)
                            .font(AppFont.nippoMedium(20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 85)
            }
        }
        .onAppear {
            animateSticker = true   // ✅ run animation
        }
    }
}

struct Intro1View_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Intro1View()
                .previewDevice("iPhone SE (3rd generation)")
                .environmentObject(LocalizationManager.shared)
            Intro1View()
                .previewDevice("iPhone 14 Pro Max")
                .environmentObject(LocalizationManager.shared)
        }
    }
}

