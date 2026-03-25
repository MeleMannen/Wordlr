//
//  SelectView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI

struct SelectView: View {
    @Environment(\.modelContext) var modelContext
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.scenePhase) private var scenePhase
	@Environment(AdManager.self) private var adManager: AdManager
    @StateObject var appManager = AppManager()
	@StateObject var reviewManager = ReviewManager()
	@StateObject var appState = AppState.shared
    @AppStorage("hasAddedStreaks") private var hasAddedStreaks: Bool = false
	@AppStorage("hasAddedSpanishStreaks") private var hasAddedSpanishStreaks: Bool = false
    @AppStorage("hasAddedNormalStreaks") private var hasAddedNormalStreaks: Bool = false
	@AppStorage("hasAddedSpanishNormalStreaks") private var hasAddedSpanishNormalStreaks: Bool = false
    @AppStorage("hasFixedLanguage") private var hasFixedLanguage: Bool = false
	@AppStorage("userWantsAds") private var userWantsAds: Bool = true
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
    @State var hasFixedDefualtValues: Bool = false
    @State var hasFixedContextAndFetched: Bool = false
    @State var didTapPlayDailyWordButton: Bool = false
    @State var didTapFakePlayDailyWordButton: Bool = false
    @State var didTapPlayNormalButton: Bool = false
    @State var didTapInfoButton: Bool = false
    @State var isShowingAlreadyPlayedAlert: Bool = false
	@State var didTapChangeOfGame: Bool = false
	@Binding var selection: TabSelection
	@State var isAllowedToPlayDailyWordAgain: Bool = true
	@State var isAllowedToChooseGameModeAgain: Bool = true
	@State var alertItem: AlertItem?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer()
                    VStack {
						Text("Number of Letters")
							.font(.title2).bold()
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						if #available(iOS 26.0, *) {
							Picker(selection: $appManager.numberOfLetters) {
								ForEach(1...8, id: \.self) { number in
									if number == 1 {
										Text("\(number) Letter")
											.tag(number)
									} else {
										Text("\(number) Letters")
											.tag(number)
									}
								}
							} label: {
								
							}
							.background {
								Capsule()
									.foregroundStyle(Color(uiColor: .systemGray6))
							}
							.glassEffect(.regular.interactive())
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.sensoryFeedback(.selection, trigger: appManager.numberOfLetters)
							.frame(maxWidth: .infinity, alignment: .trailing)
						} else {
							Picker(selection: $appManager.numberOfLetters) {
								ForEach(1...8, id: \.self) { number in
									if number == 1 {
										Text("\(number) Letter")
									} else {
										Text("\(number) Letters")
									}
								}
							} label: {
								
							}
							.pickerStyle(.menu)
							.foregroundStyle(.primary)
							.accentColor(.primary)
							.background {
								RoundedRectangle(cornerRadius: 10)
									.foregroundStyle(Color(uiColor: .tertiarySystemBackground))
									.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							}
							.sensoryFeedback(.selection, trigger: appManager.numberOfLetters)
							.frame(maxWidth: .infinity, alignment: .trailing)
						}
					}
					.padding(.bottom, 30)
					
					Spacer()
					
					VStack {
						Text("Language")
							.font(.title2).bold()
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						if #available(iOS 26.0, *) {
							Picker(selection: $appManager.selectedLanguage) {
								ForEach(LanguageSelection.languages) { language in
									Text(language.localizedName.capitalized)
								}
							} label: {
								
							}
							.background {
								Capsule()
									.foregroundStyle(Color(uiColor: .systemGray6))
							}
							.glassEffect(.regular.interactive())
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.sensoryFeedback(.selection, trigger: appManager.selectedLanguage)
							.frame(maxWidth: .infinity, alignment: .trailing)
						} else {
							Picker(selection: $appManager.selectedLanguage) {
								ForEach(LanguageSelection.languages) { language in
									Text(language.localizedName.capitalized)
								}
							} label: {
								
							}
							.pickerStyle(.menu)
							.foregroundStyle(.primary)
							.accentColor(.primary)
							.background {
								RoundedRectangle(cornerRadius: 10)
									.foregroundStyle(Color(uiColor: .tertiarySystemBackground))
									.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							}
							.sensoryFeedback(.selection, trigger: appManager.selectedLanguage)
							.frame(maxWidth: .infinity, alignment: .trailing)
						}
					}
					.padding(.bottom, 30)
					
					Spacer()
					Spacer()
					
					if #available(iOS 26.0, *) {
						VStack {
							if appManager.hasGameStarted() && appManager.selectedGameMode != .normal && !self.isAllowedToChooseGameModeAgain {
								if let streakEntity = appManager.getNormalStreakEntity(), streakEntity.streak.currentStreak >= 3 {
									VStack {
										Text("Play Unlimited\n\(streakEntity.streak.currentStreak)🔥")
											.multilineTextAlignment(.center)
											.lineSpacing(5)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												RoundedRectangle(cornerRadius: 15)
													.foregroundStyle(.green.opacity(0.3))
											}
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												self.didTapChangeOfGame = true
												self.setGameAlert()
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
										
									}
									.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
								} else {
									VStack {
										Text("Play Unlimited")
											.multilineTextAlignment(.center)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												RoundedRectangle(cornerRadius: 15)
													.foregroundStyle(.green.opacity(0.3))
											}
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												self.didTapChangeOfGame = true
												self.setGameAlert()
												
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
									}
									.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
								}
								
								
							} else {
								VStack {
									NavigationLink(destination: GameView().environmentObject(appManager)) {
										if let streakEntity = appManager.getNormalStreakEntity(), streakEntity.streak.currentStreak >= 3 {
											Text("Play Unlimited\n\(streakEntity.streak.currentStreak)🔥")
												.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
												.multilineTextAlignment(.center)
												.lineSpacing(5)
												.font(.title2).bold()
												.padding()
												.foregroundStyle(.white)
												.frame(maxWidth: .infinity)
												.background {
													if self.scenePhase == .background {
														RoundedRectangle(cornerRadius: 15)
															.foregroundStyle(Color(uiColor: .systemGreen))
														
													}
												}
										} else {
											Text("Play Unlimited")
												.font(.title2).bold()
												.padding()
												.foregroundStyle(.white)
												.frame(maxWidth: .infinity)
												.background {
													if self.scenePhase == .background {
														RoundedRectangle(cornerRadius: 15)
															.foregroundStyle(Color(uiColor: .systemGreen))
														
													}
												}
										}
									}
									.simultaneousGesture(TapGesture().onEnded {
										self.didTapPlayNormalButton.toggle()
										appManager.selectedGameMode = .normal
										Task {
											await HintTip.gamesPlayedEvent.donate()
										}
									})
									.sensoryFeedback(.impact, trigger: self.didTapPlayNormalButton)
									.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
								}
								
								.glassEffect(.regular.tint(.green).interactive(), in: .rect(cornerRadius: 15.0))
								
								
							}
						}
						.padding(.horizontal, 30)
						.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
						.padding(.bottom, 25)
					} else {
						if appManager.hasGameStarted() && appManager.selectedGameMode != .normal && !self.isAllowedToChooseGameModeAgain {
							if let streakEntity = appManager.getNormalStreakEntity(), streakEntity.streak.currentStreak >= 3 {
								VStack {
									Text("Play Unlimited\n\(streakEntity.streak.currentStreak)🔥")
										.multilineTextAlignment(.center)
										.lineSpacing(5)
										.font(.title2).bold()
										.padding()
										.frame(maxWidth: .infinity)
										.foregroundStyle(.white)
										.background {
											RoundedRectangle(cornerRadius: 15)
												.foregroundStyle(.green.opacity(0.3))
										}
										.padding(.horizontal, 30)
										.onTapGesture {
											self.didTapFakePlayDailyWordButton.toggle()
											self.didTapChangeOfGame = true
											self.setGameAlert()
										}
										.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
									
								}
								.padding(.bottom, 25)
							} else {
								VStack {
									Text("Play Unlimited")
										.multilineTextAlignment(.center)
										.font(.title2).bold()
										.padding()
										.frame(maxWidth: .infinity)
										.foregroundStyle(.white)
										.background {
											RoundedRectangle(cornerRadius: 15)
												.foregroundStyle(.green.opacity(0.3))
										}
										.padding(.horizontal, 30)
										.onTapGesture {
											self.didTapFakePlayDailyWordButton.toggle()
											self.didTapChangeOfGame = true
											self.setGameAlert()
											
										}
										.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
								}
								.padding(.bottom, 25)
							}
							
							
						} else {
							VStack {
								NavigationLink(destination: GameView().environmentObject(appManager)) {
									if let streakEntity = appManager.getNormalStreakEntity(), streakEntity.streak.currentStreak >= 3 {
										Text("Play Unlimited\n\(streakEntity.streak.currentStreak)🔥")
											.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
											.multilineTextAlignment(.center)
											.lineSpacing(5)
										//										.conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
											.font(.title2).bold()
											.padding()
											.foregroundStyle(.white)
											.frame(maxWidth: .infinity)
											.background {
												RoundedRectangle(cornerRadius: 15)
													.foregroundStyle(.green)
												
											}
											.padding(.horizontal, 30)
									} else {
										Text("Play Unlimited")
										//										.conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
										
											.font(.title2).bold()
											.padding()
											.foregroundStyle(.white)
											.frame(maxWidth: .infinity)
											.background {
												RoundedRectangle(cornerRadius: 15)
													.foregroundStyle(.green)
											}
											.padding(.horizontal, 30)
									}
								}
								.simultaneousGesture(TapGesture().onEnded {
									self.didTapPlayNormalButton.toggle()
									appManager.selectedGameMode = .normal
									Task {
										await HintTip.gamesPlayedEvent.donate()
									}
								})
								.sensoryFeedback(.impact, trigger: self.didTapPlayNormalButton)
								.buttonStyle(GrowingButton())
								
								.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							}
							.padding(.bottom, 25)
						}
//						.padding(.bottom, 25)
					}
                    
					if #available(iOS 26.0, *) {
						VStack {
							if appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain || appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain {
								if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
									VStack {
										Text("Play Daily Wordly\n\(streakEntity.streak.currentStreak)🔥")
											.multilineTextAlignment(.center)
											.lineSpacing(5)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground(opacity: 0.3)
													.environmentObject(appManager)
											}
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												if appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain {
													self.isShowingAlreadyPlayedAlert = true
													self.setDailyWordAlreadyPlayedAlert()
												} else if appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain {
													self.didTapChangeOfGame = true
													self.setGameAlert()
												}
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
										
									}
									.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
								} else {
									VStack {
										Text("Play Daily Wordly")
											.multilineTextAlignment(.center)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground(opacity: 0.3)
													.environmentObject(appManager)
											}
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												if appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain {
													self.isShowingAlreadyPlayedAlert = true
													self.setDailyWordAlreadyPlayedAlert()
												} else if appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain {
													self.didTapChangeOfGame = true
													self.setGameAlert()
												}
												
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
									}
									.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
								}
								
								
							} else {
								NavigationLink(destination: GameView().environmentObject(appManager)) {
									if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
										Text("Play Daily Wordly\n\(streakEntity.streak.currentStreak)🔥")
											.multilineTextAlignment(.center)
											.lineSpacing(5)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground2()
													.environmentObject(appManager)
											}
									} else {
										Text("Play Daily Wordly")
											.multilineTextAlignment(.center)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground2()
													.environmentObject(appManager)
											}
									}
								}
								.simultaneousGesture(TapGesture().onEnded {
									self.didTapPlayDailyWordButton.toggle()
									appManager.selectedGameMode = .dailyWord
									Task {
										await HintTip.gamesPlayedEvent.donate()
									}
									
								})
								.sensoryFeedback(.impact, trigger: self.didTapPlayDailyWordButton)
								.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
								.glassEffect((self.userWantsNormalTheme || self.colorScheme == .light) ? .regular.tint(.green).interactive() : .regular.interactive(), in: .rect(cornerRadius: 15.0))
								
							}
						}
						.padding(.horizontal, 30)
						.padding(.bottom, 10)
					} else {
						VStack {
							if appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain || appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain {
								if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
									VStack {
										Text("Play Daily Wordly\n\(streakEntity.streak.currentStreak)🔥")
											.multilineTextAlignment(.center)
											.lineSpacing(5)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground(opacity: 0.3)
													.environmentObject(appManager)
											}
											.padding(.horizontal, 30)
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												if appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain {
													self.isShowingAlreadyPlayedAlert = true
													self.setDailyWordAlreadyPlayedAlert()
												} else if appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain {
													self.didTapChangeOfGame = true
													self.setGameAlert()
												}
												
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
										
									}
								} else {
									VStack {
										Text("Play Daily Wordly")
											.multilineTextAlignment(.center)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground(opacity: 0.3)
													.environmentObject(appManager)
											}
											.padding(.horizontal, 30)
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												if appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain {
													self.isShowingAlreadyPlayedAlert = true
													self.setDailyWordAlreadyPlayedAlert()
												} else if appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain {
													self.didTapChangeOfGame = true
													self.setGameAlert()
												}
												
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
									}
								}
								
								
							} else {
								NavigationLink(destination: GameView().environmentObject(appManager)) {
									if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
										Text("Play Daily Wordly\n\(streakEntity.streak.currentStreak)🔥")
											.multilineTextAlignment(.center)
											.lineSpacing(5)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
											}
											.padding(.horizontal, 30)
									} else {
										Text("Play Daily Wordly")
											.multilineTextAlignment(.center)
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
											}
											.padding(.horizontal, 30)
									}
								}
								.simultaneousGesture(TapGesture().onEnded {
									self.didTapPlayDailyWordButton.toggle()
									appManager.selectedGameMode = .dailyWord
									Task {
										await HintTip.gamesPlayedEvent.donate()
									}
								})
								.sensoryFeedback(.impact, trigger: self.didTapPlayDailyWordButton)
								.buttonStyle(GrowingButton())
								.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							}
						}
						.padding(.bottom, 10)
					}
                }
				.alert(item: self.$alertItem) { item in
					if let primaryButton = item.primaryButton, let secondaryButton = item.secondaryButton {
						Alert(title: item.title, message: item.message, primaryButton: primaryButton, secondaryButton: secondaryButton)
					} else {
						Alert(title: item.title)
					}
				}
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                }
                .padding(.horizontal)
            }
			.safeAreaPadding(.bottom, (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac) && self.userWantsAds ? 80 : (self.userWantsAds ? 54 : 0))
            .toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: Info().environmentObject(appManager).environmentObject(appState)) {
						Image(systemName: "info")
							.font(.title2)
							.foregroundStyle(.primary)
					}
					.simultaneousGesture(TapGesture().onEnded {
						self.didTapInfoButton.toggle()
					})
					.sensoryFeedback(.selection, trigger: self.didTapInfoButton)
				}
            }
        }
		.navigationTitle(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordly")
		.onChange(of: appState.navigateHomeTrigger) {
			if appState.selectedLanguageName != nil {
				if appState.selectedLanguageName == LanguageSelection.english.rawValue {
					appManager.selectedLanguage = .english
				} else if appState.selectedLanguageName == LanguageSelection.norwegian.rawValue {
					appManager.selectedLanguage = .norwegian
				} else if appState.selectedLanguageName == LanguageSelection.spanish.rawValue {
					appManager.selectedLanguage = .spanish
				}
			}
			appManager.numberOfLetters = appState.numberOfLetters ?? 5
			self.selection = .home
		}
		.onChange(of: self.didTapPlayDailyWordButton) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = false
			}
		}
		.onChange(of: self.didTapPlayNormalButton) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = false
			}
		}
		.onChange(of: self.didTapInfoButton) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = true
			}
		}
		.onChange(of: appManager.hasGameStarted()) { oldValue, newValue in
			if newValue {
				self.isAllowedToChooseGameModeAgain = false
			}
		}
		.onChange(of: appManager.selectedLanguage) {
			self.isAllowedToChooseGameModeAgain = true
		}
		.onChange(of: appManager.numberOfLetters) {
			self.isAllowedToChooseGameModeAgain = true
		}
        .onAppear {
			appManager.message = ""
			self.isAllowedToPlayDailyWordAgain = false
            if !self.hasFixedContextAndFetched {
                appManager.modelContext = modelContext
                appManager.streakManager = StreakManager(context: modelContext)
                appManager.normalStreakManager = NormalStreakManager(context: modelContext)
                appManager.gameRecordManager = GameRecordManager(context: modelContext)
				
                if !self.hasAddedStreaks {
                    appManager.addStreaks()
                    self.hasAddedStreaks = true
					self.hasAddedSpanishStreaks = true
				} else if !self.hasAddedSpanishStreaks {
					appManager.addSpanishStreaks()
					self.hasAddedSpanishStreaks = true
				}
                
                if !self.hasAddedNormalStreaks {
                    appManager.addNormalStreaks()
                    self.hasAddedNormalStreaks = true
				} else if !self.hasAddedSpanishNormalStreaks {
					appManager.addSpanishNormalStreaks()
					self.hasAddedSpanishNormalStreaks = true
				}
                
                appManager.fetchStreaks()
                appManager.fetchNormalStreaks()
                appManager.fetchGameRecords()
                self.hasFixedContextAndFetched = true
            }
            
            if !self.hasFixedDefualtValues {
                appManager.setDefaultValues()
                self.hasFixedDefualtValues = true
            }
            
            if !self.hasFixedLanguage {
                appManager.fixLanguageBasedOnLocale()
                self.hasFixedLanguage = true
            }
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = true
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				reviewManager.checkForReviewPrompt()
			}
			AnalyticsManager.shared.logScreenViewed(screenName: "SelectView")
        }
    }
	
	func setGameAlert() {
		self.alertItem = AlertItem(title: Text("Discard current Word?"), message: Text("Are you sure that you want to discard your current Word?"), primaryButton: .cancel({
			self.isAllowedToChooseGameModeAgain = false
		}), secondaryButton: .destructive(Text("I'm Sure"), action: {
			self.isAllowedToChooseGameModeAgain = true
		}))
	}
	
	func setDailyWordAlreadyPlayedAlert() {
		self.alertItem = AlertItem(title: Text("You have already played this Word"), message: Text("You have already played this exact Word today. Are you sure you want to play the same Word again?"), primaryButton: .cancel(), secondaryButton: .default(Text("I'm Sure"), action: {
			self.isAllowedToPlayDailyWordAgain = true
			self.isAllowedToChooseGameModeAgain = true
		}))
	}
}

