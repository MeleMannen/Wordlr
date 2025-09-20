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
	
	static func fetchReminders(context: ModelContext) -> [DailyWordReminder] {
		do {
			let reminders = try context.fetch(FetchDescriptor<DailyWordReminder>())
			return reminders
		} catch let error {
			print("Error fetching reminders: \(error.localizedDescription)")
		}
		return []
	}
	
	static func requestPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
			print(granted ? "Notification permission granted" : "Notification permission denied")
		}
	}
	
	static func scheduleDailyWordReminder(reminder: DailyWordReminder) {
		NotificationManager.cancelDailyWordReminder(reminder: reminder)
		
		let content = UNMutableNotificationContent()
		content.title = "Daily Word Reminder"
		content.body = "Don't forget to complete today's \(reminder.numberOfLetters) Letter \(reminder.language.localizedName) Daily Word!"
		content.sound = .default
		content.userInfo = [
			PayloadKeys.reminderId: reminder.id.uuidString,
			PayloadKeys.languageName: reminder.language.rawValue,
			PayloadKeys.numberOfLetters: reminder.numberOfLetters
		]
		
		let components = Calendar.current.dateComponents([.hour, .minute], from: reminder.timeToFire)
		let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
		
		let request = UNNotificationRequest(
			identifier: "daily-word-reminder: \(reminder.id.uuidString)",
			content: content,
			trigger: trigger
		)
		
		UNUserNotificationCenter.current().add(request) { error in
			if let error = error { print("Error scheduling notification: \(error)") }
		}
	}
	
	static func scheduleForTomorrow(reminder: DailyWordReminder) {
		NotificationManager.cancelDailyWordReminder(reminder: reminder)
		
		let hour = Calendar.current.component(.hour, from: reminder.timeToFire)
		let minute = Calendar.current.component(.minute, from: reminder.timeToFire)
		let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
		var components = Calendar.current.dateComponents([.day], from: tomorrow)
		components.hour = hour
		components.minute = minute
		
		let content = UNMutableNotificationContent()
		content.title = "Daily Word Reminder"
		content.body = "Don't forget to complete today's \(reminder.numberOfLetters) Letter \(reminder.language.localizedName) Daily Word!"
		content.sound = .default
		content.userInfo = [
			PayloadKeys.reminderId: reminder.id.uuidString,
			PayloadKeys.languageName: reminder.language.rawValue,
			PayloadKeys.numberOfLetters: reminder.numberOfLetters
		]
		
		// Note: repeats=true with year/month/day repeats yearly. Use repeats=false if you only want tomorrow once.
		let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
		
		let request = UNNotificationRequest(
			identifier: "daily-word-reminder: \(reminder.id.uuidString)",
			content: content,
			trigger: trigger
		)
		
		UNUserNotificationCenter.current().add(request) { error in
			if let error = error { print("Error scheduling notification: \(error)") }
		}
	}
	
	static func cancelDailyWordReminder(reminder: DailyWordReminder) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(
			withIdentifiers: ["daily-word-reminder: \(reminder.id.uuidString)"]
		)
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
	
	// Optional: show alerts while app is in foreground.
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
