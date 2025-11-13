import SwiftUI

struct LanguageSelectionView: View {
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Binding var selectedLanguageCode: String
    @State private var pendingSelection: String
    
    @Environment(\.dismiss) private var dismiss
    
    private let languageCodes: [String] = [
        "en",
        "ko",
        "it",
        "ja"
    ]
    
    init(selectedLanguageCode: Binding<String>) {
        self._selectedLanguageCode = selectedLanguageCode
        self._pendingSelection = State(initialValue: selectedLanguageCode.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                header
                    .padding(.top, 12)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(languageCodes, id: \.self) { code in
                            LanguageRow(title: L10n.Language.displayName(for: code),
                                        isSelected: code == pendingSelection)
                            .onTapGesture {
                                pendingSelection = code
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var header: some View {
        HStack {
            BackButton {
                dismiss()
            }
            
            Spacer()
            
            Button(L10n.Language.done) {
                selectedLanguageCode = pendingSelection
                dismiss()
            }
            .font(AppFont.nippoMedium(16))
            .fontWeight(.bold)
            .foregroundColor(.black)
        }
        .overlay(
            Text(L10n.Language.title)
                .font(AppFont.nippoMedium(32))
                .fontWeight(.black)
                .foregroundColor(.black)
        )
    }
}

// MARK: - Components

private struct LanguageRow: View {
    let title: String
    let isSelected: Bool
    
    private let selectionColor = Color(hex: "#D7263D")
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.40))
                .frame(height: 60)
                .offset(y: 6)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? selectionColor : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 4)
                )
                .frame(height: 60)
                .overlay(rowContent)
        }
    }
    
    private var rowContent: some View {
        HStack {
            Text(title)
                .font(AppFont.nippoMedium(17))
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .black)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(AppFont.nippoMedium(18))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 22)
    }
}

private struct BackButton: View {
    var action: () -> Void
    
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
                    .font(AppFont.nippoMedium(16))
                    .fontWeight(.bold)
                            .foregroundColor(.black)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct LanguageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectionView(selectedLanguageCode: .constant("en"))
            .environmentObject(LocalizationManager.shared)
    }
}


