import SwiftUI

struct Intro3View: View {
    
    @State private var animateSticker = false      // ✅ animation trigger
    @State private var goToHome = false            // ✅ navigation trigger
    
    var body: some View {
        NavigationStack {   // ✅ enables navigation
            
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
                    ZStack {
                        Text("Share,Break, Go Viral!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .offset(x: 3, y: 4)

                        Text("Share,Break, Go Viral!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 19)

                    // ✅ Hidden NavLink to HomeView
                    NavigationLink(destination: HomeView(), isActive: $goToHome) {
                        EmptyView()
                    }.hidden()

                    // ✅ Get Started Button
                    Button(action: {
                        goToHome = true   // ✅ navigate
                    }) {
                        ZStack {
                            Image("btn_bg")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)

                            Text("Get Started")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 85)
                }
                .padding(.leading, 20)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                animateSticker = true
            }
        }
    }
}

struct Intro3View_Previews: PreviewProvider {
    static var previews: some View {
        Intro3View()
            .previewDevice("iPhone 14 Pro Max")
    }
}

