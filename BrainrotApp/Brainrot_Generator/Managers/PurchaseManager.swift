import Foundation
import StoreKit

enum PurchaseError: LocalizedError {
    case productUnavailable
    case verificationFailed
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return "The selected product is currently unavailable."
        case .verificationFailed:
            return "Unable to verify the purchase."
        case .userCancelled:
            return "Purchase cancelled."
        case .pending:
            return "Purchase pending approval."
        case .unknown:
            return "An unknown purchase error occurred."
        }
    }
}

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published private(set) var products: [String: Product] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastError: Error?
    
    private init() {}
    
    func product(for id: String) -> Product? {
        products[id]
    }
    
    func product(for plan: SubscriptionPlan) -> Product? {
        products[plan.productID]
    }
    
    func ensureProducts(for plans: [SubscriptionPlan]) async {
        let ids = plans.map { $0.productID }
        await ensureProducts(with: ids)
    }
    
    func ensureProducts(with ids: [String]) async {
        let missing = ids.filter { products[$0] == nil }
        guard !missing.isEmpty else { return }
        await loadProducts(for: missing)
    }
    
    private func loadProducts(for ids: [String]) async {
        guard !ids.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetched = try await Product.products(for: ids)
            for product in fetched {
                products[product.id] = product
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }
    
    func purchase(plan: SubscriptionPlan) async throws -> Transaction {
        let product = try await productForPurchase(plan: plan)
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return transaction
        case .userCancelled:
            throw PurchaseError.userCancelled
        case .pending:
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    func listenForTransactions() {
        Task.detached { [weak self] in
            guard let self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }
                    await transaction.finish()
                } catch {
                    await MainActor.run {
                        self.lastError = error
                    }
                }
            }
        }
    }
    
    private func productForPurchase(plan: SubscriptionPlan) async throws -> Product {
        if let stored = product(for: plan) {
            return stored
        }
        await ensureProducts(for: [plan])
        if let stored = product(for: plan) {
            return stored
        }
        throw PurchaseError.productUnavailable
    }
    
    private func checkVerified(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .unverified(_, _):
            throw PurchaseError.verificationFailed
        case .verified(let transaction):
            return transaction
        }
    }
}

