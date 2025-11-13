import SwiftUI

struct Intro2View: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    var onNext: () -> Void = {}
    
    @State private var animateSticker = false   // ✅ animation trigger
    
    var body: some View {
        ZStack {

            // Background
            Image("Intro2_bg")
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

                    // ✅ Animated Sticker
                    Image("che_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .padding(.leading, -50)
                        .padding(.top, -30)
                        .scaleEffect(animateSticker ? 1 : 0.1)      // 0% → 100%
                        .opacity(animateSticker ? 1 : 0)            // fade in
                        .offset(x: animateSticker ? 0 : 40,         // slight move from bottom-right
                                y: animateSticker ? 0 : 40)
                        .animation(.spring(response: 0.6,
                                           dampingFraction: 0.55,
                                           blendDuration: 0.2)
                                  .delay(0.2), value: animateSticker)

                    // Character Overlay Image
                    Image("shark_1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 280)
                        .padding(.top, 25)
                }

                // ✅ Title with same heavy shadow as Intro1
                ZStack {
                    // Shadow layer (black)
                    Text(L10n.Intro.Two.title)
                        .font(AppFont.nippoMedium(28))
                        .fontWeight(.black)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .offset(x: 3, y: 4) // bold shadow
                    
                    // Main white text
                    Text(L10n.Intro.Two.title)
                        .font(AppFont.nippoMedium(28))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
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
            .padding(.leading, 20)
        }
        .onAppear {
            animateSticker = true   // ✅ run animation
        }
    }
}

struct Intro2View_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Intro2View()
                .previewDevice("iPhone SE (3rd generation)")
                .environmentObject(LocalizationManager.shared)
            Intro2View()
                .previewDevice("iPhone 14 Pro Max")
                .environmentObject(LocalizationManager.shared)
        }
    }
}

