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
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			if granted || error == nil {
				completion(.success(true))
			} else {
				print(granted ? "Notification permission granted" : "Notification permission denied: \(error?.localizedDescription ?? "No error info")")
				completion(.failure(error ?? NSError(domain: "NotificationPermission", code: 1, userInfo: [NSLocalizedDescriptionKey: "Notification permission denied"])))
			}
			
		}
	}
	
	static func scheduleDailyWordReminder(reminder: DailyWordReminder, daysAhead: Int = 7) {
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { requests in
			let existingDates = requests.compactMap { request -> Date? in
				(request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
			}
			
			let content = UNMutableNotificationContent()
			content.title = "Daily Word Reminder"
			content.body = "Don't forget to complete today's \(reminder.numberOfLetters) Letter \(reminder.language.localizedName) Daily Word!"
			content.sound = .default
			content.userInfo = [
				PayloadKeys.reminderId: reminder.id.uuidString,
				PayloadKeys.languageName: reminder.language.rawValue,
				PayloadKeys.numberOfLetters: reminder.numberOfLetters
			]
			
			var datesToAdd: [Date] = []
			
			for day in 0...daysAhead {
				if let date = Calendar.current.date(byAdding: .day, value: day, to: Date()) {
					let triggerDate2 = Calendar.current.dateComponents([.hour, .minute], from: reminder.timeToFire)
					guard let hour = triggerDate2.hour, let minute = triggerDate2.minute else { continue }
					guard let triggerDate = Calendar.current.date(bySettingHour: hour,
																  minute: minute,
																  second: 0,
																  of: date) else { continue }
					if !existingDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: triggerDate) }) {
						datesToAdd.append(triggerDate)
					}
				}
			}
			
			for date in datesToAdd {
				let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
				let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
				
				guard let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day  else { continue }
				
				let request = UNNotificationRequest(
					identifier: "daily-word-reminder-\(reminder.id.uuidString)-\(year)-\(month)-\(day)",
					content: content,
					trigger: trigger
				)
				
				center.add(request) { error in
					if let error = error { print("Error scheduling notification: \(error)") }
				}
				
			}
		}
		
		center.getPendingNotificationRequests() { requests in
			print("Pending notifications after scheduling:")
			for request in requests {
				if let trigger = request.trigger as? UNCalendarNotificationTrigger,
				   let date = trigger.nextTriggerDate() {
					print("ID: \(request.identifier), Date: \(date)")
				}
			}
		}
		
	}
	
	static func cancelTodayNotification(reminder: DailyWordReminder) {
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { requests in
			let today = Calendar.current.startOfDay(for: Date())
			let ids = requests.filter {
				if let trigger = $0.trigger as? UNCalendarNotificationTrigger,
				   let date = trigger.nextTriggerDate(), $0.identifier.contains("\(reminder.id.uuidString)") {
					return Calendar.current.isDate(date, inSameDayAs: today)
				}
				return false
			}.map { $0.identifier }
			print("Cancelling today's notifications with IDs: \(ids)")
			
			center.removePendingNotificationRequests(withIdentifiers: ids)
		}
	}
	
	static func cancelDailyWordReminder(reminder: DailyWordReminder) {
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { requests in
			let ids = requests.filter {
				if $0.identifier.contains("\(reminder.id.uuidString)") {
					return true
				}
				return false
			}.map { $0.identifier }
			print("Cancelling notifications with IDs: \(ids)")
			
			center.removePendingNotificationRequests(withIdentifiers: ids)
		}
//		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//			print("Pending notifications after cancel: \(requests)")
//		}
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
