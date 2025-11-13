import Foundation

enum SubscriptionPlan: String, CaseIterable, Codable {
    case weekly
    case monthly
    
    var productID: String {
        switch self {
        case .weekly:
            return "com.theswiftvision.aiitalianbrainrotgenerator.weekly"
        case .monthly:
            return "com.theswiftvision.aiitalianbrainrotgenerator.Monthly"
        }
    }
    
    var imageQuota: Int {
        switch self {
        case .weekly:
            return 50
        case .monthly:
            return 160
        }
    }
    
    var displayName: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        }
    }
}


