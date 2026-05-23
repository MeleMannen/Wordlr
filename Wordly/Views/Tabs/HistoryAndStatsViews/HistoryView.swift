//
//  HistoryView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 17/06/2025.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.colorScheme) private var colorScheme
	@Environment(AdManager.self) private var adManager
	@AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .all
	@AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
	@AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
	@AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@State private var hasFixedDefualtValues: Bool = false
	@State private var numberOfLetters: Int = 9
	@State private var selectedLanguage: LanguageSelection = .all
	@State private var gameMode: GameMode = .both
	@State private var showsWhenHintsUsed: ShowsWhenHintsUsed = .both
	@State private var searchedWord: String = ""
	@State private var searchResults: [GameRecordEntity] = []
	@State private var groupedWords: [String: [GameRecordEntity]] = [:]
	@State private var sectionKeys: [String] = []
	@State private var hasCompletedInitialLoad: Bool = false
	@Query private var gameRecords: [GameRecordEntity]
	
	let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
	let shadowGradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
	
	private let formatter1: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		return formatter
	}()
	
	var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				VStack {
					if #unavailable(iOS 26.0) {
						FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
					}
					if !self.hasCompletedInitialLoad {
						Color.clear
							.darkGradientBackground(colorScheme: colorScheme)
					} else if self.searchResults.isEmpty && !self.searchedWord.isEmpty {
						ContentUnavailableView.search(text: self.searchedWord)
							.darkGradientBackground(colorScheme: colorScheme)
					} else if self.searchResults.isEmpty {
						ContentUnavailableView.init("History is not available with this selection!", systemImage: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", description: Text("Try playing a game first."))
							.darkGradientBackground(colorScheme: colorScheme)
					} else {
						List {
							ForEach(sectionKeys, id: \.self) { date in
								Section {
									ForEach(groupedWords[date] ?? [], id: \.id) { gameRecordEntity in
										LazyVStack(spacing: 0) {
											NavigationLink(destination: {
												GameRecordView(gameRecord: gameRecordEntity.gameRecord)
												
											}, label: {
												HStack {
													if !self.userWantsNormalTheme && self.colorScheme == .dark && gameRecordEntity.gameRecord.mode == .dailyWord && gameRecordEntity.gameRecord.state == .won {
														Image(systemName: "checkmark")
															.foregroundStyle(.white)
															.conditionalShadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
															.padding(10)
															.background {
																Circle()
																	.foregroundStyle(LinearGradient(colors: [.orange, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing))
																//                                        .padding(5)
																	.gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
																	.conditionalShadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
															}
															.font(.title2).bold()
														
													} else {
														Image(systemName: gameRecordEntity.gameRecord.state == .won ? "checkmark" : "xmark")
															.foregroundStyle(.white)
															.conditionalShadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
															.padding(10)
															.background {
																Circle()
																	.foregroundColor(gameRecordEntity.gameRecord.state == .won ? .green : .red)
																	.conditionalShadow(color: .black.opacity(0.3), radius: 3, x: 4, y: 4)
															}
															.font(.title2).bold()
													}
													
													VStack(alignment: .leading) {
														Text(gameRecordEntity.gameRecord.word)
															.font(.title3).fontWeight(.medium)
															.foregroundStyle(.primary)
															.conditionalShadow(color: .black.opacity(0.3), radius: 1.5, x: 4, y: 4)
														
														if !self.userWantsNormalTheme && self.colorScheme == .dark && gameRecordEntity.gameRecord.mode == .dailyWord && gameRecordEntity.gameRecord.state == .won {
															Text(gameRecordEntity.gameRecord.mode.localizedName + " - " + String(format: NSLocalizedString("number_letters", comment: "Daily Word Mode with number of letters"), gameRecordEntity.gameRecord.numberOfLetters))
																.font(.caption)
																.foregroundStyle(self.gradient)
																.gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
																.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
															
														} else if gameRecordEntity.gameRecord.mode == .dailyWord {
															Text(gameRecordEntity.gameRecord.mode.localizedName + " - " + String(format: NSLocalizedString("number_letters", comment: "Daily Word Mode with number of letters"), gameRecordEntity.gameRecord.numberOfLetters))
																.font(.caption)
																.foregroundStyle(.secondary)
														}
													}
													Spacer()
												}
											})
										}
									}
								} header: {
									SectionHeaderView(letter: date)
								}
								.listSectionSeparator(.hidden)
							}
						}
						.scrollContentBackground(.hidden)
						.darkGradientBackground(colorScheme: colorScheme)
						.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
						.transition(.opacity)
					}
				}
				.searchable(text: self.$searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a word")
				.searchToolbarAvoidsHidingContentWhenAvailable()
				.navigationTitle("History")
				.navigationBarTitleDisplayMode(.inline)
				.safeAreaInset(edge: .top, spacing: 0) {
					if #available(iOS 26.0, *) {
						FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
					}
				}
				.onChange(of: self.searchedWord) {
					self.filterGameRecords()
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
				.task {
					self.filterGameRecords()
				}
				.onAppear {
					if !self.hasFixedDefualtValues {
						self.setDefaultValues()
						self.hasFixedDefualtValues = true
					}
					
					AnalyticsManager.shared.logScreenViewed(screenName: "HistoryView")
				}
			}
		}
	}
	
	func filterGameRecords() {
		Task {
			let searchedWord = self.searchedWord.uppercased()

			let filteredRecords = self.gameRecords.filter { entity in
				let game = entity.gameRecord
				if !searchedWord.isEmpty && !game.word.contains(searchedWord) { return false }
				if self.numberOfLetters != 9 && game.numberOfLetters != self.numberOfLetters { return false }
				if self.selectedLanguage != .all && game.language != self.selectedLanguage { return false }
				if self.gameMode != .both && game.mode != self.gameMode { return false }
				if self.showsWhenHintsUsed == .neverUsed && (game.hintsUsed ?? 0) != 0 { return false }
				if self.showsWhenHintsUsed == .onlyWhenUsed && (game.hintsUsed ?? 0) == 0 { return false }
				return true
			}

			let sorted = filteredRecords.sorted { $0.gameRecord.date > $1.gameRecord.date }
			let grouped = Dictionary(grouping: sorted, by: { formatter1.string(from: $0.gameRecord.date) })
			let keys = grouped.keys.sorted { date1, date2 in
				guard let d1 = formatter1.date(from: date1), let d2 = formatter1.date(from: date2) else {
					return false
				}
				return d1 > d2
			}
			self.searchResults = filteredRecords
			self.groupedWords = grouped
			self.sectionKeys = keys
			if !self.hasCompletedInitialLoad {
				withAnimation(.smooth(duration: 0.2)) {
					self.hasCompletedInitialLoad = true
				}
			}
		}
	}
	
	func setDefaultValues() {
		self.selectedLanguage = self.defaultStatLanguage
		self.numberOfLetters = self.defaultStatNumberOfLetters
		self.gameMode = self.defaultStatGameMode
		self.showsWhenHintsUsed = self.defaultStatHintsUsed
	}
}

