//
//  StoreManager.swift
//  Wordly
//
//  Created by Kristoffer Melen on 23/05/2026.
//

import Foundation
import StoreKit

@MainActor
@Observable
final class StoreManager {
	static let proProductID = "SwoshEB.ThePhrase.pro"

	private(set) var isAdRemovalPurchased: Bool = false
	private(set) var adRemovalProduct: Product?
	private(set) var isPurchasing: Bool = false

	@ObservationIgnored private var transactionListener: Task<Void, Never>?

	init() {
		transactionListener = listenForTransactions()
		Task {
			await updatePurchaseStatus()
			await loadProducts()
		}
	}

	deinit {
		transactionListener?.cancel()
	}

	func loadProducts() async {
		do {
			let products = try await Product.products(for: [Self.proProductID])
			adRemovalProduct = products.first
			if adRemovalProduct == nil {
				print("StoreManager: No product found for ID '\(Self.proProductID)'. Ensure the StoreKit configuration is set in the scheme.")
			}
		} catch {
			print("Failed to load products: \(error)")
		}
	}

	func purchaseAdRemoval() async {
		guard let product = adRemovalProduct else { return }
		isPurchasing = true
		defer { isPurchasing = false }

		do {
			let result = try await product.purchase()
			switch result {
				case .success(let verification):
					if case .verified(let transaction) = verification {
						await transaction.finish()
						await updatePurchaseStatus()
						AnalyticsManager.shared.logDidBuyProEvent()
					}
				case .userCancelled, .pending:
					break
				@unknown default:
					break
			}
		} catch {
			print("Purchase failed: \(error)")
		}
	}

	func restorePurchases() async {
		try? await AppStore.sync()
		await updatePurchaseStatus()
	}

	func updatePurchaseStatus() async {
		for await result in Transaction.currentEntitlements {
			if case .verified(let transaction) = result,
			   transaction.productID == Self.proProductID {
				isAdRemovalPurchased = true
				return
			}
		}
		isAdRemovalPurchased = false
	}

	private func listenForTransactions() -> Task<Void, Never> {
		Task.detached {
			for await result in Transaction.updates {
				if case .verified(let transaction) = result {
					await transaction.finish()
					await self.updatePurchaseStatus()
				}
			}
		}
	}
}
