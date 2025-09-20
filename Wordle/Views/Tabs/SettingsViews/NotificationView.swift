//
//  NotificationView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 21/08/2025.
//

import SwiftUI
import SwiftData

struct NotificationView: View {
	@Environment(\.modelContext) private var context
	@AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
	@State private var didTapAddReminder: Bool = false
	@State private var shouldShowSheet: Bool = false
	@State private var shouldBeEditing: Bool = false
	@State private var reminderToEdit: DailyWordReminder?
	
	@Query(sort: \DailyWordReminder.timeToFire) private var dailyWordReminders: [DailyWordReminder]
	
	var body: some View {
		VStack {
			if self.dailyWordReminders.isEmpty {
				ContentUnavailableView(
					"No Reminders",
					systemImage: "bell.badge.fill",
					description: Text("No reminders has been scheduled yet.")
				)
			} else {
				List {
//					if !self.dailyWordReminders.filter({ $0.isEnabled }).isEmpty {
//						Section("Scheduled") {
							ForEach(self.dailyWordReminders, id: \.id) { reminder in
								if reminder.isEnabled {
									Button {
										self.reminderToEdit = reminder
										self.shouldBeEditing = true
										self.shouldShowSheet = true
									} label: {
										ReminderRow(reminder: reminder)
									}
									.onChange(of: reminder.isEnabled) {
										if !reminder.isEnabled {
											NotificationManager.cancelDailyWordReminder(reminder: reminder)
										} else {
											NotificationManager.scheduleDailyWordReminder(reminder: reminder)
										}
									}
								} else {
									Button {
										self.reminderToEdit = reminder
										self.shouldBeEditing = true
										self.shouldShowSheet = true
									} label: {
										ReminderRow(reminder: reminder)
									}
									.opacity(0.5)
									.onChange(of: reminder.isEnabled) {
										if !reminder.isEnabled {
											NotificationManager.cancelDailyWordReminder(reminder: reminder)
										} else {
											NotificationManager.scheduleDailyWordReminder(reminder: reminder)
										}
									}
								}
							}
							.onDelete(perform: deleteReminder)
//						}
//					}
//					if !self.dailyWordReminders.filter({ !$0.isEnabled }).isEmpty {
//						Section("Unscheduled") {
//							ForEach(self.dailyWordReminders, id: \.id) { reminder in
//								if !reminder.isEnabled {
//									Button {
//										self.reminderToEdit = reminder
//										self.shouldBeEditing = true
//										self.shouldShowSheet = true
//									} label: {
//										ReminderRow(reminder: reminder)
//									}
//									.opacity(0.5)
//									.onChange(of: reminder.isEnabled) {
//										if !reminder.isEnabled {
//											NotificationManager.cancelDailyWordReminder(reminder: reminder)
//										} else {
//											NotificationManager.scheduleDailyWordReminder(reminder: reminder)
//										}
//									}
//								}
//							}
//							.onDelete(perform: deleteReminder)
//						}
//					}
				}
				.listStyle(.insetGrouped)
			}
		}
		.navigationTitle("Daily Word Reminders")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: {
					self.didTapAddReminder.toggle()
					self.shouldShowSheet = true
				}) {
					Label("Add Reminder", systemImage: "plus")
				}
				.sensoryFeedback(.selection, trigger: self.didTapAddReminder)
			}
		}
		.sheet(isPresented: $shouldShowSheet) {
			self.reminderToEdit = nil
			self.shouldBeEditing = false
		} content: {
			AddReminderView(isPresented: self.$shouldShowSheet, isEditing: self.$shouldBeEditing, reminder: self.$reminderToEdit, reminders: self.dailyWordReminders)
				.presentationDetents([.medium, .large])
//				.presentationDetents([.large])
				
		}
	}
	
	private func deleteReminder(at offsets: IndexSet) {
		for index in offsets {
			let reminder = dailyWordReminders[index]
			context.delete(reminder)
			NotificationManager.cancelDailyWordReminder(reminder: reminder)
			
		}
		try? context.save()
	}
}

#Preview {
	NavigationStack {
		NotificationView()
	}
	.tint(.primary)
}

