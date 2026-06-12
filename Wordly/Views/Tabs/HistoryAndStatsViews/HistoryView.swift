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
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@State private var numberOfLetters: Int = 9
	@State private var selectedLanguage: LanguageSelection = .all
	@State private var gameMode: GameMode = .both
	@State private var showsWhenHintsUsed: ShowsWhenHintsUsed = .both
	@State private var searchedWord: String = ""
	@State private var historyResult: HistorySearchResult?
	@State private var didTap: Bool = false
	@Query private var gameRecords: [GameRecordEntity]
	
	let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
	let shadowGradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
	
	private let formatter1: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		return formatter
	}()

	private var historyFilter: HistoryFilter {
		HistoryFilter(
			searchedWord: self.searchedWord.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
			numberOfLetters: self.numberOfLetters,
			selectedLanguage: self.selectedLanguage,
			gameMode: self.gameMode,
			showsWhenHintsUsed: self.showsWhenHintsUsed,
			recordCount: self.gameRecords.count
		)
	}

	private var displayedHistoryResult: HistorySearchResult {
		self.historyResult ?? self.makeHistoryResult(using: self.historyFilter)
	}

	init() {
		let defaults = UserDefaults.standard
		self._numberOfLetters = State(initialValue: defaults.object(forKey: "defaultStatNumberOfLetters") as? Int ?? 9)
		self._selectedLanguage = State(initialValue: LanguageSelection(rawValue: defaults.string(forKey: "defaultStatLanguage") ?? "") ?? .all)
		self._gameMode = State(initialValue: GameMode(rawValue: defaults.string(forKey: "defaultStatGameMode") ?? "") ?? .both)
		self._showsWhenHintsUsed = State(initialValue: ShowsWhenHintsUsed(rawValue: defaults.string(forKey: "defaultStatHintsUsed") ?? "") ?? .both)
	}
	
	var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				VStack {
					if #unavailable(iOS 26.0) {
						FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
                            .darkGradientBackground(colorScheme: colorScheme)
					}

					self.historyContent(historyResult: self.displayedHistoryResult)
						.scrollContentBackground(.hidden)
						.darkGradientBackground(colorScheme: colorScheme)
						.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
						.transition(.opacity)
				}
			}
			.searchable(text: self.$searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a word")
			.searchToolbarAvoidsHidingContentWhenAvailable()
            .darkGradientBackground(colorScheme: colorScheme)
			.navigationTitle("History")
			.navigationBarTitleDisplayMode(.inline)
			.sensoryFeedback(.selection, trigger: self.didTap)
			.safeAreaInset(edge: .top, spacing: 0) {
				if #available(iOS 26.0, *) {
					FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
				}
			}
			.task(id: self.historyFilter) {
				await self.filterGameRecords(using: self.historyFilter)
			}
			.onAppear {
				AnalyticsManager.shared.logScreenViewed(screenName: "HistoryView")
			}
		}
	}

	@ViewBuilder
	private func historyContent(historyResult: HistorySearchResult) -> some View {
		if historyResult.isEmpty && !self.searchedWord.isEmpty {
			ContentUnavailableView.search(text: self.searchedWord)
				.transition(.opacity)
		} else if historyResult.isEmpty {
			ContentUnavailableView {
				Label("History is not available with this selection", systemImage: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90")
					.font(.title2)
					.foregroundStyle(.primary)
				
			} description: {
				Text("Try playing a game first.")
				
			} actions: {
				Button("Reset filters") {
					resetFilters()
				}
				.foregroundStyle(.red)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.transition(.opacity)
				
		} else {
			List {
				ForEach(historyResult.sections) { section in
					Section {
						ForEach(Array(section.records.enumerated()), id: \.element.id) { index, gameRecordEntity in
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
							.accessibilityElement(children: .ignore)
							.accessibilityLabel(WordlrAccessibilityFormatter.gameRecordSummary(gameRecordEntity.gameRecord, timeUsed: nil))
							.contextMenu {
								if gameRecordEntity.gameRecord.mode == .dailyWord,
								   GameResultShareFormatter.shareText(for: gameRecordEntity.gameRecord) != nil {
									Button {
										copyResult(for: gameRecordEntity.gameRecord)
									} label: {
										Label("Copy result", systemImage: "doc.on.doc")
									}
								}
							}
							.wordlrListSectionRowBackground(index: index, count: section.records.count)
						}
					} header: {
						SectionHeaderView(letter: section.title)
					}
					.listSectionSeparator(.hidden)
					.wordlrListSectionBackground()
				}
			}
		}
	}
		
	@MainActor
	private func filterGameRecords(using filter: HistoryFilter) async {
		guard !Task.isCancelled else { return }
		withAnimation(.smooth(duration: 0.12)) {
			self.historyResult = self.makeHistoryResult(using: filter)
		}
	}

	private func makeHistoryResult(using filter: HistoryFilter) -> HistorySearchResult {
		let sections = HistorySectionBuilder.sections(
			for: self.gameRecords,
			matching: filter,
			formatter: self.formatter1
		)
		return HistorySearchResult(sections: sections)
	}
	
	private func resetFilters() {
		self.selectedLanguage = .all
		self.gameMode = .both
		self.searchedWord = ""
		self.numberOfLetters = 9
		self.showsWhenHintsUsed = .both
		self.didTap.toggle()
		
	}

	private func copyResult(for gameRecord: GameRecord) {
		UIPasteboard.general.string = GameResultShareFormatter.shareText(for: gameRecord)
		AnalyticsManager.shared.logDidCopyResultEvent(copySource: "history_context_menu")
	}
}

private struct HistorySearchResult {
	var sections: [HistorySection] = []

	var isEmpty: Bool {
		self.sections.allSatisfy(\.records.isEmpty)
	}
}

private struct HistorySection: Identifiable {
	var id: Date { self.date }
	let date: Date
	let title: String
	let records: [GameRecordEntity]
}

private struct HistoryFilter: Equatable, Sendable {
	let searchedWord: String
	let numberOfLetters: Int
	let selectedLanguage: LanguageSelection
	let gameMode: GameMode
	let showsWhenHintsUsed: ShowsWhenHintsUsed
	let recordCount: Int
}

private enum HistorySectionBuilder {
	static func sections(for records: [GameRecordEntity], matching filter: HistoryFilter, formatter: DateFormatter) -> [HistorySection] {
		let calendar = Calendar.current
		let filtered = records
			.filter { entity in
				let game = entity.gameRecord
				if !filter.searchedWord.isEmpty && !game.word.contains(filter.searchedWord) { return false }
				if filter.numberOfLetters != 9 && game.numberOfLetters != filter.numberOfLetters { return false }
				if filter.selectedLanguage != .all && game.language != filter.selectedLanguage { return false }
				if filter.gameMode != .both && game.mode != filter.gameMode { return false }
				if filter.showsWhenHintsUsed == .neverUsed && (game.hintsUsed ?? 0) != 0 { return false }
				if filter.showsWhenHintsUsed == .onlyWhenUsed && (game.hintsUsed ?? 0) == 0 { return false }
				return true
			}
			.sorted { $0.gameRecord.date > $1.gameRecord.date }

		var sectionDates: [Date] = []
		var recordsByDate: [Date: [GameRecordEntity]] = [:]
		for record in filtered {
			let sectionDate = calendar.startOfDay(for: record.gameRecord.date)
			if recordsByDate[sectionDate] == nil {
				sectionDates.append(sectionDate)
			}
			recordsByDate[sectionDate, default: []].append(record)
		}

		return sectionDates.map { date in
			HistorySection(
				date: date,
				title: formatter.string(from: date),
				records: recordsByDate[date] ?? []
			)
		}
	}
}

extension View {
	@ViewBuilder
	func darkGradientBackground(colorScheme: ColorScheme, opacity: Double = 1.0) -> some View {
		if colorScheme == .light {
			self.background {
				Color(uiColor: .secondarySystemBackground)
					.ignoresSafeArea()
			}
		} else if #available(iOS 26.0, *) {
			self.background {
				if UIDevice.current.userInterfaceIdiom == .phone {
					RadialGradient(
						colors: [
							.green.opacity(0.42 * opacity),
							.green.opacity(0.18 * opacity),
							.clear
						],
						center: .top,
						startRadius: 0,
						endRadius: 420
					)
					.ignoresSafeArea()
				}
			}
		} else {
			self
		}
	}

	func conditionalHaptic<V: Equatable>(_ feedback: SensoryFeedback, trigger: V) -> some View {
		modifier(ConditionalHapticModifier(feedback: feedback, trigger: trigger))
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

struct ConditionalHapticModifier<V: Equatable>: ViewModifier {
	@AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
	let feedback: SensoryFeedback
	let trigger: V

	@ViewBuilder
	func body(content: Content) -> some View {
		if hapticsEnabled {
			content.sensoryFeedback(feedback, trigger: trigger)
		} else {
			content
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
