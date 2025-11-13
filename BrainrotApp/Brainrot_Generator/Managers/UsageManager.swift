import Foundation
import FirebaseCore
import FirebaseFirestore

@MainActor
final class UsageManager: ObservableObject {
    
    struct UsageQuota {
        var total: Int
        var used: Int
        var subscriptionType: String
    }
    
    enum UsageError: LocalizedError {
        case notConfigured
        case quotaExceeded
        
        var errorDescription: String? {
            switch self {
            case .notConfigured:
                return "Usage manager is not configured."
            case .quotaExceeded:
                return "You have reached your image limit."
            }
        }
    }
    
    @Published private(set) var quota = UsageQuota(total: 0, used: 0, subscriptionType: "free")
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var lastError: Error?
    
    var remaining: Int {
        max(quota.total - quota.used, 0)
    }
    
    var canGenerate: Bool {
        quota.total > 0 && quota.used < quota.total
    }
    
    private let db: Firestore?
    private var userID: String?
    private var listener: ListenerRegistration?
    
    init(firestore: Firestore? = nil) {
        if let firestore {
            self.db = firestore
        } else if FirebaseApp.app() != nil {
            self.db = Firestore.firestore()
        } else {
            self.db = nil
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    func configure(for userID: String) async {
        guard self.userID != userID else { return }
        self.userID = userID
        listener?.remove()
        
        guard db != nil else {
            quota = UsageQuota(total: 1, used: 0, subscriptionType: "free")
            isLoading = false
            return
        }
        
        await loadUsage(for: userID)
        listenForChanges(for: userID)
    }
    
    func consumeCreditIfAvailable() async throws {
        guard let userID = userID else { throw UsageError.notConfigured }
        guard db != nil else { return }
        guard canGenerate else { throw UsageError.quotaExceeded }
        
        quota = UsageQuota(total: quota.total, used: quota.used + 1, subscriptionType: quota.subscriptionType)
        
        do {
            try await usageDocument(for: userID)?.updateData([
                "used": FieldValue.increment(Int64(1)),
                "updatedAt": FieldValue.serverTimestamp()
            ])
            lastError = nil
        } catch {
            // Roll back on failure
            quota = UsageQuota(total: quota.total, used: max(quota.used - 1, 0), subscriptionType: quota.subscriptionType)
            lastError = error
            throw error
        }
    }
    
    func applySubscription(_ plan: SubscriptionPlan) async throws {
        guard let userID = userID else { throw UsageError.notConfigured }
        guard db != nil else {
            quota = UsageQuota(total: plan.imageQuota, used: 0, subscriptionType: plan.rawValue)
            return
        }
        quota = UsageQuota(total: plan.imageQuota, used: 0, subscriptionType: plan.rawValue)
        try await usageDocument(for: userID)?.setData([
            "total": plan.imageQuota,
            "used": 0,
            "subscriptionType": plan.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        lastError = nil
    }
    
    func resetToFreeTier() async throws {
        guard let userID = userID else { throw UsageError.notConfigured }
        guard db != nil else {
            quota = UsageQuota(total: 1, used: 0, subscriptionType: "free")
            return
        }
        quota = UsageQuota(total: 1, used: 0, subscriptionType: "free")
        try await usageDocument(for: userID)?.setData([
            "total": 1,
            "used": 0,
            "subscriptionType": "free",
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        lastError = nil
    }
    
    // MARK: - Private
    
    private func usageDocument(for userID: String) -> DocumentReference? {
        guard let db else { return nil }
        return db.collection("users")
            .document(userID)
            .collection("metadata")
            .document("usage")
    }
    
    private func loadUsage(for userID: String) async {
        isLoading = true
        defer { isLoading = false }
        guard let docRef = usageDocument(for: userID) else {
            quota = UsageQuota(total: 1, used: 0, subscriptionType: "free")
            return
        }
        
        do {
            let snapshot = try await docRef.getDocument()
            if let data = snapshot.data() {
                apply(data: data)
            } else {
                try await docRef.setData([
                    "total": 1,
                    "used": 0,
                    "subscriptionType": "free",
                    "updatedAt": FieldValue.serverTimestamp()
                ])
                quota = UsageQuota(total: 1, used: 0, subscriptionType: "free")
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    private func listenForChanges(for userID: String) {
        guard let docRef = usageDocument(for: userID) else { return }
        listener = docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let data = snapshot?.data() {
                Task { @MainActor in
                    self.apply(data: data)
                }
            } else if let error {
                Task { @MainActor in
                    self.lastError = error
                }
            }
        }
    }
    
    private func apply(data: [String: Any]) {
        let total = data["total"] as? Int ?? quota.total
        let used = data["used"] as? Int ?? quota.used
        let subscription = data["subscriptionType"] as? String ?? quota.subscriptionType
        quota = UsageQuota(total: total, used: used, subscriptionType: subscription)
        lastError = nil
        isLoading = false
    }
}