final class AppState: ObservableObject {
	static let shared = AppState()
	
	@Published var navigateHomeTrigger = UUID()
	@Published var selectedLanguageName: String?
	@Published var numberOfLetters: Int?
	
	func applyReminder(languageName: String?, numberOfLetters: Int?) {
		self.selectedLanguageName = languageName
		self.numberOfLetters = numberOfLetters
		self.navigateHomeTrigger = UUID()
	}
}


struct ConditionalButtonBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var appManager: AppManager
    @AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	var opacity: Double = 1.0
	
    
    var body: some View {
        if !self.userWantsNormalTheme && self.colorScheme == .dark {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(appManager.gradient.opacity(self.opacity))
                .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
            
        } else {
            RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(Color.green.opacity(self.opacity))
        }
    }
}

struct ConditionalButtonBackground2: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.scenePhase) private var scenePhase
	@EnvironmentObject var appManager: AppManager
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	
	var body: some View {
		if !self.userWantsNormalTheme && self.colorScheme == .dark {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(appManager.gradient)
				.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
			
		} else if self.scenePhase == .background {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(Color(uiColor: .systemGreen))
			
		}
	}
}


struct ConditionalGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
				.tint(.primary)
                .glassEffect(.regular.interactive())
        } else {
            content
				.tint(.primary)
        }
    }
}

struct ConditionalPadding: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			content
				.padding(.vertical, 4)
		} else {
			content
		}
	}
}

struct ConditionalShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        Group {
            if appTheme == .dark || colorScheme == .dark {
                content
                    .shadow(color: color, radius: radius, x: x, y: y)
            } else {
                content
            }
        }
    }
}

extension View {
    func conditionalShadow(
        color: Color = .black.opacity(0.33),
        radius: CGFloat = 4,
        x: CGFloat = 4,
        y: CGFloat = 4
    ) -> some View {
        modifier(
            ConditionalShadow(
                color: color,
                radius: radius,
                x: x,
                y: y
            )
        )
    }
}


#Preview {
	SelectView(selection: .constant(.home))
}
