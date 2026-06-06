//
//  NotificationManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 21/08/2025.
//


import UserNotifications
import UIKit
import SwiftData

final class NotificationManager {
	struct PayloadKeys {
		static let reminderId = "reminderId"
		static let languageName = "languageName"
		static let numberOfLetters = "numberOfLetters"
	}

	private struct ReminderSnapshot {
		let id: UUID
		let language: LanguageSelection
		let numberOfLetters: Int
		let timeToFire: Date
	}

	private struct ReminderSchedulingContext {
		let playedDayIdentifiers: Set<String>
		let currentStreak: Int
	}

	private static var dailyWordCalendar: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "CET")!
		return calendar
	}

	private static func performOnMain<T>(_ work: @MainActor () throws -> T) rethrows -> T {
		if Thread.isMainThread {
			return try MainActor.assumeIsolated {
				try work()
			}
		}

		return try DispatchQueue.main.sync {
			try MainActor.assumeIsolated {
				try work()
			}
		}
	}
	
	static func fetchReminders(context: ModelContext) -> [DailyWordReminder] {
		do {
			let reminders = try performOnMain {
				try context.fetch(FetchDescriptor<DailyWordReminder>())
			}
			return reminders
		} catch let error {
			print("Error fetching reminders: \(error.localizedDescription)")
		}
		return []
	}

	static func fetchGameRecords(context: ModelContext) -> [GameRecordEntity] {
		do {
			return try performOnMain {
				try context.fetch(FetchDescriptor<GameRecordEntity>())
			}
		} catch let error {
			print("Error fetching game records: \(error.localizedDescription)")
		}
		return []
	}
	
	static func requestPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
		print("Requesting notification permission...")
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			DispatchQueue.main.async {
				switch settings.authorizationStatus {
				case .authorized, .provisional, .ephemeral:
					print("Notification permission already granted.")
					completion(.success(true))
				case .denied:
					print("Notification permission denied.")
					AnalyticsManager.shared.logNotificationPermissionDeniedEvent()
					completion(.failure(NSError(domain: "NotificationPermission", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notification permission denied"])))
				case .notDetermined:
					print("Notification permission not determined.")
					AnalyticsManager.shared.logDidTapActivateNotificationsEvent()
					UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
						DispatchQueue.main.async {
							if granted {
								AnalyticsManager.shared.logDidActivateNotificationsEvent()
								completion(.success(true))
							} else {
								AnalyticsManager.shared.logNotificationPermissionDeniedEvent()
								completion(.failure(error ?? NSError(domain: "NotificationPermission", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notification permission denied"])))
							}
						}
					}
				@unknown default:
					print("Unknown authorization status: \(settings.authorizationStatus)")
					completion(.success(false))
				}
			}
		}
	}
	
	private static func reminderSnapshot(for reminder: DailyWordReminder) -> ReminderSnapshot {
		performOnMain {
			ReminderSnapshot(
				id: reminder.id,
				language: reminder.language,
				numberOfLetters: reminder.numberOfLetters,
				timeToFire: reminder.timeToFire
			)
		}
	}

	private static func requestId(for reminderId: UUID, on date: Date) -> String {
		let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
		let y = comps.year ?? 0, m = comps.month ?? 0, d = comps.day ?? 0
		return "daily-word-reminder-\(reminderId.uuidString)-\(y)-\(m)-\(d)"
	}

	private static func makeSchedulingContext(for reminder: ReminderSnapshot, context: ModelContext) -> ReminderSchedulingContext {
		let calendar = dailyWordCalendar
		let gameRecords = fetchGameRecords(context: context)
		let playedDayIdentifiers = Set<String>(
			gameRecords.compactMap { record in
				guard
					record.gameRecord.mode == .dailyWord,
					record.gameRecord.language == reminder.language,
					record.gameRecord.numberOfLetters == reminder.numberOfLetters
				else {
					return nil
				}

				return dayIdentifier(for: record.gameRecord.date, calendar: calendar)
			}
		)
		let currentStreak = GameRecordStreakCalculator.dailySummary(
			records: gameRecords,
			language: reminder.language,
			numberOfLetters: reminder.numberOfLetters
		).currentStreak
		return ReminderSchedulingContext(
			playedDayIdentifiers: playedDayIdentifiers,
			currentStreak: currentStreak
		)
	}

	private static func dayIdentifier(for date: Date, calendar: Calendar) -> String {
		let comps = calendar.dateComponents([.year, .month, .day], from: date)
		let year = comps.year ?? 0
		let month = comps.month ?? 0
		let day = comps.day ?? 0
		return "\(year)-\(month)-\(day)"
	}

	private static func didPlayDailyWord(on date: Date, playedDayIdentifiers: Set<String>) -> Bool {
		playedDayIdentifiers.contains(dayIdentifier(for: date, calendar: dailyWordCalendar))
	}

	private static func notificationBody(for reminder: ReminderSnapshot, streak: Int?) -> String {
		if let streak, streak >= 3 {
			return String(format: NSLocalizedString("Remember to play today's %d letter, %@ daily Wordlr to not lose your %d🔥 day streak.", comment: "Body for Daily Wordlr streak reminder notification"), reminder.numberOfLetters, reminder.language.localizedName, streak)
		}

		return String(
			format: NSLocalizedString("Don't forget to complete today's %d letter, %@ daily Wordlr", comment: "Body for Daily Wordlr reminder notification"),
			reminder.numberOfLetters,
			reminder.language.localizedName
		)
	}
	
	static func scheduleDailyWordReminder(reminder: DailyWordReminder, context: ModelContext? = nil, daysAhead: Int = 7) {
		let snapshot = reminderSnapshot(for: reminder)
		let schedulingContext = context.map { makeSchedulingContext(for: snapshot, context: $0) }
			?? ReminderSchedulingContext(playedDayIdentifiers: [], currentStreak: 0)
		let center = UNUserNotificationCenter.current()
		
		center.getPendingNotificationRequests { requests in
			let now = Date()
			let reminderRequests = requests.filter { $0.identifier.contains(snapshot.id.uuidString) }
			let reminderRequestIds = reminderRequests.map(\.identifier)
			if !reminderRequestIds.isEmpty {
				center.removePendingNotificationRequests(withIdentifiers: reminderRequestIds)
			}
			
			let title = NSLocalizedString("Daily Wordlr reminder", comment: "Title for Daily Wordlr reminder notification")
			var requestsToAdd: [UNNotificationRequest] = []
			var didScheduleFirstEligibleReminder = false
			
			for day in 0...daysAhead {
				guard let baseDate = Calendar.current.date(byAdding: .day, value: day, to: Date()) else { continue }
				let timeComps = Calendar.current.dateComponents([.hour, .minute], from: snapshot.timeToFire)
				guard let hour = timeComps.hour, let minute = timeComps.minute else { continue }
				
				guard let fireDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate) else { continue }
				if fireDate <= now { continue }
				if didPlayDailyWord(on: fireDate, playedDayIdentifiers: schedulingContext.playedDayIdentifiers) { continue }
				
				let id = requestId(for: snapshot.id, on: fireDate)
				let content = UNMutableNotificationContent()
				content.title = title
				content.body = notificationBody(
					for: snapshot,
					streak: (!didScheduleFirstEligibleReminder && schedulingContext.currentStreak >= 3) ? schedulingContext.currentStreak : nil
				)
				content.sound = .default
				content.userInfo = [
					PayloadKeys.reminderId: snapshot.id.uuidString,
					PayloadKeys.languageName: snapshot.language.rawValue,
					PayloadKeys.numberOfLetters: snapshot.numberOfLetters
				]
				
				let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
				let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
				
				let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
				requestsToAdd.append(req)
				didScheduleFirstEligibleReminder = true
			}
			
			for req in requestsToAdd {
				center.add(req) { error in
					if let error = error { print("Error scheduling notification: \(error)") }
				}
			}
			
			center.getPendingNotificationRequests { after in
				print("Pending notifications after scheduling:")
				for r in after {
					if let trigger = r.trigger as? UNCalendarNotificationTrigger,
					   let date = trigger.nextTriggerDate() {
						print("ID: \(r.identifier), Date: \(date)")
					}
				}
			}
		}
	}
	
	static func cancelTodayNotification(reminder: DailyWordReminder) {
		let id = requestId(for: reminder.id, on: Date())
		let center = UNUserNotificationCenter.current()
		center.removePendingNotificationRequests(withIdentifiers: [id])
	}
	
	static func cancelDailyWordReminder(reminder: DailyWordReminder) {
		let reminderId = reminder.id.uuidString
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { requests in
			let ids = requests
				.filter { $0.identifier.contains(reminderId) }
				.map { $0.identifier }
			
			print("Cancelling notifications with IDs: \(ids)")
			center.removePendingNotificationRequests(withIdentifiers: ids)
		}
//		center.removeAllPendingNotificationRequests()
//		center.getPendingNotificationRequests { requests in
//			print("Pending notifications after cancel: \(requests)")
//		}
	}
	
	static func cancelDailyWordReminder(reminder: DailyWordReminder, withCompletionHandler completion: @escaping () -> Void) {
		let reminderId = reminder.id.uuidString
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { requests in
			let ids = requests
				.filter { $0.identifier.contains(reminderId) }
				.map { $0.identifier }
			
			print("Cancelling notifications with IDs: \(ids)")
			center.removePendingNotificationRequests(withIdentifiers: ids)
			completion()
		}
	}
}

final class NotificationsDelegate: NSObject, UNUserNotificationCenterDelegate {
	static let shared = NotificationsDelegate()
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		let info = response.notification.request.content.userInfo
		let languageName = info[NotificationManager.PayloadKeys.languageName] as? String
		let numberOfLetters = info[NotificationManager.PayloadKeys.numberOfLetters] as? Int
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.00001) {
			AppState.shared.applyReminder(languageName: languageName, numberOfLetters: numberOfLetters)
			print("Received notification with language: \(languageName ?? "unknown"), numberOfLetters: \(numberOfLetters ?? 0)")
			completionHandler()
		}
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//		let info = notification.request.content.userInfo
//		let languageName = info[NotificationManager.PayloadKeys.languageName] as? String
//		let numberOfLetters = info[NotificationManager.PayloadKeys.numberOfLetters] as? Int
		
//		AppState.shared.applyReminder(languageName: languageName, numberOfLetters: numberOfLetters)
//		print("Received notification with language: \(languageName ?? "unknown"), numberOfLetters: \(numberOfLetters ?? 0)")
		completionHandler([.banner, .sound, .badge])
	}
}
