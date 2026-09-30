//
//  GameView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import UIKit
import GoogleMobileAds
import TipKit
import SwiftData

struct GameView26: View {
	@Environment(AppManager.self) private var appManager
	@Environment(AdManager.self) private var adManager
	@Environment(StoreManager.self) private var storeManager
	@Environment(\.modelContext) private var modelContext
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
	@AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
	@State var didTapSubmitButton: Bool = false
	@State var didTapBackButton: Bool = false
	@State var didTapResetButton: Bool = false
	@State var didTapResetGameAlertButton: Bool = false
	@State var didTapNewGameButton: Bool = false
	@State var didTapShowDefinitionButton: Bool = false
	@State var isShowingCurrentDefinition: Bool = false
	@State var alertItem: AlertItem?
	@State private var hasQueuedNotificationPromptForCurrentWin: Bool = false
	@State private var hasQueuedProPromptForCurrentGame: Bool = false
	@State private var showHintButton: Bool = false
	@State private var lastAnnouncedRevealedRow: Int?

	@Namespace private var namespace
	
	private var device : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
	private var gameColorScheme: ColorScheme { .dark }
	
	var colorForUnused: Color {
		.white
	}
	
	var colorForWhenAppInBackground: Color {
		.white
	}
	
	var body: some View {
		if #available(iOS 26.0, *) {
			GeometryReader { geometry in
				VStack {
					GeometryReader { geometry2 in
						VStack {
							ForEach(Array(appManager.board.enumerated()), id: \.offset) { rowIndex, row in
								HStack {
									ForEach(Array(row.enumerated()), id: \.element.id) { colIndex, letter in
										let isLastTileInRow = colIndex == row.count - 1
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
											shouldShowCelebrationGradient: appManager.shouldShowCelebrationGradient,
											userWantsNormalTheme: self.userWantsNormalTheme,
											colorScheme: self.gameColorScheme,
											colorForUnused: self.colorForUnused,
											gradient: appManager.gradient,
											shadowGradient: appManager.shadowGradient,
											onRevealStart: isLastTileInRow ? {
												appManager.applyPendingKeyboardUpdate()
											} : nil,
											onRevealComplete: isLastTileInRow ? {
												handleRowRevealComplete(rowIndex: rowIndex)
											} : nil
										)
									}
								}
								.accessibilityElement(children: .ignore)
								.accessibilityLabel(WordlrAccessibilityFormatter.rowLabel(row: row, rowIndex: rowIndex, currentRow: appManager.currentRow))
							}
						}
						.padding(.top, 5)
						.frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
						.accessibilityElement(children: .contain)
						.accessibilityLabel(WordlrAccessibilityFormatter.boardLabel(board: appManager.board, currentRow: appManager.currentRow, isGameOver: appManager.isGameOver))
						.accessibilityValue(WordlrAccessibilityFormatter.boardValue(numberOfLetters: appManager.numberOfLetters, rowCount: appManager.board.count))
						
					}
					GeometryReader { geometry2 in
						ZStack {
							GlassEffectContainer {
								VStack {
									Spacer()
									VStack {
										ForEach(appManager.keyboard.indices, id: \.self) { rowIndex in
											let keyboardRow = appManager.keyboard[rowIndex]
											HStack(spacing: self.device == .pad ? 8 : 5) {
												ForEach(appManager.keyboard[rowIndex].indices, id: \.self) { colIndex in
													let keyBoardKey = keyboardRow[colIndex]
													if appManager.keyboard.last == keyboardRow && keyboardRow.first?.letter == keyBoardKey.letter {
														Text("Z")
															.hidden()
															.accessibilityHidden(true)
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
														
														
														Text("Z")
															.hidden()
															.accessibilityHidden(true)
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
														
													}
													KeyboardKeyButton26(
														key: keyBoardKey,
														colorForUnused: self.colorForUnused,
														colorForWhenAppInBackground: self.colorForWhenAppInBackground,
														colorScheme: self.gameColorScheme,
														alternateLetters: appManager.selectedLanguage == .polish ? Self.polishAlternateLetters(for: keyBoardKey.letter) : [],
														namespace: self.namespace,
														width: geometry2.size.width,
														height: geometry2.size.height
													) { letter in
														appManager.insertLetterAtCurrentPosition(letter)
													}
													
													
													
													if appManager.keyboard.last == keyboardRow && keyboardRow.last?.letter == keyBoardKey.letter {
														Text("Z")
															.hidden()
															.accessibilityHidden(true)
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
														
														Text("Z")
															.hidden()
															.accessibilityHidden(true)
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
													}
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
													message: Text("You will lose your word and you cannot undo this action"),
													primaryButton: .destructive(Text("Restart")) {
														self.alertItem = AlertItem(
															title: Text("The word was: \(appManager.word)"),
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
														.foregroundStyle(self.colorForWhenAppInBackground)
														.opacity(appManager.selectedGameMode == .dailyWord ? 0.4 : 1.0)
												}
//												.overlay {
//													if gameColorScheme == .light {
//														RoundedRectangle(cornerRadius: 10)
//															.stroke(Color(uiColor: .systemGray4), lineWidth: 1)
//													}
//												}
												.opacity(appManager.selectedGameMode == .dailyWord ? 0.4 : 1.0)
										})
											.accessibilityLabel("Restart game")
											.accessibilityHint("Restarts the current free play game.")
											.accessibilityInputLabels(["Restart", "Restart game"])
//											.buttonStyle(ScalingButton(isEnabled: gameColorScheme == .light))
											.modifier(
												KeyboardGlassEffect(
													isEnabled: true,
													tint: self.colorForUnused.opacity(appManager.selectedGameMode == .dailyWord ? 0.4 : 1.0),
													cornerRadius: 10,
													id: "reset",
													namespace: self.namespace
												)
											)
										
										
										
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
												.lineLimit(2)
												.minimumScaleFactor(0.75)
												.multilineTextAlignment(.center)
												.frame(minWidth: (geometry2.size.width*7) / CGFloat(14) + CGFloat(self.device == .pad ? 60 : 30), maxWidth: (geometry2.size.width*7) / CGFloat(12) + CGFloat(self.device == .pad ? 60 : 30), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
												.foregroundStyle(.white)
												.background {
													if !self.userWantsNormalTheme && self.gameColorScheme == .dark && appManager.selectedGameMode == .dailyWord {
														RoundedRectangle(cornerRadius: 10)
															.foregroundStyle(appManager.gradient)
															.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
															.opacity(appManager.submitOpacity)
													} else {
														RoundedRectangle(cornerRadius: 10)
															.foregroundStyle(Color(uiColor: .systemGreen))
															.opacity(appManager.submitOpacity)
													}
												}
										})
										.accessibilityLabel("Submit word")
										.accessibilityValue(appManager.wordIsValidForSubmitButton() ? "Ready" : "Not ready")
										.accessibilityHint("Checks the current guess.")
										.accessibilityInputLabels(["Submit", "Submit word"])
										.glassEffectID("submit", in: self.namespace)
										.glassEffect(!self.userWantsNormalTheme && self.gameColorScheme == .dark && appManager.selectedGameMode == .dailyWord ? .regular.interactive() : .regular.tint(.green.opacity(appManager.submitOpacity)).interactive(), in: .rect(cornerRadius: 10.0))
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
										.sensoryFeedback(trigger: self.didTapSubmitButton) { _, _ in
											guard hapticsEnabled else { return nil }
											return appManager.isAnimating ? .impact : .error
										}
										
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
															.foregroundStyle(self.colorForWhenAppInBackground)
												}
//												.overlay {
//													if gameColorScheme == .light {
//														RoundedRectangle(cornerRadius: 10)
//															.stroke(Color(uiColor: .systemGray4), lineWidth: 1)
//													}
//												}
										})
										.buttonRepeatBehavior(.enabled)
											.accessibilityLabel("Delete letter")
											.accessibilityHint("Deletes the previous letter.")
											.accessibilityInputLabels(["Delete", "Delete letter"])
//											.buttonStyle(ScalingButton(isEnabled: gameColorScheme == .light))
											.modifier(
												KeyboardGlassEffect(
													isEnabled: true,
													tint: self.colorForUnused,
													cornerRadius: 10,
													id: "delete",
													namespace: self.namespace
												)
											)
										.conditionalHaptic(.impact, trigger: self.didTapBackButton)
									}
									.padding(.top, 5)
									.padding(.bottom, 5)
								}
							}
							.opacity((appManager.isGameOver && !appManager.isAnimating) ? 0 : 1)

							VStack(alignment: .center) {
								Spacer()

								Text(appManager.message)
									.font(.title2).bold()
									.padding(.top, 35)

								Spacer()

								Button(action: {
									self.didTapNewGameButton.toggle()
									appManager.startNewGameFromGameOver()
									Task {
										await HintTip.gamesPlayedEvent.donate()
									}
								}, label: {
									Text(appManager.selectedGameMode == .normal ? LocalizedStringKey("New word") : LocalizedStringKey("Unlimited"))
										.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
										.font(.title2).bold()
										.lineLimit(2)
										.minimumScaleFactor(0.8)
										.multilineTextAlignment(.center)
										.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
										.foregroundStyle(.white)
										.background {
											if !self.userWantsNormalTheme && self.gameColorScheme == .dark && appManager.selectedGameMode == .dailyWord {
												RoundedRectangle(cornerRadius: 10)
													.foregroundStyle(appManager.gradient)
													.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
											} else {
												RoundedRectangle(cornerRadius: 15)
													.foregroundStyle(Color(uiColor: .systemGreen))

												}
										}
								})
								.accessibilityHint("Starts the next game.")
								.accessibilityInputLabels(["New word", "Unlimited"])
								.glassEffect(self.userWantsNormalTheme || !self.userWantsNormalTheme && self.gameColorScheme == .dark && appManager.selectedGameMode == .normal ? .regular.tint(.green).interactive() : .regular.interactive(), in: .rect(cornerRadius: 10.0))
								.glassEffectID("new", in: self.namespace)
								.padding(.horizontal, 20)
								.conditionalHaptic(.impact, trigger: self.didTapNewGameButton)
								.conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)

								Spacer()

								NavigationLink(destination: WordDefinitionView(word: appManager.word, language: appManager.selectedLanguage), label: {
									Text("Show definition")
										.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
										.font(.title2).bold()
										.lineLimit(2)
										.minimumScaleFactor(0.8)
										.multilineTextAlignment(.center)
										.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
										.foregroundStyle(.white)
										.background {
											let useGreen = !self.userWantsNormalTheme && self.gameColorScheme == .dark && appManager.selectedGameMode == .dailyWord
											RoundedRectangle(cornerRadius: 15)
												.foregroundStyle(Color(uiColor: useGreen ? .systemGreen : .systemOrange))
										}

								})
								.accessibilityHint("Opens the definition for the answer.")
								.simultaneousGesture(TapGesture().onEnded {
									self.didTapShowDefinitionButton.toggle()
									adManager.shouldShowAds = true
								})
								.glassEffect(.regular.tint(!self.userWantsNormalTheme && self.gameColorScheme == .dark && appManager.selectedGameMode == .dailyWord ? .green : .orange).interactive(), in: .rect(cornerRadius: 10.0))
								.glassEffectID("definition", in: self.namespace)
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
											AnalyticsManager.shared.logDidCopyResultEvent(copySource: "current_game_button")
										}
									} label: {
											Label("Copy result", systemImage: appManager.hasSharedResult ? "doc.on.doc.fill" : "doc.on.doc")
												.font(.title2).bold()
											.contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
											.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
											.tint(.primary)
									}
									.accessibilityHint("Copies your shareable game result.")
									.accessibilityInputLabels(["Copy result", "Copy"])

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
											message: Text("You will lose your word and you cannot undo this action"),
											primaryButton: .destructive(Text("Restart")) {
												self.alertItem = AlertItem(
													title: Text("The word was: \(appManager.word)"),
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
											AnalyticsManager.shared.logDidCopyResultEvent(copySource: "current_game_keyboard_shortcut")
										}
									}
								}
							)
						)
					}
					.frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
				}
				.darkGradientBackground(colorScheme: colorScheme)
				.navigationDestination(isPresented: self.$isShowingCurrentDefinition, destination: {
					WordDefinitionView(word: appManager.word, language: appManager.language)
						.environment(appManager)
				})
				.navigationTitle(appManager.numberOfLetters == 1 ? "Guess the letter" : "Guess the word")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItemGroup(placement: .topBarTrailing) {
						if showHintButton {
							AdButton(shouldShowHintTip: showHintButton)
								.environment(appManager)

							SearchToolbarItem()
								.environment(appManager)

						} else {
							SearchToolbarItem()
								.environment(appManager)
						}
					}
				}
				.onChange(of: appManager.shouldShowAdButton) {
					withAnimation(.smooth) {
						showHintButton = appManager.isHintAvailable() && (appManager.shouldShowAdButton || storeManager.isAdRemovalPurchased) && !appManager.isGameOver
					}
				}
				.onChange(of: appManager.isGameOver) {
					withAnimation(.smooth) {
						showHintButton = appManager.isHintAvailable() && (appManager.shouldShowAdButton || storeManager.isAdRemovalPurchased) && !appManager.isGameOver
					}
				}
				.onChange(of: appManager.keyboard) {
					let newValue = appManager.isHintAvailable() && (appManager.shouldShowAdButton || storeManager.isAdRemovalPurchased) && !appManager.isGameOver
					if newValue != showHintButton {
						withAnimation(.smooth) {
							showHintButton = newValue
						}
					}
				}
			}
			.onAppear {
				AnalyticsManager.shared.logScreenViewed(screenName: "GameView26")
				appManager.prepareGameForSelectedOptions()
				showHintButton = appManager.isHintAvailable() && (appManager.shouldShowAdButton || storeManager.isAdRemovalPurchased) && !appManager.isGameOver
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
			.onChange(of: appManager.shouldPromptForProAfterGameCompletion) { _, shouldPrompt in
				guard shouldPrompt else { return }
				presentProPromptIfNeeded()
			}
			.onChange(of: appManager.isGameOver) {
				presentNotificationPromptIfNeeded()
				presentProPromptIfNeeded()
			}
			.onChange(of: appManager.isAnimating) {
				presentNotificationPromptIfNeeded()
				presentProPromptIfNeeded()
			}
			.onChange(of: self.alertItem?.title) {
				if self.alertItem != nil {
					self.didTapResetButton.toggle()
				} else {
					presentNotificationPromptIfNeeded()
					presentProPromptIfNeeded()
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
				if !appManager.hasLoadedAd {
					await appManager.loadAd()
					appManager.hasLoadedAd = true
				}
			}
		}
	}

	private func handleRowRevealComplete(rowIndex: Int) {
		appManager.shouldShowCelebrationGradient = true
		appManager.applyPendingGameCompletion()
		guard lastAnnouncedRevealedRow != rowIndex,
			  appManager.board.indices.contains(rowIndex) else {
			return
		}

		lastAnnouncedRevealedRow = rowIndex
		let announcement = WordlrAccessibilityFormatter.rowLabel(
			row: appManager.board[rowIndex],
			rowIndex: rowIndex,
			currentRow: appManager.currentRow
		)
		UIAccessibility.post(notification: .announcement, argument: announcement)
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
				let increment = currentThreshold <= 10 ? 25 : 50
				UserDefaults.standard.set(currentWins + increment, forKey: "notificationPromptNextWinThreshold")
				appManager.shouldPromptForNotificationsAfterFirstWin = false
			}
		)
	}

	private func presentProPromptIfNeeded() {
		guard appManager.isGameOver,
			  !appManager.isAnimating,
			  appManager.shouldPromptForProAfterGameCompletion,
			  !storeManager.isAdRemovalPurchased,
			  !hasQueuedProPromptForCurrentGame,
			  alertItem == nil else {
			return
		}

		hasQueuedProPromptForCurrentGame = true
		alertItem = AlertItem(
			title: Text("Tired of ads?"),
			message: Text("Upgrade to Pro to remove ads and get free hints."),
			primaryButton: .default(Text("Go to Settings")) {
				appManager.shouldPromptForProAfterGameCompletion = false
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					AppState.shared.navigateToSettingsTrigger = true
				}
			},
			secondaryButton: .cancel(Text("Not now")) {
				appManager.shouldPromptForProAfterGameCompletion = false
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

	private static func polishAlternateLetters(for letter: String) -> [String] {
		switch letter {
			case "A": return ["Ą"]
			case "C": return ["Ć"]
			case "E": return ["Ę"]
			case "L": return ["Ł"]
			case "N": return ["Ń"]
			case "O": return ["Ó"]
			case "S": return ["Ś"]
			case "Z": return ["Ź", "Ż"]
			default: return []
		}
	}
}

struct AdButton: View {
	@Environment(AppManager.self) private var appManager
	@Environment(StoreManager.self) private var storeManager
	@Environment(\.colorScheme) private var colorScheme
	@State private var didTap: Bool = false
	let shouldShowHintTip: Bool
	let hintTip = HintTip()

	var body: some View {
		let button = Button(action: {
				self.didTap.toggle()
				self.hintTip.invalidate(reason: .actionPerformed)
				Task {
					await HintTip.getHintEvent.donate()
				}
				if !appManager.isGameOver && !appManager.isAnimating {
					if storeManager.isAdRemovalPurchased {
						appManager.getHint()
					} else if appManager.hasLoadedAd {
						appManager.showAd()
					} else {
						Task {
							await appManager.loadAd()
							appManager.showAd()
						}
					}
				}
			}, label: {
				Image(systemName: colorScheme == .light ? "lightbulb.max" : "lightbulb.max.fill")
					.contentShape(Rectangle())
			})
			.task {
				if !storeManager.isAdRemovalPurchased && !appManager.hasLoadedAd {
					await appManager.loadAd()
					appManager.hasLoadedAd = true
				}
			}
			.conditionalHaptic(.selection, trigger: self.didTap)

		Group {
			if shouldShowHintTip {
				button.popoverTip(self.hintTip)
			} else {
				button
			}
		}
		.accessibilityLabel("Get hint")
		.accessibilityHint(storeManager.isAdRemovalPurchased ? "Reveals one hint." : "Shows an ad, then reveals one hint.")
		.accessibilityInputLabels(["Hint", "Get hint", "Lightbulb"])
	}
}

struct SearchToolbarItem: View {
	@Environment(AppManager.self) private var appManager
	@State var didTapSearchButton: Bool = false
	private let searchTip = SearchTip()
	
	var body: some View {
		NavigationLink(destination: SearchView().environment(appManager), label: {
			Label("Search", systemImage: "magnifyingglass")
				.labelStyle(.iconOnly)
				.contentShape(Rectangle())
		})
		.simultaneousGesture(TapGesture().onEnded {
			self.didTapSearchButton.toggle()
			Task {
				await SearchTip.searchEvent.donate()
			}
		})
		.conditionalHaptic(.selection, trigger: self.didTapSearchButton)
		.popoverTip(self.searchTip)
		.accessibilityLabel("Search")
		.accessibilityHint("Opens word search.")
		.accessibilityInputLabels(["Search", "Word search", "Magnifying glass"])
	}
}

@available(iOS 26.0, *)
private struct KeyboardGlassEffect: ViewModifier {
	let isEnabled: Bool
	let tint: Color
	let cornerRadius: CGFloat
	let id: String
	let namespace: Namespace.ID

	@ViewBuilder
	func body(content: Content) -> some View {
		if isEnabled {
			content
				.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
				.glassEffectID(id, in: namespace)
		} else {
			content
		}
	}
}

struct KeyboardKeyButton18: View {
	@Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

	let key: KeyBoardLetter
	let colorForUnused: Color
	let colorScheme: ColorScheme
	let width: CGFloat
	let height: CGFloat
	let action: () -> Void
	
	@State private var feedbackTrigger: Bool = false
	
	var body: some View {
		Button {
			action()
			feedbackTrigger.toggle()
		} label: {
			Text(key.letter)
				.font(.title2).bold()
				.foregroundStyle(key.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
				.frame(minWidth: width / CGFloat(14), maxWidth: width / CGFloat(12), minHeight: height / CGFloat(10), idealHeight: height / CGFloat(8), maxHeight: height / CGFloat(6))
				.background {
					RoundedRectangle(cornerRadius: 5)
						.fill(keyColor)
				}
				.overlay {
					if colorScheme == .light && key.state == .notUsed {
						RoundedRectangle(cornerRadius: 5)
							.stroke(Color(uiColor: .systemGray4), lineWidth: 1)
					}
				}
				.overlay(alignment: .bottomTrailing) {
					if differentiateWithoutColor, let symbolName = key.state.accessibilitySymbolName {
						Image(systemName: symbolName)
							.font(.caption2.bold())
							.foregroundStyle(key.state == .notUsed ? .black : .white)
							.padding(3)
							.accessibilityHidden(true)
					}
				}
		}
		.buttonStyle(ScalingButton(isEnabled: colorScheme == .light))
		.conditionalHaptic(.impact, trigger: feedbackTrigger)
		.accessibilityLabel(WordlrAccessibilityFormatter.keyboardKeyLabel(key: key))
		.accessibilityValue(WordlrAccessibilityFormatter.keyboardKeyValue(key: key))
		.accessibilityHint(WordlrAccessibilityFormatter.keyboardKeyHint(key: key))
		.accessibilityInputLabels([LocalizedStringKey(key.letter), LocalizedStringKey(WordlrAccessibilityFormatter.keyboardKeyLabel(key: key))])
	}
	
	private var keyColor: Color {
		switch key.state {
			case .correctPosition:
				return .green
			case .correctLetter:
				return .orange
			case .usedButNotCorrect:
				return Color(UIColor.darkGray)
			case .notUsed:
				return colorForUnused
		}
	}
}

@available(iOS 26.0, *)
struct KeyboardKeyButton26: View {
	@Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

	let key: KeyBoardLetter
	let colorForUnused: Color
	let colorForWhenAppInBackground: Color
	let colorScheme: ColorScheme
	let alternateLetters: [String]
	let namespace: Namespace.ID
	let width: CGFloat
	let height: CGFloat
	let action: (String) -> Void
	
	@State private var feedbackTrigger: Bool = false
	@State private var isShowingAlternateLetters: Bool = false
	@State private var didHandleLongPress: Bool = false
	
	var body: some View {
		Button {
			if didHandleLongPress {
				didHandleLongPress = false
				return
			}
			action(key.letter)
			feedbackTrigger.toggle()
		} label: {
			Text(key.letter)
				.font(.title2).bold()
				.foregroundStyle(key.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
				.frame(minWidth: width / CGFloat(14), maxWidth: width / CGFloat(12), minHeight: height / CGFloat(10), idealHeight: height / CGFloat(8), maxHeight: height / CGFloat(6))
				.background {
					RoundedRectangle(cornerRadius: 5)
						.foregroundStyle(backgroundKeyColor)
				}
//				.overlay {
//					if colorScheme == .light && key.state == .notUsed {
//						RoundedRectangle(cornerRadius: 5)
//							.stroke(Color(uiColor: .systemGray4), lineWidth: 1)
//					}
//				}
				.overlay(alignment: .bottomTrailing) {
					if differentiateWithoutColor, let symbolName = key.state.accessibilitySymbolName {
						Image(systemName: symbolName)
							.font(.caption2.bold())
							.foregroundStyle(key.state == .notUsed ? .black : .white)
							.padding(3)
							.accessibilityHidden(true)
					}
				}
		}
		.simultaneousGesture(
			LongPressGesture(minimumDuration: 0.35).onEnded { _ in
				guard !alternateLetters.isEmpty else { return }
				didHandleLongPress = true
				isShowingAlternateLetters = true
				feedbackTrigger.toggle()
			}
		)
		.popover(isPresented: $isShowingAlternateLetters, arrowEdge: .bottom) {
			HStack(spacing: 8) {
				ForEach(alternateLetters, id: \.self) { letter in
					Button {
						action(letter)
						feedbackTrigger.toggle()
						isShowingAlternateLetters = false
					} label: {
						Text(letter)
							.font(.title2.bold())
							.foregroundStyle(.primary)
							.frame(width: 44, height: 44)
							.background {
								RoundedRectangle(cornerRadius: 8)
									.foregroundStyle(Color(uiColor: .secondarySystemBackground))
							}
					}
					.buttonStyle(ScalingButton())
				}
			}
			.padding(10)
			.presentationCompactAdaptation(.popover)
		}
//		.buttonStyle(ScalingButton())
		.modifier(
			KeyboardGlassEffect(
				isEnabled: true,
				tint: keyColor,
				cornerRadius: 5,
				id: "\(key.letter)",
				namespace: namespace
			)
		)
		.conditionalHaptic(.impact, trigger: feedbackTrigger)
		.accessibilityLabel(WordlrAccessibilityFormatter.keyboardKeyLabel(key: key))
		.accessibilityValue(WordlrAccessibilityFormatter.keyboardKeyValue(key: key))
		.accessibilityHint(WordlrAccessibilityFormatter.keyboardKeyHint(key: key))
		.accessibilityInputLabels([LocalizedStringKey(key.letter), LocalizedStringKey(WordlrAccessibilityFormatter.keyboardKeyLabel(key: key))])
	}
	
	private var keyColor: Color {
		switch key.state {
			case .correctPosition:
				return .green
			case .correctLetter:
				return .orange
			case .usedButNotCorrect:
				return Color(UIColor.darkGray)
			case .notUsed:
				return colorForUnused
		}
	}
	
	private var backgroundKeyColor: Color {
		switch key.state {
			case .correctPosition:
				return Color(uiColor: .systemGreen)
			case .correctLetter:
				return Color(uiColor: .systemOrange)
			case .usedButNotCorrect:
				return Color(UIColor.darkGray)
			case .notUsed:
				return colorForWhenAppInBackground
		}
	}
}

struct GrowingButton: ButtonStyle {
	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed && !reduceMotion ? 1.05 : 1)
			.animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: configuration.isPressed)
	}
}

struct ScalingButton: ButtonStyle {
	@Environment(\.accessibilityReduceMotion) private var reduceMotion

	var isEnabled: Bool = true

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(isEnabled && configuration.isPressed && !reduceMotion ? 1.1 : 1)
			.animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: configuration.isPressed)
	}
}



#Preview {
	GameView26()
		.environment(AppManager())
}
