import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    @Published private(set) var isUnlocked: Bool = false
    @Published private(set) var product: Product?
    @Published private(set) var purchaseState: PurchaseState = .idle

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case purchased
        case pending
        case failed(String)
    }

    static let productID = "com.flagexplorer.fullaccess"

    private var transactionListener: Task<Void, Error>?

    init() {
        isUnlocked = UserDefaults.standard.bool(forKey: "isFullAccessUnlocked")

        transactionListener = listenForTransactions()

        Task {
            await loadProduct()
            await checkEntitlement()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Product

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            print("Failed to load product: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product else {
            purchaseState = .failed("Product not available. Check your connection.")
            return
        }

        purchaseState = .purchasing

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    unlock()
                case .unverified:
                    purchaseState = .failed("Purchase could not be verified.")
                }

            case .userCancelled:
                purchaseState = .idle

            case .pending:
                purchaseState = .pending

            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed("Purchase failed. Please try again.")
        }
    }

    // MARK: - Restore

    func restorePurchase() async {
        purchaseState = .purchasing

        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID {
                await transaction.finish()
                unlock()
                found = true
                break
            }
        }

        if !found {
            purchaseState = .failed("No previous purchase found.")
        }
    }

    // MARK: - Check Entitlement

    func checkEntitlement() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID {
                entitled = true
                await transaction.finish()
                break
            }
        }

        if entitled {
            unlock()
        } else if isUnlocked {
            // Handle refund: was unlocked but no longer entitled
            lock()
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.checkEntitlement()
                }
            }
        }
    }

    // MARK: - State Updates

    private func unlock() {
        isUnlocked = true
        UserDefaults.standard.set(true, forKey: "isFullAccessUnlocked")
        purchaseState = .purchased
    }

    private func lock() {
        isUnlocked = false
        UserDefaults.standard.set(false, forKey: "isFullAccessUnlocked")
        purchaseState = .idle
    }

    // MARK: - Debug

    #if DEBUG
    func debugUnlock() {
        unlock()
    }

    func debugLock() {
        lock()
    }
    #endif
}
