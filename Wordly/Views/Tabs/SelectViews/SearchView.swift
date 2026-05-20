//
//  SearchView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct SearchView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.scenePhase) private var scenePhase
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
	
	private let filterTip = FilterTip()
	
	var body: some View {
		@Bindable var appManager = appManager
		
		if #available(iOS 17.1, *) {
			VStack {
				if self.searchResults.isEmpty && !appManager.searchedWord.isEmpty {
					ContentUnavailableView.search(text: appManager.searchedWord)
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
													Label("Use the Word", systemImage: "checkmark.circle")
												}
											}
										}
									} header: {
										SectionHeaderView(letter: letter)
									}
									.sectionIndexLabel(letter)
									.listSectionSeparator(.hidden)
									.id(letter)
								}
							}
							.listSectionIndexVisibility(.visible)
							.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
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
													Label("Use the Word", systemImage: "checkmark.circle")
												}
											}
										}
									} header: {
										SectionHeaderView(letter: letter)
									}
									.listSectionSeparator(.hidden)
									.id(letter)
								}
							}
							.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
						}
					}
				}
			}
			.searchable(text: $appManager.searchedWord, isPresented: $appManager.isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Word")
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
				//						.sensoryFeedback(.selection, trigger: self.isShowingFilterOptions)
				//						.id(filterButtonID)
				//					}
				//				}
				if #available(iOS 26.0, *) {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: {
							self.isShowingFilterOptions = true
							self.didTap.toggle()
							Task {
								await FilterTip.filterEvent.donate()
							}
							AnalyticsManager.shared.logDidUseSearchFiltersEvent(word: appManager.word, language: appManager.selectedLanguage, numberOfLetters: appManager.numberOfLetters, gameMode: appManager.gameMode)
						}) {
							Label("Filter Options", systemImage: "slider.horizontal.3")
						}
						.sensoryFeedback(.selection, trigger: self.didTap)
						.popoverTip(self.filterTip, arrowEdge: .top)
					}
					.matchedTransitionSource(id: "filter", in: self.namespace)
					
					
				} else {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: {
							self.isShowingFilterOptions = true
							self.didTap.toggle()
							Task {
								await FilterTip.filterEvent.donate()
							}
							AnalyticsManager.shared.logDidUseSearchFiltersEvent(word: appManager.word, language: appManager.selectedLanguage, numberOfLetters: appManager.numberOfLetters, gameMode: appManager.gameMode)
						}) {
							Label("Filter Options", systemImage: "slider.horizontal.3")
						}
						.sensoryFeedback(.selection, trigger: self.didTap)
						.popoverTip(self.filterTip, arrowEdge: .top)
					}
				}
			}
			.sheet(isPresented: $isShowingFilterOptions) {
				
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
			//			.overlay(alignment: .bottomTrailing) {
			//				if #available(iOS 26.0, *) {
			//					NavigationLink(destination: FilterOptionsView().environmentObject(appManager).navigationTransition(.zoom(sourceID: "filter", in: namespace)), label: {
			//						Image(systemName: "slider.horizontal.3")
			//							.font(.title)
			//							.foregroundColor(.white)
			//							.padding()
			//							.matchedTransitionSource(id: "filter", in: namespace)
			//							.background {
			//								if self.scenePhase == .background {
			//									Circle()
			//										.foregroundStyle(Color(uiColor: .systemGreen))
			//									
			//								}
			//							}
			//					})
			//					.glassEffect(.regular.tint(.green).interactive(), in: .circle)
			//					.padding(.trailing, 25)
			//					.padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : (adManager.shouldShowAds ? 75 : 25))
			//					.transition(.scale)
			//					.simultaneousGesture(
			//						LongPressGesture(minimumDuration: 1.2)
			//							.onEnded { _ in
			//								appManager.resetFilters()
			//								self.isShowingFilterOptions.toggle()
			//							}
			//					)
			//					.simultaneousGesture(TapGesture().onEnded {
			//						self.isShowingFilterOptions.toggle()
			//						Task {
			//							await FilterTip.filterEvent.donate()
			//						}
			//					})
			//					.popoverTip(self.filterTip, arrowEdge: .top)
			//					.sensoryFeedback(.selection, trigger: self.isShowingFilterOptions)
			//					.id(filterButtonID)
			//					
			//				} else if #available(iOS 18.0, *) {
			//					NavigationLink(destination: FilterOptionsView().environmentObject(appManager).navigationTransition(.zoom(sourceID: "filter", in: namespace)), label: {
			//						Image(systemName: "slider.horizontal.3")
			//							.font(.title)
			//							.foregroundColor(.white)
			//							.padding()
			//							.background(Color.green)
			//							.clipShape(Circle())
			//							.sensoryFeedback(.selection, trigger: self.isShowingFilterOptions)
			//							.matchedTransitionSource(id: "filter", in: namespace)
			//							.simultaneousGesture(
			//								LongPressGesture(minimumDuration: 1.2)
			//									.onEnded { _ in
			//										appManager.resetFilters()
			//										self.isShowingFilterOptions.toggle()
			//									}
			//							)
			//					})
			//					.padding(.trailing, 25)
			//					.padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : (adManager.shouldShowAds ? 75 : 25))
			//					.transition(.scale)
			//					.simultaneousGesture(TapGesture().onEnded {
			//						self.isShowingFilterOptions.toggle()
			//						Task {
			//							await FilterTip.filterEvent.donate()
			//						}
			//					})
			//					.popoverTip(self.filterTip, arrowEdge: .top)
			//					.id(filterButtonID)
			//				} else {
			//					NavigationLink(destination: FilterOptionsView().environmentObject(appManager), label: {
			//						Image(systemName: "slider.horizontal.3")
			//							.font(.title)
			//							.foregroundColor(.white)
			//							.padding()
			//							.background(Color.green)
			//							.clipShape(Circle())
			//							.sensoryFeedback(.selection, trigger: self.isShowingFilterOptions)
			//							.simultaneousGesture(
			//								LongPressGesture(minimumDuration: 1.2)
			//									.onEnded { _ in
			//										appManager.resetFilters()
			//										self.isShowingFilterOptions.toggle()
			//									}
			//							)
			//					})
			//					.padding(.trailing, 25)
			//					.padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : (adManager.shouldShowAds ? 75 : 25))
			//					.simultaneousGesture(TapGesture().onEnded {
			//						self.isShowingFilterOptions.toggle()
			//						Task {
			//							await FilterTip.filterEvent.donate()
			//						}
			//					})
			//					.popoverTip(self.filterTip, arrowEdge: .top)
			//					
			//					
			//				}
			//				
			//			}
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
