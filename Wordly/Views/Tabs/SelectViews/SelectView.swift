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
	@Environment(AdManager.self) private var adManager
	@State private var appManager = AppManager()
	@StateObject var reviewManager = ReviewManager()
	@StateObject var appState = AppState.shared
	@AppStorage("hasFixedLanguage") private var hasFixedLanguage: Bool = false
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
						Text("Word length")
							.font(.title2).bold()
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						if #available(iOS 26.0, *) {
							HStack {
								Spacer(minLength: 0)

								UIKitMenuPicker(
									selection: $appManager.numberOfLetters,
									options: Array(1...8)
								) { number in
									if number == 1 {
										return String(
											format: NSLocalizedString(
												"%lld letter",
												comment: "Number of letters singular"
											),
											number
										)
									} else {
										return String(
											format: NSLocalizedString(
												"%lld letters",
												comment: "Number of letters plural"
											),
											number
										)
									}
								}
								.fixedSize(horizontal: true, vertical: false)
							}
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.conditionalHaptic(.selection, trigger: appManager.numberOfLetters)
							.frame(height: 36)
						} else {
							Picker(selection: $appManager.numberOfLetters) {
								ForEach(1...8, id: \.self) { number in
									if number == 1 {
										Text("\(number) letter")
									} else {
										Text("\(number) letters")
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
							.conditionalHaptic(.selection, trigger: appManager.numberOfLetters)
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
							HStack {
								Spacer(minLength: 0)

								UIKitMenuPicker(
									selection: $appManager.selectedLanguage,
									options: LanguageSelection.languages,
									title: { $0.localizedName }
								)
								.fixedSize(horizontal: true, vertical: false)
							}
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.conditionalHaptic(.selection, trigger: appManager.selectedLanguage)
							.frame(height: 36)
						} else {
							Picker(selection: $appManager.selectedLanguage) {
								ForEach(LanguageSelection.languages) { language in
									Text(language.localizedName)
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
							.conditionalHaptic(.selection, trigger: appManager.selectedLanguage)
							.frame(maxWidth: .infinity, alignment: .trailing)
						}
					}
					.padding(.bottom, 30)
					
					Spacer()
					Spacer()
					
					SelectGameModeButton(
						title: "Daily Wordlr",
						mode: .dailyWord,
						appManager: appManager,
						streak: self.dailyWordStreak,
						isAvailable: !self.isDailyWordModeBlocked,
						impactTrigger: self.didTapPlayDailyWordButton,
						errorTrigger: self.didTapFakePlayDailyWordButton,
						startAction: self.startDailyWordGame,
						blockedAction: self.showDailyWordBlockedAlert
					)
					.padding(.horizontal, 30)
					.padding(.bottom, 25)

					SelectGameModeButton(
						title: "Free Play",
						mode: .normal,
						appManager: appManager,
						streak: self.normalStreak,
						isAvailable: !self.isNormalModeBlocked,
						impactTrigger: self.didTapPlayNormalButton,
						errorTrigger: self.didTapFakePlayDailyWordButton,
						startAction: self.startNormalGame,
						blockedAction: self.showChangeGameAlert
					)
					.padding(.horizontal, 30)
					.padding(.bottom, 10)
				}
				.alert(item: self.$alertItem) { item in
					if let primaryButton = item.primaryButton, let secondaryButton = item.secondaryButton {
						Alert(title: item.title, message: item.message, primaryButton: primaryButton, secondaryButton: secondaryButton)
					} else {
						Alert(title: item.title)
					}
				}
				.padding(20)
				.wordlrSurface(cornerRadius: 25)
				.padding(.horizontal)
			}
			.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
			.darkGradientBackground(colorScheme: colorScheme)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: Info().environment(appManager).environmentObject(appState)) {
						Label("Info", systemImage: "info")
							.labelStyle(.iconOnly)
							.font(.title2)
							.foregroundStyle(.primary)
					}
					.accessibilityLabel("Info")
					.accessibilityHint("Shows how to play.")
					.accessibilityInputLabels(["Info", "How to play"])
					.simultaneousGesture(TapGesture().onEnded {
						self.didTapInfoButton.toggle()
					})
					.conditionalHaptic(.selection, trigger: self.didTapInfoButton)
				}
			}
		}
		.navigationTitle(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr")
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
			if appManager.selectedGameMode != .dailyWord {
				self.isAllowedToPlayDailyWordAgain = false
			}
			if !self.hasFixedContextAndFetched {
				appManager.modelContext = modelContext
				appManager.gameRecordManager = GameRecordManager(context: modelContext)
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
	
	private var isNormalModeBlocked: Bool {
		appManager.hasGameStarted() &&
		appManager.selectedGameMode != .normal &&
		!self.isAllowedToChooseGameModeAgain
	}
	
	private var isDailyWordModeBlocked: Bool {
		(appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain) ||
		(appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain)
	}
	
	private var normalStreak: Int? {
		guard let streakEntity = appManager.getNormalStreakEntity(), streakEntity.currentStreak > 0 else {
			return nil
		}
		
		return streakEntity.currentStreak
	}
	
	private var dailyWordStreak: Int? {
		guard let streakEntity = appManager.getStreakEntity(), streakEntity.currentStreak > 0, streakEntity.isAlive else {
			return nil
		}
		
		return streakEntity.currentStreak
	}
	
	private func startNormalGame() {
		self.didTapPlayNormalButton.toggle()
		appManager.selectedGameMode = .normal
		Task {
			await HintTip.gamesPlayedEvent.donate()
		}
	}
	
	private func startDailyWordGame() {
		self.didTapPlayDailyWordButton.toggle()
		appManager.selectedGameMode = .dailyWord
		Task {
			await HintTip.gamesPlayedEvent.donate()
		}
	}
	
	private func showChangeGameAlert() {
		self.didTapFakePlayDailyWordButton.toggle()
		self.didTapChangeOfGame = true
		self.setGameAlert()
	}
	
	private func showDailyWordBlockedAlert() {
		self.didTapFakePlayDailyWordButton.toggle()
		
		if appManager.checkIfDailyWordIsAlreadyPlayed() && !self.isAllowedToPlayDailyWordAgain {
			self.isShowingAlreadyPlayedAlert = true
			self.setDailyWordAlreadyPlayedAlert()
		} else if appManager.hasGameStarted() && appManager.selectedGameMode != .dailyWord && !self.isAllowedToChooseGameModeAgain {
			self.didTapChangeOfGame = true
			self.setGameAlert()
		}
	}
	
	func setGameAlert() {
		self.alertItem = AlertItem(title: Text("Discard current word?"), message: Text("Are you sure that you want to discard your current word?"), primaryButton: .cancel({
			self.isAllowedToChooseGameModeAgain = false
		}), secondaryButton: .destructive(Text("I'm sure"), action: {
			self.isAllowedToChooseGameModeAgain = true
		}))
	}
	
	func setDailyWordAlreadyPlayedAlert() {
		self.alertItem = AlertItem(title: Text("You have already played this word"), message: Text("You have already played this exact word today. Are you sure you want to play the same word again?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("I'm sure"), action: {
			self.isAllowedToPlayDailyWordAgain = true
			self.isAllowedToChooseGameModeAgain = true
		}))
	}
}

final class AppState: ObservableObject {
	static let shared = AppState()
	
	@Published var navigateHomeTrigger = UUID()
	@Published var navigateToSettingsTrigger = false
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
	@Environment(AppManager.self) private var appManager
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
	@Environment(AppManager.self) private var appManager
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
