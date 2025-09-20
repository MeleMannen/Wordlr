//
//  ReviewManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/08/2025.
//

import StoreKit
import SwiftUI

class ReviewManager: ObservableObject {
	@AppStorage("lastReviewPrompt") private var lastReviewPrompt: TimeInterval = 0
	@AppStorage("numberOfTimesAskedBefore") private var numberOfTimesAskedBefore: Int = 1
	
	func checkForReviewPrompt() {
		let currentTime = Date().timeIntervalSince1970
		let timeSinceLastPrompt = currentTime - self.lastReviewPrompt
		if timeSinceLastPrompt >= Double(1209600 + (10518975 * self.numberOfTimesAskedBefore)) {
			self.requestReview()
		}
	}
	
	private func requestReview() {
		self.lastReviewPrompt = Date().timeIntervalSince1970
		
		if let windowScene = UIApplication.shared.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
			SKStoreReviewController.requestReview(in: windowScene)
			self.numberOfTimesAskedBefore += 1
		} else {
			print("Failed to request review: No active window scene found.")
		}
	}
}
