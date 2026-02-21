//
//  AnalyticsManager.swift
//  Wordly
//
//  Created by Kristoffer Melen on 17/02/2026.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
	
	static let shared = AnalyticsManager()
	
	func logGameStartedEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		Analytics.logEvent("game_started", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"game_mode": gameMode.rawValue
		])
	}
	
	func logGameEndedEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode, won: Bool, attemptsNeeded: Int, gameDurationSeconds: Int, currentStreak: Int) {
		Analytics.logEvent("game_ended", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"game_mode": gameMode.rawValue,
			"won": won,
			"attempts_needed": attemptsNeeded,
			"game_duration_seconds": gameDurationSeconds,
			"currentStreak": currentStreak
		])
	}
	
	func logDidTapWatchRewardedAdEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		Analytics.logEvent("did_tap_watch_rewarded_ad", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"game_mode": gameMode.rawValue
		])
	}
	
	func logDidLoadRewardedAdEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		Analytics.logEvent("did_load_rewarded_ad", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"game_mode": gameMode.rawValue
		])
	}
	
	func logDidUseSearchEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		Analytics.logEvent("did_use_search", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"game_mode": gameMode.rawValue
		])
	}
	
	func logDidUseSearchFiltersEvent(word: String, language: LanguageSelection, numberOfLetters: Int, gameMode: GameMode) {
		Analytics.logEvent("did_use_search_filters", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"game_mode": gameMode.rawValue
		])
	}
	
	func logDidTapActivateNotificationsEvent() {
		Analytics.logEvent("did_tap_activate_notifications", parameters: nil)
	}
	
	func logDidActivateNotificationsEvent() {
		Analytics.logEvent("did_activate_notifications", parameters: nil)
	}
	
	func logDidActivateAReminderEvent() {
		Analytics.logEvent("did_activate_a_reminder", parameters: nil)
	}
	
	func logDidDeactivateAReminderEvent() {
		Analytics.logEvent("did_deactivate_a_reminder", parameters: nil)
	}
	
	func logDidChangeThemeEvent(newTheme: AppTheme, oldTheme: AppTheme) {
		Analytics.logEvent("did_change_theme", parameters: [
			"new_theme": newTheme.rawValue,
			"old_theme": oldTheme.rawValue
		])
	}
	
	func logDidChangeDailyWordThemeEvent(newTheme: String) {
		Analytics.logEvent("did_change_dailyword_theme", parameters: [
			"new_theme": newTheme
		])
	}
	
	func logDidViewWordDefinitionEvent(word: String, language: LanguageSelection, numberOfLetters: Int, viewSuccess: Bool) {
		Analytics.logEvent("did_view_word_definition", parameters: [
			"word": word,
			"language": language.rawValue,
			"number_of_letters": numberOfLetters,
			"viewSuccess": viewSuccess
		])
	}
}
