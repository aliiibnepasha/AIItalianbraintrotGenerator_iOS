import Foundation

/// Centralized localization helper. Add new keys to the nested enums below and
/// remember to provide translations in each `Localizable.strings` file.
enum L10n {
    
    // MARK: - Helpers
    
    private static func bundle() -> Bundle {
        LocalizationManager.shared.bundle
    }
    
    private static func tr(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: bundle(), comment: "")
    }
    
    private static func tr(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: nil, bundle: bundle(), comment: "")
        return String(format: format, locale: LocalizationManager.shared.locale, arguments: args)
    }
    
    static func string(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, comment: comment)
    }
    
    // MARK: - App
    
    enum App {
        static var name: String { tr("app_name") }
    }
    
    // MARK: - Common
    
    enum Common {
        static var ok: String { tr("common.ok") }
        static var share: String { tr("common.share") }
        static var delete: String { tr("common.delete") }
        static var favorite: String { tr("common.favorite") }
        static var favorited: String { tr("common.favorited") }
        static var generate: String { tr("common.generate") }
        static var generateAgain: String { tr("common.generate_again") }
        static var language: String { tr("common.language") }
        static var done: String { tr("common.done") }
        static var restore: String { tr("common.restore") }
        static var termsOfUse: String { tr("common.terms_of_use") }
        static var privacyPolicy: String { tr("common.privacy_policy") }
        static var getPremium: String { tr("common.get_premium") }
        static var home: String { tr("common.home") }
        static var setting: String { tr("common.setting") }
    }
    
    // MARK: - Splash & Intro
    
    enum Splash {
        static var title: String { tr("splash.title") }
    }
    
    enum Intro {
        static var next: String { tr("intro.next") }
        
        enum One {
            static var title: String { tr("intro1.title") }
        }
        
        enum Two {
            static var title: String { tr("intro2.title") }
        }
        
        enum Three {
            static var title: String { tr("intro3.title") }
            static var getStarted: String { tr("intro3.get_started") }
        }
    }
    
    // MARK: - Home
    
    enum Home {
        static var headerTitle: String { tr("home.header_title") }
        static var placeholder: String { tr("home.placeholder") }
        static var lastGenerated: String { tr("home.last_generated") }
        static var lastGeneratedEmpty: String { tr("home.last_generated_empty") }
        static var favorites: String { tr("home.favorites") }
        static var favoritesEmpty: String { tr("home.favorites_empty") }
        static var alertMissingKeywords: String { tr("home.alert.missing_keywords") }
        static var alertGenerationFailed: String { tr("home.alert.generation_failed") }
        static var tabHome: String { tr("home.tab.home") }
        static var tabSettings: String { tr("home.tab.settings") }
        static var quotaLabel: String { tr("home.quota_label") }
        static var quotaLoading: String { tr("home.quota_loading") }
    }
    
    // MARK: - Generate Details
    
    enum GenerateDetails {
        static var headerTitle: String { tr("generate.header_title") }
        static var sectionGender: String { tr("generate.section.gender") }
        static var sectionMood: String { tr("generate.section.mood") }
        static var sectionAccent: String { tr("generate.section.accent") }
        static var sectionOutfit: String { tr("generate.section.outfit") }
        static var sectionAspect: String { tr("generate.section.aspect") }
        
        static var genderMale: String { tr("generate.gender.male") }
        static var genderFemale: String { tr("generate.gender.female") }
        static var genderMixed: String { tr("generate.gender.mixed") }
        static var genderChaos: String { tr("generate.gender.chaos") }
        
        static var moodRomantic: String { tr("generate.mood.romantic") }
        static var moodMafia: String { tr("generate.mood.mafia") }
        static var moodCafe: String { tr("generate.mood.cafe") }
        static var moodTiktok: String { tr("generate.mood.tiktok") }
        
        static var outfitVintage: String { tr("generate.outfit.vintage") }
        static var outfitModern: String { tr("generate.outfit.modern") }
        static var outfitMeme: String { tr("generate.outfit.meme") }
        
        static var sliderLow: String { tr("generate.slider.low") }
        static var sliderHigh: String { tr("generate.slider.high") }
        
        static var defaultTitle: String { tr("generate.default_title") }
        static var defaultCharacter: String { tr("generate.default_character") }
        
        static func summary(mood: String, outfit: String, aspect: String) -> String {
            tr("generate.summary_format", mood, outfit, aspect)
        }
    }
    
    // MARK: - Generating
    
    enum Generating {
        static var status: String { tr("generating.status") }
    }
    
    // MARK: - Generated Result & Detail
    
    enum Result {
        static var title: String { tr("result.title") }
    }
    
    // MARK: - Gallery
    
    enum Gallery {
        static var title: String { tr("gallery.title") }
        static var emptyTitle: String { tr("gallery.empty_title") }
        static var emptySubtitle: String { tr("gallery.empty_subtitle") }
    }
    
    // MARK: - Settings
    
    enum Settings {
        static var title: String { tr("settings.title") }
        static var language: String { tr("settings.language") }
        static var termsOfService: String { tr("settings.terms_of_service") }
        static var communityGuidelines: String { tr("settings.community_guidelines") }
        static var creations: String { tr("settings.creations") }
    }
    
    // MARK: - Language Selection
    
    enum Language {
        static var title: String { tr("language.title") }
        static var done: String { tr("language.done") }
        
        static var english: String { tr("language.name.english") }
        static var korean: String { tr("language.name.korean") }
        static var italian: String { tr("language.name.italian") }
        static var japanese: String { tr("language.name.japanese") }
        
        static func displayName(for value: String) -> String {
            switch value {
            case "en", "English": return english
            case "ko", "Korean": return korean
            case "it", "Italian": return italian
            case "ja", "Japanese": return japanese
            default: return value
            }
        }
    }
    
    // MARK: - Paywall
    
    enum Paywall {
        static var heroTitle: String { tr("paywall.hero_title") }
        static var benefitFasterResults: String { tr("paywall.benefit.faster_results") }
        static var benefitUnlockPremium: String { tr("paywall.benefit.unlock_premium") }
        static var benefitUnlimitedMemes: String { tr("paywall.benefit.unlimited_memes") }
        static var benefitNonstopChaos: String { tr("paywall.benefit.nonstop_chaos") }
        static var freeTrial: String { tr("paywall.free_trial") }
        static var weeklyPlan: String { tr("paywall.plan.weekly") }
        static var monthlyPlan: String { tr("paywall.plan.monthly") }
        static var monthlySubtitle: String { tr("paywall.plan.monthly_subtitle") }
        static var bestValueBadge: String { tr("paywall.plan.badge") }
        static var subscribe: String { tr("paywall.subscribe") }
        static var legal: String { tr("paywall.legal") }
        static var restore: String { tr("paywall.restore") }
        static var terms: String { tr("paywall.terms") }
        static var privacy: String { tr("paywall.privacy") }
    }
    
    // MARK: - Service Errors
    
    enum ServiceError {
        static var unexpectedResponse: String { tr("service_error.unexpected_response") }
        static func statusWithMessage(_ status: String, _ message: String) -> String {
            tr("service_error.status_with_message", status, message)
        }
        static var missingURL: String { tr("service_error.missing_url") }
        static var invalidImageData: String { tr("service_error.invalid_image_data") }
        static var downloadFailed: String { tr("service_error.download_failed") }
        static var unknownError: String { tr("service_error.unknown_error") }
        static var noResponseBody: String { tr("service_error.no_response") }
    }
}