extension View {
	@ViewBuilder
	func darkGradientBackground(colorScheme: ColorScheme) -> some View {
		self.background {
			if colorScheme == .dark {
				RadialGradient(
					colors: [.green.opacity(0.25), .clear],
					center: .topLeading,
					startRadius: 0,
					endRadius: 420
				)
				.ignoresSafeArea()
			}
		}
	}

	func gradientShadow(gradient: LinearGradient, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View {
		self.overlay(
			self.mask(gradient)
				.blur(radius: radius)
				.offset(x: x, y: y)
		)
	}
	
	@ViewBuilder
	func searchToolbarAvoidsHidingContentWhenAvailable() -> some View {
		if #available(iOS 17.1, *) {
			self.searchPresentationToolbarBehavior(.avoidHidingContent)
		} else {
			self
		}
	}
}

struct GradientShadowView: View {
	let text: String
	let gradient: LinearGradient
	let alignment: Alignment
	let blurRadius: CGFloat
	
	var body: some View {
		ZStack(alignment: alignment) {
			gradient
				.mask(alignment: alignment) {
					Text(text)
						.fixedSize()
				}
				.blur(radius: blurRadius)
			
				.overlay(alignment: alignment) {
					Text(text)
						.foregroundStyle(gradient)
						.blur(radius: 0.2)
				}
				.frame(maxWidth: .infinity, alignment: alignment)
		}
	}
}


#Preview {
	HistoryView()
}
