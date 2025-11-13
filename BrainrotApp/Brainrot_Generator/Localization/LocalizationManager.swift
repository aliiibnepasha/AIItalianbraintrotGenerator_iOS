import Foundation
import Combine

final class LocalizationManager: ObservableObject {
    static let supportedCodes: [String] = ["en", "ko", "it", "ja"]
    private static let storageKey = "app.language"
    
    static let shared = LocalizationManager()
    
    @Published var languageCode: String {
        didSet {
            guard oldValue != languageCode else { return }
            UserDefaults.standard.set(languageCode, forKey: Self.storageKey)
        }
    }
    
    var locale: Locale {
        Locale(identifier: languageCode)
    }
    
    var bundle: Bundle {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return Bundle.main
    }
    
    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey)
        let resolved = LocalizationManager.resolveInitialLanguage(from: stored)
        languageCode = resolved
        if stored == nil {
            UserDefaults.standard.set(resolved, forKey: Self.storageKey)
        }
    }
    
    func setLanguage(_ code: String) {
        guard code != languageCode else { return }
        languageCode = LocalizationManager.resolveInitialLanguage(from: code)
    }
    
    private static func resolveInitialLanguage(from code: String?) -> String {
        if let code, supportedCodes.contains(code) {
            return code
        }
        // fallback to device preferred language if supported
        if let preferred = Locale.preferredLanguages
            .compactMap({ Locale(identifier: $0).languageCode })
            .first(where: { supportedCodes.contains($0) }) {
            return preferred
        }
        return "en"
    }
}


