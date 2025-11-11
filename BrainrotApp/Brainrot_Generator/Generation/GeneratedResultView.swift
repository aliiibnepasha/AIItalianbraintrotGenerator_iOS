import SwiftUI

struct GeneratedResultView: View {
    
    var onShare: () -> Void = {}
    var onGenerateAgain: () -> Void = {}
    
    private let bgColor = Color(hex: "#FBEEE3")
    private let previewImageName = "generated_placeholder"
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    header
                    
                    generatedPreview
                    
                    VStack(spacing: 16) {
                        ShareButton(action: onShare)
                        GenerateAgainButton(action: onGenerateAgain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                Spacer()
            }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var header: some View {
        HStack {
            BackButton(action: onGenerateAgain)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            .opacity(0) // Hidden placeholder for layout symmetry
        }
        .overlay(
            Text("Ai Brainrot")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.black)
        )
    }
    
    private var generatedPreview: some View {
        Image(previewImageName)
            .resizable()
            .scaledToFill()
            .frame(height: 260)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.black, lineWidth: 6)
            )
            .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 14)
    }
}

// MARK: - Components

private struct ShareButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.black, lineWidth: 4)
                    )
                    .frame(height: 60)
                
                Text("Share")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct GenerateAgainButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 3)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

private struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

struct GeneratedResultView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratedResultView()
            .previewDevice("iPhone 14 Pro")
    }
}


