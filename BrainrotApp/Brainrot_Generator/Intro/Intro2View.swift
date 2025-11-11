import SwiftUI

struct Intro2View: View {
    
    @State private var animateSticker = false   // ✅ animation trigger
    @State private var goNext = false           // ✅ navigation trigger
    
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
                    Text("Create your own rot!")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .offset(x: 3, y: 4) // bold shadow
                    
                    // Main white text
                    Text("Create your own rot!")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)
                .padding(.bottom, 19)

            

                // ✅ Next Button
                Button {
                    goNext = true
                } label: {
                    ZStack {
                        Image("btn_bg")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)

                        Text("Next")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 85)
            }
            .padding(.leading, 20)
            .navigationDestination(isPresented: $goNext) {
                Intro3View()
            }
        }
        .navigationBarBackButtonHidden(true)
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
            Intro2View()
                .previewDevice("iPhone 14 Pro Max")
        }
    }
}

