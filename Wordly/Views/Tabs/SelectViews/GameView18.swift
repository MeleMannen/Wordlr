//
//  GameView18.swift
//  Wordle
//
//  Created by Kristoffer Melen on 14/09/2025.
//

import SwiftUI
import GoogleMobileAds
import TipKit

struct GameView18: View {
	@Environment(AppManager.self) private var appManager
	@Environment(AdManager.self) private var adManager
	@Environment(StoreManager.self) private var storeManager
	@Environment(\.modelContext) private var modelContext
	@Environment(\.colorScheme) private var colorScheme
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
	@AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
	@State var didTapSubmitButton: Bool = false
	@State var didTapBackButton: Bool = false
	@State var didTapResetButton: Bool = false
	@State var didTapResetGameAlertButton: Bool = false
	@State var didTapNewGameButton: Bool = false
	@State var didTapSearchButton: Bool = false
	@State var didTapShowDefinitionButton: Bool = false
	@State var isShowingCurrentDefinition: Bool = false
	@State var alertItem: AlertItem?
	@State private var hasQueuedNotificationPromptForCurrentWin: Bool = false
	
	@Namespace private var namespace
	
	private let searchTip = SearchTip()
	
	private var device : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
	
	var colorForUnused: Color {
		switch colorScheme {
			case .light:
				return Color(UIColor.lightGray)
			case .dark:
				return .primary
			@unknown default:
				return .primary
		}
	}
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				GeometryReader { geometry2 in
					VStack {
						ForEach(appManager.board.indices, id: \.self) { rowIndex in
							HStack {
								ForEach(appManager.board[rowIndex].indices, id: \.self) { colIndex in
									let letter = appManager.board[rowIndex][colIndex]
									AnimatedGameTile(
										letter: letter,
										tileSize: geometry2.size.height / CGFloat(appManager.numberOfLetters < 5 ? 6 : appManager.numberOfLetters + 1),
										colIndex: colIndex,
										rowIndex: rowIndex,
										currentRow: appManager.currentRow,
										boardCount: appManager.board.count,
										isShaking: appManager.isShaking,
										isResettingBoard: appManager.isResettingBoard,
										selectedGameMode: appManager.selectedGameMode,
										didWinGame: appManager.didWinGame,
										isGameOver: appManager.isGameOver,
										userWantsNormalTheme: self.userWantsNormalTheme,
										colorScheme: self.colorScheme,
										colorForUnused: self.colorForUnused,
										gradient: appManager.gradient,
										shadowGradient: appManager.shadowGradient,
										onRevealStart: colIndex == appManager.board[rowIndex].count - 1 ? {
											appManager.applyPendingKeyboardUpdate()
										} : nil,
										onRevealComplete: colIndex == appManager.board[rowIndex].count - 1 ? {
											appManager.applyPendingGameCompletion()
										} : nil
									)
								}
							}
						}
					}
					.padding(.top, 5)
					.frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
					
				}
				GeometryReader { geometry2 in
					ZStack {
						VStack {
							Spacer()
							ForEach(appManager.keyboard.indices, id: \.self) { rowIndex in
								let keyboardRow = appManager.keyboard[rowIndex]
								HStack(spacing: self.device == .pad ? 8 : 5) {
									ForEach(appManager.keyboard[rowIndex].indices, id: \.self) { colIndex in
										let keyBoardKey = keyboardRow[colIndex]
										if appManager.keyboard.last == keyboardRow && keyboardRow.first?.letter == keyBoardKey.letter {
											Text("Z")
												.hidden()
												.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
											
											
											Text("Z")
												.hidden()
												.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
											
										}
										
										KeyboardKeyButton18(
											key: keyBoardKey,
											colorForUnused: self.colorForUnused,
											width: geometry2.size.width,
											height: geometry2.size.height
										) {
											appManager.insertLetterAtCurrentPosition(keyBoardKey.letter)
										}
										
										
										
										if appManager.keyboard.last == keyboardRow && keyboardRow.last?.letter == keyBoardKey.letter {
											Text("Z")
												.hidden()
												.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
											
											Text("Z")
												.hidden()
												.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
										}
									}
								}
							}
							
							HStack {
								Button(action: {
									self.didTapResetButton.toggle()
									if appManager.selectedGameMode == .normal {
										self.alertItem = AlertItem(
											title: Text("Are you sure you want to restart?"),
											message: Text("You will lose your word and you cannot undo this action!"),
											primaryButton: .destructive(Text("Restart")) {
												self.alertItem = AlertItem(
													title: Text("The word was: \(appManager.word)!"),
													message: Text("Do you want to see the definition?"),
													primaryButton: .default(Text("Show definition")) {
														self.isShowingCurrentDefinition = true
														
														DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
															print("reseting...")
															appManager.restartCurrentGame()
															self.didTapResetGameAlertButton.toggle()
														}
													},
													secondaryButton: .cancel(Text("Dismiss")) {
														print("reseting...")
														appManager.restartCurrentGame()
														self.didTapResetGameAlertButton.toggle()
													})
											}, secondaryButton: .cancel())
									}
									
								}, label: {
									Image(systemName: "arrow.clockwise")
										.font(.title2).bold()
										.foregroundStyle(.black)
										.frame(minWidth: geometry2.size.width / CGFloat(9),
											   maxWidth: geometry2.size.width / CGFloat(7),
											   minHeight: geometry2.size.height / CGFloat(10),
											   idealHeight: geometry2.size.height / CGFloat(8),
											   maxHeight: geometry2.size.height / CGFloat(6))
										.background {
											RoundedRectangle(cornerRadius: 10)
												.foregroundStyle(self.colorForUnused)
										}
								})
								.buttonStyle(ScalingButton())
								.opacity(appManager.selectedGameMode == .dailyWord ? 0.7 : 1.0)
								
								
								Spacer()
								
								Button(action: {
									self.didTapSubmitButton.toggle()
									if !appManager.isAnimating {
										appManager.didTapSubmit()
									}
									
									
								}, label: {
									Text("SUBMIT WORD")
										.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 3, y: 3)
										.font(.title).bold()
										.frame(minWidth: (geometry2.size.width*7) / CGFloat(14) + CGFloat(self.device == .pad ? 60 : 30), maxWidth: (geometry2.size.width*7) / CGFloat(12) + CGFloat(self.device == .pad ? 60 : 30), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
										.foregroundStyle(.white)
										.background {
											if !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .dailyWord {
												RoundedRectangle(cornerRadius: 10)
													.foregroundStyle(appManager.gradient)
													.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
													.opacity(appManager.submitOpacity)
													.animation(.easeInOut(duration: 0.2), value: appManager.submitOpacity)
													.conditionalHaptic(.alignment, trigger: appManager.submitOpacity)
													.onChange(of: appManager.wordIsValidForSubmitButton()) { _, newValue in
														withAnimation {
															if newValue {
																appManager.submitOpacity = 1.0
															} else {
																appManager.submitOpacity = 0.5
															}
														}
													}
											} else {
												RoundedRectangle(cornerRadius: 10)
													.foregroundStyle(.green)
													.opacity(appManager.submitOpacity)
													.animation(.easeInOut(duration: 0.2), value: appManager.submitOpacity)
													.conditionalHaptic(.alignment, trigger: appManager.submitOpacity)
													.onChange(of: appManager.wordIsValidForSubmitButton()) { _, newValue in
														withAnimation {
															if newValue {
																appManager.submitOpacity = 1.0
															} else {
																appManager.submitOpacity = 0.5
															}
														}
													}
											}
											
										}
								})
								.sensoryFeedback(trigger: self.didTapSubmitButton) { _, _ in
									guard hapticsEnabled else { return nil }
									return appManager.isAnimating ? .impact : .error
								}
								.buttonStyle(GrowingButton())
								
								
								
								
								Spacer()
								
								Button(action: {
									self.didTapBackButton.toggle()
									appManager.deleteLetterAtCurrentPosition()
									
								}, label: {
									Image(systemName: "delete.left")
										.font(.title2).bold()
										.foregroundStyle(.black)
										.frame(minWidth: geometry2.size.width / CGFloat(9), maxWidth: geometry2.size.width / CGFloat(7), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
										.background {
											RoundedRectangle(cornerRadius: 10)
												.foregroundStyle(self.colorForUnused)
										}
									
								})
								.buttonRepeatBehavior(.enabled)
								.conditionalHaptic(.impact, trigger: self.didTapBackButton)
								.buttonStyle(ScalingButton())
								
							}
							.padding(.top, 5)
							.padding(.bottom, 5)
							
							
						}
						.opacity((appManager.isGameOver && !appManager.isAnimating) ? 0 : 1)
						.animation(.easeOut(duration: 0.3), value: appManager.isGameOver)
						.animation(.easeOut(duration: 0.3), value: appManager.isAnimating)
						.sensoryFeedback(.selection, trigger: appManager.isAnimating) { oldValue, newValue in
							hapticsEnabled && oldValue && !newValue
						}
						
						
						VStack(alignment: .center) {
							Spacer()
							Spacer()
							Text(appManager.message)
								.font(.title2).bold()
								.padding(.top, 5)
							
							Spacer()
							
							Button(action: {
								self.didTapNewGameButton.toggle()
								appManager.startNewGameFromGameOver()
								Task {
									await HintTip.gamesPlayedEvent.donate()
								}
							}, label: {
								Text(appManager.selectedGameMode == .normal ? "New game" : "Free play")
									.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
									.font(.title2).bold()
									.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
									.foregroundStyle(.white)
									.background {
										RoundedRectangle(cornerRadius: 10)
											.foregroundStyle(.green)
									}
							})
							.padding(.horizontal, 20)
							.conditionalHaptic(.impact, trigger: self.didTapNewGameButton)
							.buttonStyle(GrowingButton())
							.conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)
							
							Spacer()
							
							NavigationLink(destination: WordDefinitionView(word: appManager.word, language: appManager.selectedLanguage), label: {
								if !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .dailyWord {
									Text("Show definition")
										.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
										.font(.title2).bold()
										.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
										.foregroundStyle(.white)
										.background {
											RoundedRectangle(cornerRadius: 10)
												.foregroundStyle(appManager.gradient)
												.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
										}
								} else {
									Text("Show definition")
										.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
										.font(.title2).bold()
										.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
										.foregroundStyle(.white)
										.background {
											RoundedRectangle(cornerRadius: 10)
												.foregroundStyle(Color.orange)
										}
								}
							})
							.simultaneousGesture(TapGesture().onEnded {
								self.didTapShowDefinitionButton.toggle()
								adManager.shouldShowAds = true
							})
							.buttonStyle(GrowingButton())
							.conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)
							.conditionalHaptic(.impact, trigger: self.didTapShowDefinitionButton)
							.padding(.horizontal, 20)
							
							Spacer()
							
							if appManager.selectedGameMode == .dailyWord && !appManager.dailyWordHasBeenPlayed {
								Button {
									withAnimation {
										appManager.hasSharedResult = true
										self.didTapBackButton.toggle()
										UIPasteboard.general.string = appManager.getShareResult(row: appManager.currentRow, numberOfLetters: appManager.numberOfLetters, date: appManager.startDate, board: appManager.board, timeUsedString: appManager.getTimeUsedString(startDate: appManager.startDate, endDate: appManager.endDate))
										
										
									}
								} label: {
									Label("Copy result", systemImage: appManager.hasSharedResult ? "doc.on.doc.fill" : "doc.on.doc")
										.font(.title2).bold()
										.contentTransition(.symbolEffect(.replace))
										.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
										.tint(.primary)
								}
								Spacer()
							}
						}
						.opacity((appManager.isGameOver && !appManager.isAnimating) ? 1 : 0)
						.conditionalHaptic(.success, trigger: (appManager.isGameOver && !appManager.isAnimating))
						
					}
					.padding(.horizontal, 5)
					.background(
						hardwareKeyCommands(
							onInsertLetter: { ch in
								appManager.insertLetterAtCurrentPosition(ch)
							},
							onDelete: {
								appManager.deleteLetterAtCurrentPosition()
							},
							onReturn: {
								guard !appManager.isAnimating else { return }
								appManager.didTapSubmit()
							},
							onCommandR: {
								self.didTapResetButton.toggle()
								if appManager.selectedGameMode == .normal {
									self.alertItem = AlertItem(
										title: Text("Are you sure you want to restart?"),
										message: Text("You will lose your word and you cannot undo this action!"),
										primaryButton: .destructive(Text("Restart")) {
											self.alertItem = AlertItem(
												title: Text("The word was: \(appManager.word)!"),
												message: Text("Do you want to see the definition?"),
												primaryButton: .default(Text("Show definition")) {
													self.isShowingCurrentDefinition = true
													
													DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
														print("reseting...")
														appManager.restartCurrentGame()
													}
												},
												secondaryButton: .cancel(Text("Dismiss")) {
													print("reseting...")
													appManager.restartCurrentGame()
												})
										}, secondaryButton: .cancel())
								}
							},
							onCommandN: {
								if !appManager.isAnimating && appManager.isGameOver {
									self.didTapNewGameButton.toggle()
									appManager.startNewGameFromGameOver()
									Task {
										await HintTip.gamesPlayedEvent.donate()
									}
								}
							},
							onCommandC: {
								if !appManager.isAnimating && appManager.isGameOver {
									withAnimation {
										appManager.hasSharedResult = true
										self.didTapBackButton.toggle()
										UIPasteboard.general.string = appManager.getShareResult(row: appManager.currentRow, numberOfLetters: appManager.numberOfLetters, date: appManager.startDate, board: appManager.board, timeUsedString: appManager.getTimeUsedString(startDate: appManager.startDate, endDate: appManager.endDate))
									}
								}
							}
						)
					)
				}
				.frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
			}
			.navigationDestination(isPresented: self.$isShowingCurrentDefinition, destination: {
				WordDefinitionView(word: appManager.word)
					.environment(appManager)
			})
			.navigationTitle(appManager.numberOfLetters == 1 ? "Guess the letter" : "Guess the Word")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				if appManager.isHintAvailable() && (appManager.shouldShowAdButton || storeManager.isAdRemovalPurchased) {
					ToolbarItem(placement: .topBarTrailing) {
						AdButton(shouldShowHintTip: appManager.isHintAvailable() && (appManager.shouldShowAdButton || storeManager.isAdRemovalPurchased))
							.environment(appManager)
					}
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					SearchToolbarItem()
						.environment(appManager)
				}
			}
		}
		.onAppear {
			AnalyticsManager.shared.logScreenViewed(screenName: "GameView18")
			if appManager.word.isEmpty || appManager.selectedLanguage != appManager.language || appManager.gameMode != appManager.selectedGameMode || appManager.message == "" && appManager.isGameOver {
				appManager.getWords()
			} else if appManager.word.count != appManager.numberOfLetters {
				appManager.resetBoard()
			}
			adManager.currentSelectView = .gameView
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = false
			}
			
		}
		.onDisappear {
			adManager.currentSelectView = .selectView
		}
		.onChange(of: appManager.shouldPromptForNotificationsAfterFirstWin) { _, shouldPrompt in
			guard shouldPrompt else { return }
			presentNotificationPromptIfNeeded()
		}
		.onChange(of: appManager.isGameOver) {
			presentNotificationPromptIfNeeded()
		}
		.onChange(of: appManager.isAnimating) {
			presentNotificationPromptIfNeeded()
		}
		.onChange(of: self.alertItem?.title) {
			if self.alertItem != nil {
				self.didTapResetButton.toggle()
			}
		}
		.alert(item: self.$alertItem) { item in
			if let dismissButton = item.dismissButton {
				Alert(title: item.title, message: item.message, dismissButton: dismissButton)
			} else if let primaryButton = item.primaryButton, let secondaryButton = item.secondaryButton {
				Alert(title: item.title, message: item.message, primaryButton: primaryButton, secondaryButton: secondaryButton)
			} else {
				Alert(title: item.title)
			}
		}
		.conditionalHaptic(.warning, trigger: self.didTapResetButton)
		.conditionalHaptic(.success, trigger: self.didTapResetGameAlertButton)
		.task {
			await appManager.loadAd()
			appManager.hasLoadedAd = true
		}
	}
	
	private func presentNotificationPromptIfNeeded() {
		guard appManager.isGameOver,
			  !appManager.isAnimating,
			  appManager.didWinGame == .won,
			  appManager.shouldPromptForNotificationsAfterFirstWin,
			  !notificationsEnabled,
			  !hasQueuedNotificationPromptForCurrentWin,
			  alertItem == nil else {
			return
		}
		
		hasQueuedNotificationPromptForCurrentWin = true
		alertItem = AlertItem(
			title: Text("Keep your streak going?"),
			message: Text("Turn on reminders so you don't miss the next daily word."),
			primaryButton: .default(Text("Turn on")) {
				notificationsEnabled = true
				createReminderForCurrentDailyWord()
				UserDefaults.standard.set(Int.max, forKey: "notificationPromptNextWinThreshold")
				appManager.shouldPromptForNotificationsAfterFirstWin = false
			},
			secondaryButton: .cancel(Text("Not now")) {
				let currentWins = UserDefaults.standard.integer(forKey: "notificationPromptWinCount")
				let currentThreshold = UserDefaults.standard.object(forKey: "notificationPromptNextWinThreshold") as? Int ?? 1
				let increment = currentThreshold <= 1 ? 25 : 50
				UserDefaults.standard.set(currentWins + increment, forKey: "notificationPromptNextWinThreshold")
				appManager.shouldPromptForNotificationsAfterFirstWin = false
			}
		)
	}
	
	private func createReminderForCurrentDailyWord() {
		let reminders = NotificationManager.fetchReminders(context: modelContext)
		let reminder = reminders.first {
			$0.language == appManager.selectedLanguage && $0.numberOfLetters == appManager.numberOfLetters
		} ?? DailyWordReminder(
			language: appManager.selectedLanguage,
			numberOfLetters: appManager.numberOfLetters,
			timeToFire: defaultReminderTime()
		)
		
		reminder.isEnabled = true
		if !reminders.contains(where: { $0.id == reminder.id }) {
			modelContext.insert(reminder)
		}
		
		NotificationManager.scheduleDailyWordReminder(reminder: reminder, context: modelContext)
		try? modelContext.save()
	}
	
	private func defaultReminderTime() -> Date {
		Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 1, hour: 18, minute: 0)) ?? Date()
	}
}

#Preview {
	GameView18()
		.environment(AppManager())
}
