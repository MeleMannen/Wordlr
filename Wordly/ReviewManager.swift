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
	@AppStorage("numberOfTimesAskedBefore") private var numberOfTimesAskedBefore: Int = 0
	@AppStorage("firstLaunchTime") private var firstLaunchTime: TimeInterval = 0
	
	init() {
		// Initialize first launch timestamp if not set yet
		if firstLaunchTime == 0 {
			firstLaunchTime = Date().timeIntervalSince1970
		}
	}
	
	func checkForReviewPrompt() {
		let now = Date().timeIntervalSince1970
		let day: TimeInterval = 24 * 60 * 60
		
		// Ensure we have a first launch time; if not, set it and do not prompt immediately
		if firstLaunchTime == 0 {
			firstLaunchTime = now
			return
		}
		
		let appAge = now - firstLaunchTime
		let timeSinceLastPrompt = now - self.lastReviewPrompt
		
		var shouldPrompt = false
		
		switch numberOfTimesAskedBefore {
		case 0:
			// Never prompted before: at least 7 days of app age
			shouldPrompt = appAge >= 7 * day
		case 1:
			// Prompted once before: at least 30 days of app age
			shouldPrompt = appAge >= 30 * day
		case 2:
			// Prompted twice before: at least 180 days of app age
			shouldPrompt = appAge >= 180 * day
		default:
			// Prompted 3+ times: every 90 days since last prompt
			shouldPrompt = timeSinceLastPrompt >= 90 * day
		}
		
		if shouldPrompt {
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