struct AddReminderView: View {
	@Environment(\.modelContext) private var context
	@State private var notificationTime: Date = {
		let calendar = Calendar.current
		return calendar.date(from: DateComponents(year: 2025, month: 9, day: 1, hour: 18, minute: 0)) ?? Date()
	}()
	@State private var notificationLanguage: LanguageSelection = .english
	@State private var notificationLetters: Int = 5
	@State private var isEnabled: Bool = true
	@State private var didTap: Bool = false
	@Binding var isPresented: Bool
	@Binding var isEditing: Bool
	@Binding var reminder: DailyWordReminder?
	@State var reminders: [DailyWordReminder]
	
	var body: some View {
		NavigationStack {
				List {
					Section {
						DatePicker("Time of Day", selection: $notificationTime, displayedComponents: .hourAndMinute)
//					} header: {
//						Text("Time of Day")
//					}
					
//					Section {
						Picker("Language", selection: $notificationLanguage) {
							ForEach(LanguageSelection.languages) { language in
								Text(language.localizedName.capitalized).tag(language)
							}
						}
						.pickerStyle(.menu)
//					} header: {
//						Text("Language")
//					}
					
//					Section {
						Picker("Number of Letters", selection: $notificationLetters) {
							ForEach(1...8, id: \.self) { number in
								Text(number == 1 ? "\(number) Letter" : "\(number) Letters").tag(number)
							}
						}
						.pickerStyle(.menu)
						
						if let reminder, self.isEditing {
							if #available(iOS 26.0, *) {
								HStack {
									Spacer()
									Button("Delete", role: .destructive) {
										self.isPresented = false
										self.isEditing = false
										context.delete(reminder)
									}
									//						.foregroundStyle(.primary)
									//						.frame(maxWidth: .infinity)
									//						.padding()
									//						.glassEffect(.regular.tint(.red).interactive(), in: .capsule)
									
									//						.padding(.horizontal, 20)
									
									Spacer()
								}
								.onAppear {
									self.notificationLanguage = reminder.language
									self.notificationLetters = reminder.numberOfLetters
									self.notificationTime = reminder.timeToFire
								}
								
							} else {
								HStack {
									Spacer()
									Button("Delete", role: .destructive) {
										self.isPresented = false
										self.isEditing = false
										context.delete(reminder)
									}
									Spacer()
								}
								.onAppear {
									self.notificationLanguage = reminder.language
									self.notificationLetters = reminder.numberOfLetters
									self.notificationTime = reminder.timeToFire
								}
							}
						}
					} header: {
						Text("Reminder Details")
					}
					
					
					
					
				}
				.tint(.secondary)
				.navigationTitle(self.isEditing ? "Edit Reminder" : "Add Reminder")
				.navigationBarTitleDisplayMode(.inline)
				.fontWeight(.medium)
				.toolbar {
					if #available(iOS 26.0, *) {
						ToolbarItem(placement: .cancellationAction) {
								Button("Close", systemImage: "xmark", role: .close) {
									self.isPresented = false
									
								}
								.glassEffect(.regular.interactive(), in: .circle)
								.sensoryFeedback(.selection, trigger: self.didTap)
						}
						.sharedBackgroundVisibility(.visible)
						
					} else {
						ToolbarItem(placement: .cancellationAction) {
							Button("Cancel", systemImage: "xmark", role: .cancel) {
								self.isPresented = false
							}
							.sensoryFeedback(.selection, trigger: self.didTap)
						}
					}
					
					ToolbarItem(placement: .confirmationAction) {
						if #available(iOS 26.0, *) {
							Button("Done", systemImage: "checkmark", role: .confirm) {
								print("time to fire: \(self.notificationTime.timeIntervalSince1970)")
								if self.isEditing, let reminder {
									reminder.language = self.notificationLanguage
									reminder.numberOfLetters = self.notificationLetters
									reminder.timeToFire = self.notificationTime
									reminder.isEnabled = true
									NotificationManager.scheduleDailyWordReminder(reminder: reminder)
									
								} else {
									if self.checkIfReminderExists() {
										return
									}
									let reminder = DailyWordReminder(language: self.notificationLanguage, numberOfLetters: self.notificationLetters, timeToFire: self.notificationTime)
									context.insert(reminder)
									NotificationManager.scheduleDailyWordReminder(reminder: reminder)
								}
								try? context.save()
								self.isPresented = false
								self.isEditing = false
							}
							
							.opacity(self.isEditing ? 1.0 : (self.checkIfReminderExists() ? 0.3 : 1.0))
							.tint(self.isEditing ? .blue : (self.checkIfReminderExists() ? .secondary : .blue))
							.buttonStyle(.glassProminent)
						} else {
							Button {
								print("time to fire: \(self.notificationTime.timeIntervalSince1970)")
								if self.isEditing, let reminder {
									reminder.language = self.notificationLanguage
									reminder.numberOfLetters = self.notificationLetters
									reminder.timeToFire = self.notificationTime
									reminder.isEnabled = true
									NotificationManager.scheduleDailyWordReminder(reminder: reminder)
									
								} else {
									if self.checkIfReminderExists() {
										return
									}
									let reminder = DailyWordReminder(language: self.notificationLanguage, numberOfLetters: self.notificationLetters, timeToFire: self.notificationTime)
									context.insert(reminder)
									NotificationManager.scheduleDailyWordReminder(reminder: reminder)
								}
								try? context.save()
								self.isPresented = false
								self.isEditing = false
							} label: {
								Image(systemName: "checkmark")
									.foregroundStyle(.primary)
									.opacity(self.isEditing ? 1.0 : (self.checkIfReminderExists() ? 0.3 : 1.0))
							}
							.sensoryFeedback(self.isEditing ? .selection : (self.checkIfReminderExists() ? .error : .selection), trigger: self.didTap)
							.keyboardShortcut(.defaultAction)
						}
						
					}
				}
			
			
			
		}
		.presentationDragIndicator(.hidden)
	}
	
	private func checkIfReminderExists() -> Bool {
		for reminder in reminders {
			if reminder.language == notificationLanguage && reminder.numberOfLetters == notificationLetters && reminder.timeToFire.timeIntervalSince1970 == notificationTime.timeIntervalSince1970 {
				return true
			}
		}
		return false
	}
}

