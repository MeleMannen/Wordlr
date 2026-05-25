//
//  StatsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 11/06/2025.
//

import SwiftUI
import Charts
import SwiftData

struct StatsView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Environment(AdManager.self) private var adManager
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .all
	@AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
	@AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
	@AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
	@State private var hasFixedDefualtValues: Bool = false
	@State private var numberOfLetters: Int = 9
	@State private var selectedLanguage: LanguageSelection = .all
	@State private var gameMode: GameMode = .both
	@State private var showsWhenHintsUsed: ShowsWhenHintsUsed = .both
	@State private var maxNumberOfRows: Int = 6
	@State private var filteredGameRecords: [GameRecordEntity] = []
	@State private var wonCount: Int = 0
	@State private var lostCount: Int = 0
	@State private var totalCount: Int = 0
	@State private var winRate: Double = 0.0
	@State private var counts: [Int] = Array(repeating: 0, count: 6)
	@State private var maxGuessesPerCount: Int = 0
	@State private var selectedStreakLanguage: LanguageSelection = .norwegian
	@State private var longestStreakPerLetters: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])] = [(language: .english, streaks: []), (language: .spanish, streaks: []), (language: .norwegian, streaks: [])]
	@State private var longestNormalStreakPerLetters: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])] = [(language: .english, streaks: []), (language: .spanish, streaks: []), (language: .norwegian, streaks: [])]
	@State private var maxStreakLength: Double = 0.0
	@State private var maxNormalStreakLength: Double = 0.0
	@State private var hasCompletedInitialLoad: Bool = false
	@State private var showBarLabels: Bool = false

	@Query private var gameRecords: [GameRecordEntity]

	private let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)

	private var useGradientTheme: Bool {
		!userWantsNormalTheme && colorScheme == .dark
	}

	var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				VStack {
					if #unavailable(iOS 26.0) {
						FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
					}
					if self.filteredGameRecords.isEmpty && self.hasCompletedInitialLoad {
						ContentUnavailableView.init("No stats available for this selection!", systemImage: "exclamationmark.triangle.fill", description: Text("Try playing a game first or changing the selection."))
							.padding(.bottom, 20)
							.darkGradientBackground(colorScheme: colorScheme)
					} else {
						List {
							Section {
								VStack(alignment: .leading) {
									HStack {
										Text("Played")
											.font(.title3).bold()
											.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
										
										Spacer()
										
										AnimatedCountText(value: Double(self.filteredGameRecords.count))
											.font(.title3)
											.foregroundStyle(.secondary)
											.animation(reduceMotion ? nil : .easeInOut(duration: 1.0), value: self.filteredGameRecords.count)
									}
								}
								.wordlrListSectionRowBackground(.first)
								VStack(alignment: .leading) {
									HStack {
										Text("Win rate")
											.font(.title3).bold()
											.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
											.padding(.top, 3)
										
										Spacer()
										
										AnimatedCountText(value: self.winRate, isPercentage: true)
											.font(.title3)
											.foregroundStyle(.secondary)
											.animation(reduceMotion ? nil : .easeInOut(duration: 1.0), value: self.winRate)
									}
									
									Chart {
										BarMark(
											x: .value("Count", self.wonCount),
											y: .value("State", "won"),
											width: .fixed(20.0)
										)
										.foregroundStyle(Color.green)
										.annotation(position: self.wonCount < (self.lostCount / 6) ? .trailing : .overlay) {
											if self.wonCount > 0 {
												Text("\(self.wonCount)")
													.foregroundColor(self.wonCount < (self.lostCount / 6) ? .primary : .white)
													.font(.headline)
													.shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
													.opacity(self.showBarLabels ? 1 : 0)
													.animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: self.showBarLabels)
											}
										}

										BarMark(
											x: .value("Count", self.lostCount),
											y: .value("State", "lost"),
											width: .fixed(20.0)
										)
										.foregroundStyle(Color.red)
										.annotation(position: self.lostCount < (self.wonCount / 6) ? .trailing : .overlay) {
											if self.lostCount > 0 {
												Text("\(self.lostCount)")
													.foregroundColor(self.lostCount < (self.wonCount / 6) ? .primary : .white)
													.font(.headline)
													.shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
													.opacity(self.showBarLabels ? 1 : 0)
													.animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: self.showBarLabels)
											}
										}
									}
									.chartYAxis {
										AxisMarks(preset: .extended, position: .leading) { value in
											AxisValueLabel {
												if let label = value.as(String.self) {
													if label == "won" {
														Image(systemName: "checkmark.square.fill")
															.font(.title2)
															.symbolRenderingMode(.palette)
															.foregroundStyle(.white, Color.green)
															.shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
													} else {
														Image(systemName: "xmark.square.fill")
															.font(.title2)
															.symbolRenderingMode(.palette)
															.foregroundStyle(.white, .red)
															.shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
													}
												}
											}
										}
									}
									.chartXScale(domain: 0...max(Double(self.totalCount), 1))
									.animation(reduceMotion ? nil : .easeOut(duration: 1.0), value: self.filteredGameRecords.count)
									.accessibilityLabel("Win rate chart")
									.accessibilityValue(WordlrAccessibilityFormatter.winRateChartSummary(wins: self.wonCount, losses: self.lostCount, winRate: self.winRate))
								}
								.wordlrListSectionRowBackground(.last)
							} header: {
								Text("Played")
							}
							.wordlrListSectionBackground()
							
							Section {
								VStack(alignment: .leading) {
									Text("Number of guesses needed")
										.font(.title3).bold()
										.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
										.padding(.top, 3)
									
									Chart {
										ForEach(Array(self.counts.enumerated()), id: \.offset) { index, count in
											BarMark(
												x: .value("Count", count),
												y: .value("Number of guesses", " \(index+1) "),
												width: .fixed(20.0)
											)
											.foregroundStyle(Color.green)
											.annotation(position: count < (self.maxGuessesPerCount / 6) ? .trailing : .overlay) {
												if count > 0 {
													Text("\(count)")
														.foregroundColor(count < (self.maxGuessesPerCount / 6) ? .primary : .white)
														.font(.headline)
														.shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
														.opacity(self.showBarLabels ? 1 : 0)
														.animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: self.showBarLabels)
												}
											}
										}
									}
									.chartXScale(domain: 0...max(Double(self.maxGuessesPerCount), 1))
									.chartYAxis {
										AxisMarks(preset: .extended, position: .leading) { _ in
											AxisValueLabel(horizontalSpacing: 15)
												.font(.footnote)
										}
									}
									.animation(reduceMotion ? nil : .easeOut(duration: 1.0), value: self.filteredGameRecords.count)
									.accessibilityLabel("Guesses chart")
									.accessibilityValue(WordlrAccessibilityFormatter.guessesChartSummary(counts: self.counts))
									.frame(minHeight: 250)
								}
								.wordlrListSectionRowBackground(.single)
							} header: {
								Text("Guesses")
							}
							.wordlrListSectionBackground()
							if self.maxStreakLength > 0 || self.maxNormalStreakLength > 0 {
								Section {
									if self.maxStreakLength > 0 && (self.gameMode == .both || self.gameMode == .dailyWord) {
										StreakChartView(title: NSLocalizedString("Daily Wordlr streaks 🔥", comment: "Title for daily word streaks chart in stats view"), longestStreakPerLetters: self.$longestStreakPerLetters, maxStreakLength: self.$maxStreakLength)
											.wordlrListSectionRowBackground((self.maxNormalStreakLength > 0 && (self.gameMode == .both || self.gameMode == .normal)) ? .first : .single)
									}
									if self.maxNormalStreakLength > 0 && (self.gameMode == .both || self.gameMode == .normal) {
											StreakChartView(title: NSLocalizedString("Free play streaks 🔥", comment: "Title for free play streaks chart in stats view"), longestStreakPerLetters: self.$longestNormalStreakPerLetters, maxStreakLength: self.$maxNormalStreakLength)
											.wordlrListSectionRowBackground((self.maxStreakLength > 0 && (self.gameMode == .both || self.gameMode == .dailyWord)) ? .last : .single)
									}
								} header: {
									Text("Streaks")
								}
								.wordlrListSectionBackground()
							}
							
						}
						.scrollContentBackground(.hidden)
						.darkGradientBackground(colorScheme: colorScheme)
						.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
					}
				}
				.navigationTitle("Stats")
				.navigationBarTitleDisplayMode(.inline)
				.safeAreaInset(edge: .top) {
					if #available(iOS 26.0, *) {
						FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
					}
				}
				.onChange(of: self.numberOfLetters) {
					self.filterGameRecords()
				}
				.onChange(of: self.selectedLanguage) {
					self.filterGameRecords()
				}
				.onChange(of: self.gameMode) {
					self.filterGameRecords()
				}
				.onChange(of: self.showsWhenHintsUsed) {
					self.filterGameRecords()
				}
			}
			
		}
		.onAppear {
			if !self.hasFixedDefualtValues {
				self.setDefaultValues()
				self.hasFixedDefualtValues = true
			}

			Task {
				self.filterGameRecords()
			}
			AnalyticsManager.shared.logScreenViewed(screenName: "StatsView")
		}
	}
	
	@MainActor
	func filterGameRecords() {
		let numberOfLetters = self.numberOfLetters
		let selectedLanguage = self.selectedLanguage
		let gameMode = self.gameMode
		let showsWhenHintsUsed = self.showsWhenHintsUsed
		let allRecords = self.gameRecords

		let filteredRecords = allRecords.filter { entity in
			let game = entity.gameRecord
			if numberOfLetters != 9 && game.numberOfLetters != numberOfLetters { return false }
			if selectedLanguage != .all && game.language != selectedLanguage { return false }
			if gameMode != .both && game.mode != gameMode { return false }
			if showsWhenHintsUsed == .neverUsed && (game.hintsUsed ?? 0) != 0 { return false }
			if showsWhenHintsUsed == .onlyWhenUsed && (game.hintsUsed ?? 0) == 0 { return false }
			return true
		}

		let maxRows = max(rowCount(for: numberOfLetters == 9 ? 0 : numberOfLetters), filteredRecords.map { $0.gameRecord.effectiveMaxRows }.max() ?? 0)
		var wonCount = 0
		var lostCount = 0
		var guessCounts = Array(repeating: 0, count: maxRows)
		for entity in filteredRecords {
			let game = entity.gameRecord
			if game.state == .won {
				wonCount += 1
				let guessIndex = game.numberOfGuesses - 1
				if guessIndex >= 0 && guessIndex < maxRows {
					guessCounts[guessIndex] += 1
				}
			} else if game.state == .lost {
				lostCount += 1
			}
		}
		let totalCount = wonCount + lostCount
		let winRate = totalCount > 0 ? Double(wonCount) / Double(totalCount) : 0.0
		let maxGuessesPerCount = guessCounts.max() ?? 0

		let languages: [LanguageSelection] = [.english, .spanish, .norwegian]
		var dailyStreaks: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])] = []
		var normalStreaks: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])] = []
		var maxStreak: Double = 0
		var maxNormalStreak: Double = 0

		for language in languages {
			var dStreaks: [(index: Int, currentStreak: Int, longestStreak: Int)] = []
			var nStreaks: [(index: Int, currentStreak: Int, longestStreak: Int)] = []
			for index in 1...8 {
				if numberOfLetters != 9 && numberOfLetters != index { continue }
				if selectedLanguage != .all && selectedLanguage != language { continue }

				if gameMode == .both || gameMode == .dailyWord {
					let summary = GameRecordStreakCalculator.dailySummary(records: allRecords, language: language, numberOfLetters: index)
					if summary.longestStreak > 0 {
						dStreaks.append((index: index, currentStreak: summary.currentStreak, longestStreak: summary.longestStreak))
						maxStreak = max(maxStreak, Double(summary.longestStreak))
					}
				}
				if gameMode == .both || gameMode == .normal {
					let summary = GameRecordStreakCalculator.normalSummary(records: allRecords, language: language, numberOfLetters: index)
					if summary.longestStreak > 0 {
						nStreaks.append((index: index, currentStreak: summary.currentStreak, longestStreak: summary.longestStreak))
						maxNormalStreak = max(maxNormalStreak, Double(summary.longestStreak))
					}
				}
			}
			dailyStreaks.append((language: language, streaks: dStreaks))
			normalStreaks.append((language: language, streaks: nStreaks))
		}

		let isInitialLoad = !self.hasCompletedInitialLoad
		if isInitialLoad {
			self.showBarLabels = false
		}
		withAnimation(.easeOut(duration: 1.0)) {
			self.filteredGameRecords = filteredRecords
			self.maxNumberOfRows = maxRows
			self.wonCount = wonCount
			self.lostCount = lostCount
			self.totalCount = totalCount
			self.winRate = winRate
			self.counts = guessCounts
			self.maxGuessesPerCount = maxGuessesPerCount
			self.longestStreakPerLetters = dailyStreaks
			self.maxStreakLength = maxStreak
			self.longestNormalStreakPerLetters = normalStreaks
			self.maxNormalStreakLength = maxNormalStreak
			self.hasCompletedInitialLoad = true
		}
		if isInitialLoad {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
				withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
					self.showBarLabels = true
				}
			}
		}
	}
	
	func setDefaultValues() {
		self.selectedLanguage = self.defaultStatLanguage
		self.numberOfLetters = self.defaultStatNumberOfLetters
		self.gameMode = self.defaultStatGameMode
		self.showsWhenHintsUsed = self.defaultStatHintsUsed
		self.selectedStreakLanguage = self.defaultStatLanguage
	}
}

struct AnimatedCountText: View, Animatable {
	var value: Double
	var isPercentage: Bool = false

	var animatableData: Double {
		get { value }
		set { value = newValue }
	}

	var body: some View {
		if isPercentage {
			Text(String(format: "%.0f%%", value * 100))
		} else {
			Text("\(Int(value))")
		}
	}
}

#Preview {
	StatsView()
}
