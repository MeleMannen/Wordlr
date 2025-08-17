//
//  SearchView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appManager: AppManager
	@Environment(AdManager.self) private var adManager: AdManager
	@AppStorage("userWantsAds") var userWantsAds: Bool = true
    @Namespace private var namespace
    @State private var isShowingFilterOptions: Bool = false
    @State private var searchResults: [String] = []
    @State private var groupedWords: [String: [String]] = [:]
    @State private var sectionKeys: [String] = []
    
    var body: some View {
        VStack {
            if self.searchResults.isEmpty && !appManager.searchedWord.isEmpty {
                ContentUnavailableView.search(text: appManager.searchedWord)
            } else {
				HStack(spacing: 0) {
//					if #available(iOS 26, *) {
//						List {
//							ForEach(self.sectionKeys, id: \.self) { letter in
//								Section {
//									ForEach(Array((self.groupedWords[letter] ?? []).enumerated()), id: \.offset) { index, word in
//										LazyVStack(spacing: 0) {
//											NavigationLink(destination: {
//												WordDefinitionView(word: word, language: appManager.selectedLanguage)
//											}, label: {
//												HStack {
//													Text(word)
//														.font(.title3)
//														.foregroundStyle(.primary)
//													Spacer()
//												}
//											})
//										}
//									}
//								} header: {
//									SectionHeaderView(letter: letter)
//								}
//								.sectionIndexLabel(letter)
//								.listSectionSeparator(.hidden)
//								.id(letter)
//							}
//						}
//						.listSectionIndexVisibility(.visible)
//						.safeAreaPadding(.bottom, self.userWantsAds ? 54 : 0)
//					} else {
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
									}
								} header: {
									SectionHeaderView(letter: letter)
								}
								.listSectionSeparator(.hidden)
								.id(letter)
							}
						}
						.safeAreaPadding(.bottom, self.userWantsAds ? 54 : 0)
//					}
				}
            }
        }
        .searchable(text: $appManager.searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Phrase")
        .navigationTitle("Search")
        .onChange(of: appManager.searchedWord) {
            self.filterGameRecords()
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
        .overlay(alignment: .bottomTrailing) {
			if #available(iOS 18.0, *) {
				NavigationLink(destination: FilterOptionsView().environmentObject(appManager).navigationTransition(.zoom(sourceID: "filter", in: namespace)), label: {
					Image(systemName: "slider.horizontal.3")
						.font(.title)
						.foregroundColor(.white)
						.padding()
						.background(Color.green)
						.clipShape(Circle())
						.sensoryFeedback(.selection, trigger: self.isShowingFilterOptions)
						.matchedTransitionSource(id: "filter", in: namespace)
						.simultaneousGesture(
							LongPressGesture(minimumDuration: 1.2)
								.onEnded { _ in
									appManager.resetFilters()
									self.isShowingFilterOptions.toggle()
								}
						)
				})
				.padding(.trailing, 25)
				.padding(.bottom, self.userWantsAds ? 75 : 25)
				.transition(.scale)
				.simultaneousGesture(TapGesture().onEnded {
					self.isShowingFilterOptions.toggle()
				})
			} else {
				NavigationLink(destination: FilterOptionsView().environmentObject(appManager), label: {
					Image(systemName: "slider.horizontal.3")
						.font(.title)
						.foregroundColor(.white)
						.padding()
						.background(Color.green)
						.clipShape(Circle())
						.sensoryFeedback(.selection, trigger: self.isShowingFilterOptions)
						.simultaneousGesture(
							LongPressGesture(minimumDuration: 1.2)
								.onEnded { _ in
									appManager.resetFilters()
									self.isShowingFilterOptions.toggle()
								}
						)
				})
				.padding(.trailing, 25)
				.padding(.bottom, self.userWantsAds ? 75 : 25)
				.simultaneousGesture(TapGesture().onEnded {
					self.isShowingFilterOptions.toggle()
				})
			}
            
        }
        .onAppear {
            self.filterGameRecords()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = true
			}
        }
    }
    
    func filterGameRecords() {
        var filteredWords = appManager.words?.wordGroups["\(appManager.numberOfLetters)"] ?? []
//                let shuffledWords = filteredWords.shuffled()
//                for word in shuffledWords {
//                    if word == shuffledWords.last {
//                        print("\"\(word)\"")
//                        print("fini")
//                    } else {
//                        print("\"\(word)\",")
//                    }
//                }
        if appManager.isFilteringSearchWord && !appManager.searchedWord.isEmpty {
            filteredWords = filteredWords.filter { $0.contains(appManager.searchedWord.uppercased()) }
        }
        if appManager.isFilteringStartWith && !appManager.startsWithFilter.isEmpty {
            filteredWords = filteredWords.filter { $0.hasPrefix(appManager.startsWithFilter.uppercased()) }
        }
        if appManager.isFilteringEndsWith && !appManager.endsWithFilter.isEmpty {
            filteredWords = filteredWords.filter { $0.hasSuffix(appManager.endsWithFilter.uppercased()) }
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
        .environmentObject(AppManager())
}
