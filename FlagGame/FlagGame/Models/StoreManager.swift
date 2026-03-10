import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var purchaseState: PurchaseState = .idle
    @Published var product: Product?

    enum PurchaseState {
        case idle, purchasing, purchased, pending, failed(String)
    }

    private let productID = "com.flagexplorer.fullaccess"
    private let unlockedKey = "isUnlocked"
    private var transactionListener: Task<Void, Never>?

    init() {
        isUnlocked = UserDefaults.standard.bool(forKey: unlockedKey)
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        Task { await checkEntitlement() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Product

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product else {
            purchaseState = .failed("Product not available")
            return
        }
        purchaseState = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                unlock()
                purchaseState = .purchased
            case .pending:
                purchaseState = .pending
            case .userCancelled:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Restore

    func restore() async {
        try? await AppStore.sync()
        await checkEntitlement()
    }

    // MARK: - Entitlement

    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID {
                unlock()
                return
            }
        }
        if !isUnlocked {
            lock()
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    await self?.unlock()
                case .unverified:
                    break
                }
            }
        }
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verification
        case .verified(let value):
            return value
        }
    }

    // MARK: - State

    func unlock() {
        isUnlocked = true
        UserDefaults.standard.set(true, forKey: unlockedKey)
    }

    private func lock() {
        isUnlocked = false
        UserDefaults.standard.set(false, forKey: unlockedKey)
    }

    #if DEBUG
    func debugUnlock() {
        unlock()
    }
    func debugLock() {
        lock()
    }
    #endif

    enum StoreError: Error {
        case verification
    }
}