struct ReminderRow: View {
	@Environment(\.modelContext) private var context
	@State var reminder: DailyWordReminder
	@State private var isEnabled: Bool = false
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "bell")
				.font(.title).bold()
				.foregroundStyle(.white)
			
			VStack(alignment: .leading, spacing: 6) {
				Text(reminder.timeToFire, format: .dateTime.hour().minute())
					.font(.system(.title3, design: .rounded))
					.fontWeight(.semibold)
					.monospacedDigit()
				
				HStack(spacing: 8) {
					Chip(text: reminder.language.localizedName.capitalized)
					
					Chip(text: reminder.numberOfLetters == 1 ? String(format: NSLocalizedString("numberOfLetter", comment: "Number of letter single"), reminder.numberOfLetters) : String(format: NSLocalizedString("numberOfLetters", comment: "Number of letters plural"), reminder.numberOfLetters))
				}
				.font(.footnote)
				.foregroundStyle(.secondary)
			}
			
			Spacer(minLength: 1)
			
			VStack {
				if #available(iOS 26.0, *) {
					Toggle(isOn: self.$isEnabled) {
						
					}
					.tint(.green)
					.padding(.vertical, 4)
						
				} else {
					Toggle(isOn: self.$isEnabled) {
						
					}
					.tint(.green)
				}
			}
			.onChange(of: self.isEnabled) {
				reminder.isEnabled = self.isEnabled
				try? context.save()
			}
		}
		.padding(.vertical, 8)
		.contentShape(Rectangle())
		.onAppear {
			self.isEnabled = reminder.isEnabled
		}
	}
}

struct Chip: View {
	let text: String
	let systemImage: String?
	
	init(text: String, systemImage: String? = nil) {
		self.text = text
		self.systemImage = systemImage
	}
	
	var body: some View {
		HStack(spacing: 4) {
			if let systemImage {
				Image(systemName: systemImage)
			}
			Text(text)
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 5)
		.background(.quaternary.opacity(0.25), in: Capsule())
	}
}

@Model
final class DailyWordReminder: Identifiable {
	var id: UUID
	var language: LanguageSelection
	var numberOfLetters: Int
	var timeToFire: Date
	var isEnabled: Bool = true
	
	init(id: UUID = UUID(), language: LanguageSelection, numberOfLetters: Int, timeToFire: Date) {
		self.id = id
		self.language = language
		self.numberOfLetters = numberOfLetters
		self.timeToFire = timeToFire
	}
}
