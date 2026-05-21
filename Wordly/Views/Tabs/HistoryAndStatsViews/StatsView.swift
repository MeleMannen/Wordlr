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
	@Environment(AdManager.self) private var adManager
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
	@State private var counts: [Int] = []
	@State private var maxGuessesPerCount: Int = 0
	@State private var selectedStreakLanguage: LanguageSelection = .norwegian
	@State private var longestStreakPerLetters: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])] = [(language: .english, streaks: []), (language: .spanish, streaks: []), (language: .norwegian, streaks: [])]
	@State private var longestNormalStreakPerLetters: [(language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)])] = [(language: .english, streaks: []), (language: .spanish, streaks: []), (language: .norwegian, streaks: [])]
	@State private var maxStreakLength: Double = 0.0
	@State private var maxNormalStreakLength: Double = 0.0
	
	@Query private var gameRecords: [GameRecordEntity]
	
	var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				VStack {
					if #unavailable(iOS 26.0) {
						FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
					}
					if self.filteredGameRecords.isEmpty {
						ContentUnavailableView.init("No stats available for this selection!", systemImage: "exclamationmark.triangle.fill", description: Text("Try playing a game first or changing the selection."))
							.padding(.bottom, 20)
					} else {
						List {
							Section {
								VStack(alignment: .leading) {
									HStack {
										Text("Played")
											.font(.title3).bold()
											.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
										
										Spacer()
										
										Text("\(self.filteredGameRecords.count)")
											.font(.title3)
											.foregroundStyle(.secondary)
									}
								}
								VStack(alignment: .leading) {
									HStack {
										Text("Win rate")
											.font(.title3).bold()
											.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
											.padding(.top, 3)
										
										Spacer()
										
										Text("\(String(format: "%.0f%%", self.winRate * 100))")
											.font(.title3)
											.foregroundStyle(.secondary)
									}
									
									Chart {
										BarMark(
											x: .value("Count", self.wonCount),
											y: .value("State", "✅"),
											width: .fixed(20.0)
										)
										.foregroundStyle(Color.green)
										.annotation(position: self.wonCount < (self.lostCount / 6) ? .trailing : .overlay) {
											if self.wonCount > 0 {
												Text("\(self.wonCount)")
													.foregroundColor(self.wonCount < (self.lostCount / 6) ? .primary : .white)
													.font(.headline)
											}
										}
										
										BarMark(
											x: .value("Count", self.lostCount),
											y: .value("State", "❌"),
											width: .fixed(20.0)
										)
										.foregroundStyle(Color.red)
										.annotation(position: self.lostCount < (self.wonCount / 6) ? .trailing : .overlay) {
											if self.lostCount > 0 {
												Text("\(self.lostCount)")
													.foregroundColor(self.lostCount < (self.wonCount / 6) ? .primary : .white)
													.font(.headline)
											}
										}
									}
									.chartXScale(domain: 0...Double(self.totalCount))
									.chartYAxis {
										AxisMarks(preset: .extended, position: .leading) { _ in
											AxisValueLabel(horizontalSpacing: 15)
												.font(.footnote)
										}
									}
									.animation(.easeInOut(duration: 0.5), value: self.filteredGameRecords.count)
								}
							} header: {
								Text("Played")
							}
							
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
												}
											}
										}
									}
									.chartXScale(domain: 0...Double(self.maxGuessesPerCount))
									.chartYAxis {
										AxisMarks(preset: .extended, position: .leading) { _ in
											AxisValueLabel(horizontalSpacing: 15)
												.font(.footnote)
										}
									}
									.animation(.easeInOut(duration: 0.5), value: self.filteredGameRecords.count)
									.frame(minHeight: 250)
								}
							} header: {
								Text("Guesses")
							}
							if self.maxStreakLength > 0 || self.maxNormalStreakLength > 0 {
								Section {
									if self.maxStreakLength > 0 && (self.gameMode == .both || self.gameMode == .dailyWord) {
										StreakChartView(title: NSLocalizedString("Daily Wordlr streaks 🔥", comment: "Title for daily word streaks chart in stats view"), longestStreakPerLetters: self.$longestStreakPerLetters, maxStreakLength: self.$maxStreakLength)
									}
									if self.maxNormalStreakLength > 0 && (self.gameMode == .both || self.gameMode == .normal) {
											StreakChartView(title: NSLocalizedString("Free play streaks 🔥", comment: "Title for free play streaks chart in stats view"), longestStreakPerLetters: self.$longestNormalStreakPerLetters, maxStreakLength: self.$maxNormalStreakLength)
									}
								} header: {
									Text("Streaks")
								}
							}
							
						}
						.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
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
			
			self.filterGameRecords()
			AnalyticsManager.shared.logScreenViewed(screenName: "StatsView")
		}
	}
	
	func filterGameRecords() {
		var filteredRecords = self.gameRecords
		
		if self.numberOfLetters != 9 {
			filteredRecords = filteredRecords.filter { $0.gameRecord.numberOfLetters == self.numberOfLetters }
		}
		
		if self.selectedLanguage != .all {
			filteredRecords = filteredRecords.filter { $0.gameRecord.language == self.selectedLanguage }
		}
		
		if self.gameMode != .both {
			filteredRecords = filteredRecords.filter { $0.gameRecord.mode == self.gameMode }
		}
		
		if self.showsWhenHintsUsed == .neverUsed {
			filteredRecords = filteredRecords.filter { $0.gameRecord.hintsUsed ?? 0 == 0 }
		} else if self.showsWhenHintsUsed == .onlyWhenUsed {
			filteredRecords = filteredRecords.filter { $0.gameRecord.hintsUsed ?? 0 > 0 }
		}
		self.filteredGameRecords = filteredRecords
		self.maxNumberOfRows = max(rowCount(for: self.numberOfLetters == 9 ? 0 : self.numberOfLetters), filteredRecords.map { $0.gameRecord.effectiveMaxRows }.max() ?? 0)
		print("Selected game records: \(self.filteredGameRecords.count)")
		self.wonCount = self.filteredGameRecords.filter { $0.gameRecord.state == .won }.count
		self.lostCount = self.filteredGameRecords.filter { $0.gameRecord.state == .lost }.count
		self.totalCount = self.wonCount + self.lostCount
		self.winRate = self.totalCount > 0 ? Double(self.wonCount) / Double(self.totalCount) : 0.0
		
		self.counts.removeAll()
		for i in 1...self.maxNumberOfRows {
			self.counts.append(self.filteredGameRecords.filter { $0.gameRecord.numberOfGuesses == i && $0.gameRecord.state == .won }.count)
		}
		self.maxGuessesPerCount = self.counts.max() ?? 0
		
		// Streaks
		self.maxStreakLength = 0
		var i = 0
		for longestStreak in self.longestStreakPerLetters {
			self.longestStreakPerLetters[i].streaks.removeAll()
			for index in 1...8 {
				if self.numberOfLetters != 9 && self.numberOfLetters != index {
					continue
				}
				
				if self.selectedLanguage != .all && self.selectedLanguage != longestStreak.language {
					continue
				}
				
				let summary = GameRecordStreakCalculator.dailySummary(
					records: self.gameRecords,
					language: longestStreak.language,
					numberOfLetters: index
				)
				
				guard summary.longestStreak > 0 else {
					continue
				}
				
				self.longestStreakPerLetters[i].streaks.append((index: index, currentStreak: summary.currentStreak, longestStreak: summary.longestStreak))
				let longestDouble = Double(summary.longestStreak)
				if longestDouble > self.maxStreakLength {
					self.maxStreakLength = longestDouble
				}
			}
			i += 1
		}
		
		i = 0
		self.maxNormalStreakLength = 0
		for longestStreak in self.longestNormalStreakPerLetters {
			self.longestNormalStreakPerLetters[i].streaks.removeAll()
			for index in 1...8 {
				if self.numberOfLetters != 9 && self.numberOfLetters != index {
					continue
				}
				
				if self.selectedLanguage != .all && self.selectedLanguage != longestStreak.language {
					continue
				}
				
				let summary = GameRecordStreakCalculator.normalSummary(
					records: self.gameRecords,
					language: longestStreak.language,
					numberOfLetters: index
				)
				
				guard summary.longestStreak > 0 else {
					continue
				}
				
				self.longestNormalStreakPerLetters[i].streaks.append((index: index, currentStreak: summary.currentStreak, longestStreak: summary.longestStreak))
				let longestDouble = Double(summary.longestStreak)
				if longestDouble > self.maxNormalStreakLength {
					self.maxNormalStreakLength = longestDouble
				}
			}
			i += 1
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

#Preview {
	StatsView()
}
