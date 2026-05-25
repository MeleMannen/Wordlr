//
//  SearchView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct SearchView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) private var colorScheme
	@Environment(AppManager.self) private var appManager
	@Environment(AdManager.self) private var adManager
	@Namespace private var namespace
	@State private var isShowingFilterOptions: Bool = false
	@State private var didTap: Bool = false
	@State private var searchResults: [String] = []
	@State private var groupedWords: [String: [String]] = [:]
	@State private var sectionKeys: [String] = []
	@State private var filterButtonID = UUID()
	@State private var selectedDetent: PresentationDetent = .large
	@State private var didResetFiltersWithLongPress = false
	
	private let filterTip = FilterTip()
	
	var body: some View {
		@Bindable var appManager = appManager
		
		if #available(iOS 17.1, *) {
			VStack {
				if self.searchResults.isEmpty && !appManager.searchedWord.isEmpty {
					ContentUnavailableView {
						Label("No results for \(appManager.searchedWord)", systemImage: "magnifyingglass")
							.font(.title2)
							.foregroundStyle(.primary)
					} description: {
						Text("Try changing the search text or removing filters.")
					} actions: {
						HStack {
							Button("Clear search") {
								clearSearch()
							}
							.foregroundStyle(.green)
						}
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.darkGradientBackground(colorScheme: colorScheme)
				} else if self.searchResults.isEmpty {
					ContentUnavailableView {
						Label("No words matching current filters", systemImage: "magnifyingglass")
							.font(.title2)
							.foregroundStyle(.primary)
							
					} description: {
						Text("There are no words matching the current filters. Try adjusting or removing some filters to see more words.")
							
					} actions: {
						HStack {
							Button("Reset filters") {
								resetFiltersFromToolbar()
							}
							.foregroundStyle(.green)
						}
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.darkGradientBackground(colorScheme: colorScheme)

				} else {
					HStack(spacing: 0) {
						if #available(iOS 26, *) {
							List {
								ForEach(self.sectionKeys, id: \.self) { letter in
									Section {
										ForEach(Array((self.groupedWords[letter] ?? []).enumerated()), id: \.offset) { index, word in
											LazyVStack(spacing: 0) {
												NavigationLink(destination: {
													WordDefinitionView(word: word, language: appManager.selectedLanguage)
												}, label: {
													HStack {
														Text(word)
															.font(.title3)
															.foregroundStyle(.primary)
														Spacer()
													}
												})
											}
											.contextMenu {
												Button {
													appManager.useWord(word: word)
													dismiss()
												} label: {
													Label("Use the word", systemImage: "checkmark.circle")
												}
											}
											.wordlrListSectionRowBackground(index: index, count: self.groupedWords[letter]?.count ?? 0)
										}
									} header: {
										SectionHeaderView(letter: letter)
									}
									.sectionIndexLabel(letter)
									.listSectionSeparator(.hidden)
									.wordlrListSectionBackground()
									.id(letter)
								}
							}
							.listSectionIndexVisibility(.visible)
							.scrollContentBackground(.hidden)
							.darkGradientBackground(colorScheme: colorScheme)
							.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
						} else {
							List {
								ForEach(self.sectionKeys, id: \.self) { letter in
									Section {
										ForEach(Array((self.groupedWords[letter] ?? []).enumerated()), id: \.offset) { index, word in
											LazyVStack(spacing: 0) {
												NavigationLink(destination: {
													WordDefinitionView(word: word, language: appManager.selectedLanguage)
												}, label: {
													HStack {
														Text(word)
															.font(.title3)
															.foregroundStyle(.primary)
														Spacer()
													}
												})
											}
											.contextMenu {
												Button {
													appManager.useWord(word: word)
													dismiss()
												} label: {
													Label("Use the word", systemImage: "checkmark.circle")
												}
											}
											.wordlrListSectionRowBackground(index: index, count: self.groupedWords[letter]?.count ?? 0)
										}
									} header: {
										SectionHeaderView(letter: letter)
									}
									.listSectionSeparator(.hidden)
									.wordlrListSectionBackground()
									.id(letter)
								}
							}
							.scrollContentBackground(.hidden)
							.darkGradientBackground(colorScheme: colorScheme)
							.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
						}
					}
				}
			}
			.searchable(text: $appManager.searchedWord, isPresented: $appManager.isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a word")
			.searchPresentationToolbarBehavior(.avoidHidingContent)
			.navigationTitle("Search")
			.toolbar {
				//				ToolbarItem(placement: .topBarTrailing) {
				//					if #available(iOS 26.0, *) {
				//						NavigationLink(destination: FilterOptionsView().environmentObject(appManager).navigationTransition(.zoom(sourceID: "filter", in: namespace)), label: {
				//							Image(systemName: "slider.horizontal.3")
				//								.foregroundColor(.white)
				//								.matchedTransitionSource(id: "filter", in: namespace)
				//						})
				////						.transition(.scale)
				//						.simultaneousGesture(
				//							LongPressGesture(minimumDuration: 1.2)
				//								.onEnded { _ in
				//									appManager.resetFilters()
				//									self.isShowingFilterOptions.toggle()
				//								}
				//						)
				//						.simultaneousGesture(TapGesture().onEnded {
				//							self.isShowingFilterOptions.toggle()
				//							Task {
				//								await FilterTip.filterEvent.donate()
				//							}
				//						})
				//						.popoverTip(self.filterTip, arrowEdge: .top)
				//						.conditionalHaptic(.selection, trigger: self.isShowingFilterOptions)
				//						.id(filterButtonID)
				//					}
				//				}
				if #available(iOS 26.0, *) {
					ToolbarItem(placement: .navigationBarTrailing) {
						Menu {
							Button(role: .destructive) {
								resetFiltersFromToolbar()
							} label: {
								Label("Reset filters", systemImage: "arrow.counterclockwise")
							}
						} label: {
							Label("Filter options", systemImage: "slider.horizontal.3")
						} primaryAction: {
							openFilterOptions()
						}
						.accessibilityHint("Opens filters for word search.")
						.accessibilityInputLabels(["Filter options", "Filters", "Reset filters"])
						.conditionalHaptic(.selection, trigger: self.didTap)
						.popoverTip(self.filterTip, arrowEdge: .top)
					}
					.matchedTransitionSource(id: "filter", in: self.namespace)
					
					
				} else {
					ToolbarItem(placement: .navigationBarTrailing) {
						Menu {
							Button(role: .destructive) {
								resetFiltersFromToolbar()
							} label: {
								Label("Reset filters", systemImage: "arrow.counterclockwise")
							}
						} label: {
							Label("Filter options", systemImage: "slider.horizontal.3")
						} primaryAction: {
							openFilterOptions()
						}
						.accessibilityHint("Opens filters for word search.")
						.accessibilityInputLabels(["Filter options", "Filters", "Reset filters"])
						.conditionalHaptic(.selection, trigger: self.didTap)
						.popoverTip(self.filterTip, arrowEdge: .top)
					}
				}
			}
			.sheet(isPresented: $isShowingFilterOptions) {
				filterGameRecords()
			} content: {
				if #available(iOS 26.0, *) {
					FilterOptionsView(isShowingFilterOptions: self.$isShowingFilterOptions)
						.environment(appManager)
						.presentationDetents([.large, .fraction(0.8)], selection: $selectedDetent)
						.navigationTransition(.zoom(sourceID: "filter", in: self.namespace))
				} else {
					FilterOptionsView(isShowingFilterOptions: self.$isShowingFilterOptions)
						.environment(appManager)
				}
			}
			.onChange(of: appManager.isSearching) {
				if appManager.isSearching {
					adManager.shouldShowAds = false
				} else {
					adManager.shouldShowAds = true
				}
			}
			.onChange(of: appManager.searchedWord) {
				self.filterGameRecords()
				AnalyticsManager.shared.logDidUseSearchEvent(word: appManager.word, language: appManager.selectedLanguage, numberOfLetters: appManager.numberOfLetters, gameMode: appManager.gameMode)
			}
			.onChange(of: appManager.isFilteringSearchWord) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.startsWithFilter) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.isFilteringStartWith) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.endsWithFilter) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.isFilteringEndsWith) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.selectedIncludedLetters) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.isFilteringIncludedLetters) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.selectedExcludedLetters) {
				self.filterGameRecords()
			}
			.onChange(of: appManager.isFilteringExcludeLetters) {
				self.filterGameRecords()
			}
			.onAppear {
				AnalyticsManager.shared.logScreenViewed(screenName: "SearchView")
				self.filterGameRecords()
				adManager.currentSelectView = .searchView
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
					adManager.shouldShowAds = true
				}
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.filterButtonID = UUID()
				}
			}
		}
	}
	
	func filterGameRecords() {
		var filteredWords = appManager.searchableWords()
		//		let shuffledWords = filteredWords.shuffled()
		//		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
		//			print("[")
		//			for word in shuffledWords {
		//				if word == shuffledWords.last {
		//					print("\"\(word)\"")
		//					print("]")
		//				} else {
		//					print("\"\(word)\",")
		//				}
		//			}
		//		}
		
		if appManager.isFilteringSearchWord && !appManager.searchedWord.isEmpty {
			filteredWords = filteredWords.filter { $0.contains(appManager.searchedWord.replacingOccurrences(of: " ", with: "").uppercased()) }
		}
		if appManager.isFilteringStartWith && !appManager.startsWithFilter.isEmpty {
			filteredWords = filteredWords.filter { $0.hasPrefix(appManager.startsWithFilter.replacingOccurrences(of: " ", with: "").uppercased()) }
		}
		if appManager.isFilteringEndsWith && !appManager.endsWithFilter.isEmpty {
			filteredWords = filteredWords.filter { $0.hasSuffix(appManager.endsWithFilter.replacingOccurrences(of: " ", with: "").uppercased()) }
		}
		
		if appManager.isFilteringIncludedLetters && !appManager.selectedIncludedLetters.isEmpty {
			let includedCharacters = Set(appManager.selectedIncludedLetters.joined())
			filteredWords = filteredWords.filter { word in
				includedCharacters.isSubset(of: Set(word.uppercased()))
			}
		}
		
		if appManager.isFilteringExcludeLetters && !appManager.selectedExcludedLetters.isEmpty {
			let excludedCharacters = Set(appManager.selectedExcludedLetters.joined())
			filteredWords = filteredWords.filter { word in
				excludedCharacters.isDisjoint(with: word.uppercased())
			}
		}
		self.searchResults = filteredWords
		self.groupedWords = Dictionary(grouping: self.searchResults.sorted(), by: { String($0.prefix(1)).uppercased() })
		self.sectionKeys = self.groupedWords.keys.sorted(using: String.Comparator(options: .caseInsensitive, locale: Locale(identifier: "nb"), order: .forward))
	}

	private func openFilterOptions() {
		if didResetFiltersWithLongPress {
			didResetFiltersWithLongPress = false
			return
		}

		DispatchQueue.main.async {
			self.isShowingFilterOptions = true
		}
		self.didTap.toggle()
		Task {
			await FilterTip.filterEvent.donate()
		}
		AnalyticsManager.shared.logDidUseSearchFiltersEvent(word: appManager.word, language: appManager.selectedLanguage, numberOfLetters: appManager.numberOfLetters, gameMode: appManager.gameMode)
	}

	private func resetFiltersFromToolbar() {
		didResetFiltersWithLongPress = true
		appManager.resetFilters()
		filterGameRecords()
		isShowingFilterOptions = false
		didTap.toggle()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			self.didResetFiltersWithLongPress = false
		}
	}

	private func clearSearch() {
		appManager.searchedWord = ""
		filterGameRecords()
		didTap.toggle()
	}

	private var hasActiveFilters: Bool {
		appManager.isFilteringStartWith ||
		appManager.isFilteringEndsWith ||
		appManager.isFilteringIncludedLetters ||
		appManager.isFilteringExcludeLetters ||
		!appManager.startsWithFilter.isEmpty ||
		!appManager.endsWithFilter.isEmpty ||
		!appManager.selectedIncludedLetters.isEmpty ||
		!appManager.selectedExcludedLetters.isEmpty
	}
}


struct SectionHeaderView: View {
	let letter: String
	
	var body: some View {
		VStack {
			HStack {
				Text(letter)
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundColor(.gray)
					.padding(.leading, 16)
				Spacer()
			}
		}
		.padding(.vertical, 8)
		.frame(height: 35)
		.listRowInsets(EdgeInsets())
	}
}

#Preview {
	SearchView()
		.environment(AppManager())
}
