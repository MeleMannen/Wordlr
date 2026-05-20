//
//  AnalyticsManager.swift
//  Wordlr
//
//  Created by Kristoffer Melen on 17/02/2026.
//

import Foundation
import FirebaseAnalytics
import TelemetryDeck
import PostHog

final class AnalyticsManager {

	static let shared = AnalyticsManager()

	func logGameStartedEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		let parameters: [String: String] = [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": "\(numberOfLetters)",
			"game_mode": gameMode.rawValue
		]
		Analytics.logEvent("game_started", parameters: parameters)
		TelemetryDeck.signal("game_started", parameters: parameters)
		PostHogSDK.shared.capture("game_started", properties: parameters)
	}

	func logGameEndedEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode, won: Bool, attemptsNeeded: Int, gameDurationSeconds: Int, currentStreak: Int) {
		Analytics.logEvent("game_ended", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"game_mode": gameMode.rawValue,
			"won": won ? "true" : "false",
			"won_numeric" : won ? 1 : 0,
			"attempts_needed": attemptsNeeded,
			"game_duration_seconds": gameDurationSeconds,
			"current_streak": currentStreak
		])
		let tdAndPhParameters: [String: String] = [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": "\(numberOfLetters)",
			"game_mode": gameMode.rawValue,
			"won": won ? "true" : "false",
			"attempts_needed": "\(attemptsNeeded)",
			"game_duration_seconds": "\(gameDurationSeconds)",
			"current_streak": "\(currentStreak)"
		]
		TelemetryDeck.signal("game_ended", parameters: tdAndPhParameters)
		PostHogSDK.shared.capture("game_ended", properties: tdAndPhParameters)
	}

	func logDidTapWatchRewardedAdEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		let parameters: [String: String] = [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": "\(numberOfLetters)",
			"game_mode": gameMode.rawValue
		]
		Analytics.logEvent("did_tap_watch_rewarded_ad", parameters: parameters)
		TelemetryDeck.signal("did_tap_watch_rewarded_ad", parameters: parameters)
		PostHogSDK.shared.capture("did_tap_watch_rewarded_ad", properties: parameters)
	}

	func logDidLoadRewardedAdEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		let parameters: [String: String] = [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": "\(numberOfLetters)",
			"game_mode": gameMode.rawValue
		]
		Analytics.logEvent("did_load_rewarded_ad", parameters: parameters)
		TelemetryDeck.signal("did_load_rewarded_ad", parameters: parameters)
		PostHogSDK.shared.capture("did_load_rewarded_ad", properties: parameters)
	}

	func logDidUseSearchEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		let parameters: [String: String] = [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": "\(numberOfLetters)",
			"game_mode": gameMode.rawValue
		]
		Analytics.logEvent("did_use_search", parameters: parameters)
		TelemetryDeck.signal("did_use_search", parameters: parameters)
		PostHogSDK.shared.capture("did_use_search", properties: parameters)
	}

	func logDidUseSearchFiltersEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		let parameters: [String: String] = [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": "\(numberOfLetters)",
			"game_mode": gameMode.rawValue
		]
		Analytics.logEvent("did_use_search_filters", parameters: parameters)
		TelemetryDeck.signal("did_use_search_filters", parameters: parameters)
		PostHogSDK.shared.capture("did_use_search_filters", properties: parameters)
	}

	func logDidTapActivateNotificationsEvent() {
		Analytics.logEvent("did_tap_activate_notifications", parameters: nil)
		TelemetryDeck.signal("did_tap_activate_notifications")
		PostHogSDK.shared.capture("did_tap_activate_notifications")
	}

	func logDidActivateNotificationsEvent() {
		Analytics.logEvent("did_activate_notifications", parameters: nil)
		TelemetryDeck.signal("did_activate_notifications")
		PostHogSDK.shared.capture("did_activate_notifications")
	}

	func logNotificationPermissionDeniedEvent() {
		Analytics.logEvent("notification_permission_denied", parameters: nil)
		TelemetryDeck.signal("notification_permission_denied")
		PostHogSDK.shared.capture("notification_permission_denied")
	}

	func logDidActivateAReminderEvent() {
		Analytics.logEvent("did_activate_a_reminder", parameters: nil)
		TelemetryDeck.signal("did_activate_a_reminder")
		PostHogSDK.shared.capture("did_activate_a_reminder")
	}

	func logDidDeactivateAReminderEvent() {
		Analytics.logEvent("did_deactivate_a_reminder", parameters: nil)
		TelemetryDeck.signal("did_deactivate_a_reminder")
		PostHogSDK.shared.capture("did_deactivate_a_reminder")
	}

	func logDidChangeThemeEvent(newTheme: AppTheme, oldTheme: AppTheme) {
		let parameters: [String: String] = [
			"new_theme": newTheme.rawValue,
			"old_theme": oldTheme.rawValue
		]
		Analytics.logEvent("did_change_theme", parameters: parameters)
		TelemetryDeck.signal("did_change_theme", parameters: parameters)
		PostHogSDK.shared.capture("did_change_theme", properties: parameters)
	}

	func logDidChangeDailyWordThemeEvent(newTheme: String) {
		let parameters: [String: String] = ["new_theme": newTheme]
		Analytics.logEvent("did_change_dailyword_theme", parameters: parameters)
		TelemetryDeck.signal("did_change_dailyword_theme", parameters: parameters)
		PostHogSDK.shared.capture("did_change_dailyword_theme", properties: parameters)
	}

	func logDidViewWordDefinitionEvent(word: String, language: LanguageSelection, numberOfLetters: Int, viewSuccess: Bool) {
		Analytics.logEvent("did_view_word_definition", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"viewSuccess": viewSuccess
		])
		let tdAndPhParameters: [String: String] = [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": "\(numberOfLetters)",
			"view_success": "\(viewSuccess)"
		]
		TelemetryDeck.signal("did_view_word_definition", parameters: tdAndPhParameters)
		PostHogSDK.shared.capture("did_view_word_definition", properties: tdAndPhParameters)
	}

	func logScreenViewed(screenName: String) {
		Analytics.logEvent(AnalyticsEventScreenView, parameters: [
			AnalyticsParameterScreenName: screenName,
			AnalyticsParameterScreenClass: screenName
		])
		TelemetryDeck.signal("screen_viewed", parameters: [
			"screen_name": screenName
		])
		PostHogSDK.shared.screen(screenName)
	}

	func logReviewPromptShownEvent(timesAskedBefore: Int) {
		let parameters: [String: String] = [
			"times_asked_before": "\(timesAskedBefore)"
		]
		Analytics.logEvent("review_prompt_shown", parameters: [
			"times_asked_before": timesAskedBefore
		])
		TelemetryDeck.signal("review_prompt_shown", parameters: parameters)
		PostHogSDK.shared.capture("review_prompt_shown", properties: parameters)
	}

	func logDidTapRateAppEvent() {
		Analytics.logEvent("did_tap_rate_app", parameters: nil)
		TelemetryDeck.signal("did_tap_rate_app")
		PostHogSDK.shared.capture("did_tap_rate_app")
	}
}
