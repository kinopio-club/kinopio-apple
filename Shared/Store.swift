import StoreKit

public enum StoreError: Error {
    case failedVerification
}

class Store: ObservableObject {
    static let shared = Store()
    
    func fetchProduct(identifier: String) async throws -> Product? {
        try await Product.products(for: [identifier]).first
    }
    
    func purchase(_ product: Product, appAccountToken: UUID) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase(options: [.appAccountToken(appAccountToken)])
        switch result {
            case .success(let verification):
                // Check whether the transaction is verified. If it isn't,
                // this function rethrows the verification error.
                let transaction = try checkVerified(verification)
                
                // The transaction is verified. Deliver content to the user.
                print("Purchase was successful!")
                
                await transaction.finish()
                
                return transaction
            case .userCancelled, .pending:
                return nil
            default:
                return nil
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
            case .unverified:
                // StoreKit parses the JWS, but it fails verification.
                throw StoreError.failedVerification
            case .verified(let safe):
                // The result is verified. Return the unwrapped value.
                return safe
        }
    }
    
}
