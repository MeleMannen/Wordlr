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
	
	static func requestPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
		AnalyticsManager.shared.logDidTapActivateNotificationsEvent()
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			if granted || error == nil {
				AnalyticsManager.shared.logDidActivateNotificationsEvent()
				completion(.success(true))
			} else {
				print(granted ? "Notification permission granted" : "Notification permission denied: \(error?.localizedDescription ?? "No error info")")
				completion(.failure(error ?? NSError(domain: "NotificationPermission", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notification permission denied"])))
			}
			
		}
	}
	
	private static func requestId(for reminder: DailyWordReminder, on date: Date) -> String {
		let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
		let y = comps.year ?? 0, m = comps.month ?? 0, d = comps.day ?? 0
		return "daily-word-reminder-\(reminder.id.uuidString)-\(y)-\(m)-\(d)"
	}
	
	static func scheduleDailyWordReminder(reminder: DailyWordReminder, daysAhead: Int = 7) {
		let center = UNUserNotificationCenter.current()
		
		center.getPendingNotificationRequests { requests in
			let existingIds = Set(
				requests
					.filter { $0.identifier.contains(reminder.id.uuidString) }
					.map { $0.identifier }
			)
			
			let title = NSLocalizedString("Daily Wordly Reminder", comment: "Title for Daily Wordly reminder notification")
			let body = String(
				format: NSLocalizedString("Don't forget to complete today's %d Letter, %@ Daily Wordly!", comment: "Body for Daily Wordly reminder notification"),
				reminder.numberOfLetters,
				reminder.language.localizedName
			)
			
			
			let content = UNMutableNotificationContent()
			content.title = title
			content.body = body
			content.sound = .default
			content.userInfo = [
				PayloadKeys.reminderId: reminder.id.uuidString,
				PayloadKeys.languageName: reminder.language.rawValue,
				PayloadKeys.numberOfLetters: reminder.numberOfLetters
			]
			
			var requestsToAdd: [UNNotificationRequest] = []
			
			for day in 0...daysAhead {
				guard let baseDate = Calendar.current.date(byAdding: .day, value: day, to: Date()) else { continue }
				let timeComps = Calendar.current.dateComponents([.hour, .minute], from: reminder.timeToFire)
				guard let hour = timeComps.hour, let minute = timeComps.minute else { continue }
				
				guard let fireDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate) else { continue }
				
				let id = requestId(for: reminder, on: fireDate)
				// Skip if already scheduled for this reminder on that day.
				if existingIds.contains(id) { continue }
				
				let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
				let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
				
				let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
				requestsToAdd.append(req)
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
		let id = requestId(for: reminder, on: Date())
		let center = UNUserNotificationCenter.current()
		center.removePendingNotificationRequests(withIdentifiers: [id])
	}
	
	static func cancelDailyWordReminder(reminder: DailyWordReminder) {
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { requests in
			let ids = requests
				.filter { $0.identifier.contains(reminder.id.uuidString) }
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
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { requests in
			let ids = requests
				.filter { $0.identifier.contains(reminder.id.uuidString) }
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
