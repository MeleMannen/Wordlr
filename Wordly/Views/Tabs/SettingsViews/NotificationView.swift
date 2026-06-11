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
	@Environment(\.colorScheme) private var colorScheme
	@AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
	@State private var shouldShowSheet: Bool = false
	@State private var shouldBeEditing: Bool = false
	@State private var reminderToEdit: DailyWordReminder?
	@State private var isPresentingFromAdd: Bool = false
	
	@Namespace private var namespace
	
	@Query(sort: \DailyWordReminder.timeToFire) private var dailyWordReminders: [DailyWordReminder]
	
	var body: some View {
		VStack {
			if self.dailyWordReminders.isEmpty {
				ContentUnavailableView(
					"No reminders",
					systemImage: "bell.badge.fill",
					description: Text("No reminders has been scheduled yet.")
				)
			} else {
				List {
					ForEach(Array(self.dailyWordReminders.enumerated()), id: \.element.id) { index, reminder in
						Button {
							self.reminderToEdit = reminder
							self.shouldBeEditing = true
							self.shouldShowSheet = true
							self.isPresentingFromAdd = false
						} label: {
							ReminderRow(reminder: reminder)
						}
						.opacity(reminder.isEnabled ? 1 : 0.5)
						.onChange(of: reminder.isEnabled) {
							if !reminder.isEnabled {
									NotificationManager.cancelDailyWordReminder(reminder: reminder)
									AnalyticsManager.shared.logDidDeactivateAReminderEvent()
								} else {
									NotificationManager.scheduleDailyWordReminder(reminder: reminder, context: context)
									AnalyticsManager.shared.logDidActivateAReminderEvent()
								}
							}
						.wordlrListSectionRowBackground(index: index, count: self.dailyWordReminders.count)
					}
					.onDelete(perform: deleteReminder)
				}
				.listStyle(.insetGrouped)
				.scrollContentBackground(.hidden)
			}
		}
		.darkGradientBackground(colorScheme: colorScheme)
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle("Daily Wordlr reminders")
		.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if #available(iOS 26.0, *) {
                    Button {
                        DispatchQueue.main.async {
                            self.isPresentingFromAdd = true
                            self.shouldShowSheet = true
                        }
                    } label: {
                        Label("Add reminder", systemImage: "plus")
                    }
                    .matchedTransitionSource(id: "add", in: self.namespace)
                    
                } else {
                    Button {
                        self.shouldShowSheet = true
                    } label: {
                        Label("Add reminder", systemImage: "plus")
                    }
                }
            }
		}
		.sheet(isPresented: $shouldShowSheet) {
			self.reminderToEdit = nil
			self.shouldBeEditing = false
		} content: {
			if #available(iOS 26.0, *), self.isPresentingFromAdd {
				AddReminderView(isPresented: self.$shouldShowSheet, isEditing: self.$shouldBeEditing, reminder: self.$reminderToEdit, reminders: self.dailyWordReminders)
					.presentationDetents([.fraction(0.8), .large])
					.navigationTransition(.zoom(sourceID: "add", in: self.namespace))
			} else {
				AddReminderView(isPresented: self.$shouldShowSheet, isEditing: self.$shouldBeEditing, reminder: self.$reminderToEdit, reminders: self.dailyWordReminders)
					.presentationDetents([.fraction(0.8), .large])
			}
			
		}
		.onAppear {
			AnalyticsManager.shared.logScreenViewed(screenName: "NotificationView")
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
				DatePicker(selection: $notificationTime, displayedComponents: .hourAndMinute) {
					
				}
				.datePickerStyle(.wheel)
				.listRowBackground(Color.clear)
				.frame(maxWidth: .infinity, alignment: .center)
				Section {
					Picker("Language", selection: $notificationLanguage) {
						ForEach(LanguageSelection.languages) { language in
							Text(language.localizedName)
								.tag(language)
								.foregroundStyle(.secondary)
								
						}
					}
					.pickerStyle(.menu)
					.wordlrListSectionRowBackground(.first)
					Picker("Word length", selection: $notificationLetters) {
						ForEach(1...8, id: \.self) { number in
							Text(number == 1 ? "\(number) letter" : "\(number) letters")
								.tag(number)
								.foregroundStyle(.secondary)
							
						}
					}
					.pickerStyle(.menu)
					.wordlrListSectionRowBackground(.last)
					
				} header: {
					Text("Reminder details")
				}
				.wordlrListSectionBackground()
				
				if let reminder, self.isEditing {
					HStack {
						Spacer()
						Button("Delete", role: .destructive) {
							self.isPresented = false
							self.isEditing = false
							NotificationManager.cancelDailyWordReminder(reminder: reminder)
							context.delete(reminder)
							try? context.save()
						}
						.font(.title3)
						.fontWeight(.bold)
						
						Spacer()
					}
					.onAppear {
						self.notificationLanguage = reminder.language
						self.notificationLetters = reminder.numberOfLetters
						self.notificationTime = reminder.timeToFire
					}
					.wordlrListSectionRowBackground(.single)
				}
				
				
				
					
			}
			.scrollContentBackground(.hidden)
			.tint(.secondary)
			.navigationTitle(self.isEditing ? "Edit reminder" : "Add reminder")
			.navigationBarTitleDisplayMode(.inline)
			.fontWeight(.medium)
			.toolbar {
				if #available(iOS 26.0, *) {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel", systemImage: "xmark") {
							self.isPresented = false
						}
						.conditionalHaptic(.selection, trigger: self.didTap)
					}
					
				} else {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel", role: .cancel) {
							self.isPresented = false
						}
						.conditionalHaptic(.selection, trigger: self.didTap)
						.tint(.red)
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					if #available(iOS 26.0, *) {
						Button("Save", systemImage: "checkmark") {
							self.saveButtonAction()
						}
						.conditionalHaptic(self.isEditing ? .selection : (self.checkIfReminderExists() ? .error : .selection), trigger: self.didTap)
						.opacity(self.isEditing ? 1.0 : (self.checkIfReminderExists() ? 0.3 : 1.0))
						.tint(self.isEditing ? .green : (self.checkIfReminderExists() ? .secondary : .green))
						.animation(.easeInOut, value: self.isEditing)
						.animation(.easeInOut, value: self.checkIfReminderExists())
					} else {
						Button {
							self.saveButtonAction()
						} label: {
							Text("Save")
								.foregroundStyle(.green)
								.opacity(self.isEditing ? 1.0 : (self.checkIfReminderExists() ? 0.3 : 1.0))
						}
						.conditionalHaptic(self.isEditing ? .selection : (self.checkIfReminderExists() ? .error : .selection), trigger: self.didTap)
						.animation(.easeInOut, value: self.isEditing)
						.animation(.easeInOut, value: self.checkIfReminderExists())
					}
					
				}
			}
		}
		.presentationDragIndicator(.hidden)
	}
	
	private func saveButtonAction() {
		print("time to fire: \(self.notificationTime.timeIntervalSince1970)")
		if self.isEditing, let reminder {
			NotificationManager.cancelDailyWordReminder(reminder: reminder) {
				reminder.language = self.notificationLanguage
				reminder.numberOfLetters = self.notificationLetters
				reminder.timeToFire = self.notificationTime
				reminder.isEnabled = true
				NotificationManager.scheduleDailyWordReminder(reminder: reminder, context: context)
			}
			
			
		} else {
			if self.checkIfReminderExists() {
				return
				}
				let reminder = DailyWordReminder(language: self.notificationLanguage, numberOfLetters: self.notificationLetters, timeToFire: self.notificationTime)
				context.insert(reminder)
				NotificationManager.scheduleDailyWordReminder(reminder: reminder, context: context)
			}
		try? context.save()
		self.isPresented = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			self.isEditing = false
		}
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
				.foregroundStyle(.primary)
			
			VStack(alignment: .leading, spacing: 6) {
				Text(reminder.timeToFire, format: .dateTime.hour().minute())
					.font(.system(.title3, design: .rounded))
					.fontWeight(.semibold)
					.monospacedDigit()
					.tint(.primary)
				
				HStack(spacing: 8) {
					Chip(text: reminder.language.localizedName)
					
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
		.tint(.primary)
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
