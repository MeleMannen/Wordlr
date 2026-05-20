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
		if firstLaunchTime == 0 {
			firstLaunchTime = Date().timeIntervalSince1970
		}
	}
	
	func checkForReviewPrompt() {
		let now = Date().timeIntervalSince1970
		let day: TimeInterval = 24 * 60 * 60
		
		if firstLaunchTime == 0 {
			firstLaunchTime = now
			return
		}
		
		let appAge = now - firstLaunchTime
		let timeSinceLastPrompt = now - self.lastReviewPrompt
		
		var shouldPrompt = false
		
		switch numberOfTimesAskedBefore {
		case 0:
			// Never prompted before: at least 14 days of app age
			shouldPrompt = appAge >= 14 * day
		case 1:
			// Prompted once before: at least 40 days of app age
			shouldPrompt = appAge >= 50 * day
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
			AnalyticsManager.shared.logReviewPromptShownEvent(timesAskedBefore: self.numberOfTimesAskedBefore)
			SKStoreReviewController.requestReview(in: windowScene)
			self.numberOfTimesAskedBefore += 1
		} else {
			print("Failed to request review: No active window scene found.")
		}
	}
}
