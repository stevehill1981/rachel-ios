//
//  IAPManager.swift
//  Rachel
//
//  Created by Assistant on 07/08/2025.
//

import StoreKit
import SwiftUI

// Product identifiers for themes
enum IAPProduct: String, CaseIterable {
    case midnightTheme = "xyz.stevehill.rachel.theme.midnight"
    case oceanTheme = "xyz.stevehill.rachel.theme.ocean"
    case allThemesBundle = "xyz.stevehill.rachel.themes.bundle"
    
    var themeId: String? {
        switch self {
        case .midnightTheme: return "midnight"
        case .oceanTheme: return "ocean"
        case .allThemesBundle: return nil
        }
    }
}

@MainActor
class IAPManager: ObservableObject {
    static let shared = IAPManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var productIDsToFetch: Set<String> {
        Set(IAPProduct.allCases.map { $0.rawValue })
    }
    
    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    // MARK: - StoreKit 2 Methods
    
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDsToFetch)
            isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            errorMessage = "Failed to load products"
            isLoading = false
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Unlock the appropriate theme
            if let iapProduct = IAPProduct(rawValue: product.id) {
                handlePurchase(of: iapProduct)
            }
            
            await transaction.finish()
            await updatePurchasedProducts()
            
        case .userCancelled:
            break
            
        case .pending:
            break
            
        @unknown default:
            break
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func updatePurchasedProducts() async {
        var purchased = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchased.insert(transaction.productID)
            } catch {
                print("Transaction verification failed")
            }
        }
        
        purchasedProductIDs = purchased
        
        // Update theme unlocks based on purchases
        for productID in purchased {
            if let iapProduct = IAPProduct(rawValue: productID) {
                handlePurchase(of: iapProduct)
            }
        }
    }
    
    func restorePurchases() async {
        await updatePurchasedProducts()
    }
    
    // MARK: - Theme Unlocking
    
    private func handlePurchase(of product: IAPProduct) {
        let themeManager = ThemeManager.shared
        
        switch product {
        case .midnightTheme:
            themeManager.unlockTheme(withId: "midnight")
        case .oceanTheme:
            themeManager.unlockTheme(withId: "ocean")
        case .allThemesBundle:
            themeManager.unlockAllThemes()
        }
    }
    
    // MARK: - Helpers
    
    func product(for themeId: String) -> Product? {
        products.first { product in
            IAPProduct(rawValue: product.id)?.themeId == themeId
        }
    }
    
    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
}

enum StoreError: Error {
    case failedVerification
}