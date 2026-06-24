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
    @State private var searchResults: [String] = []
    @State private var groupedWords: [String: [String]] = [:]
    @State private var sectionKeys: [String] = []
    @State private var selectedDetent: PresentationDetent = .large
    @State private var didResetFiltersWithLongPress = false
    private let filterTip = FilterTip()
    
    private struct FilterState: Equatable {
        let isFilteringSearchWord: Bool
        let isFilteringStartWith: Bool
        let startsWithFilter: String
        let isFilteringEndsWith: Bool
        let endsWithFilter: String
        let isFilteringIncludedLetters: Bool
        let selectedIncludedLetters: [String]
        let isFilteringExcludeLetters: Bool
        let selectedExcludedLetters: [String]
        let numberOfLetters: Int
        let selectedGameMode: GameMode
        let isExpertModeEnabled: Bool
    }
    
    var body: some View {
        @Bindable var appManager = appManager
        
        if #available(iOS 17.1, *) {
            VStack {
                if searchResults.isEmpty && !appManager.searchedWord.isEmpty {
                    emptySearchState(
                        title: "No results for \(appManager.searchedWord)",
                        description: "Try changing the search text or removing filters.",
                        buttonTitle: "Clear search",
                        action: clearSearch
                    )
                } else if searchResults.isEmpty {
                    emptySearchState(
                        title: "No words matching current filters",
                        description: "There are no words matching the current filters. Try adjusting or removing some filters to see more words.",
                        buttonTitle: "Reset filters",
                        action: resetFiltersFromToolbar
                    )
                } else {
                    HStack(spacing: 0) {
                        if #available(iOS 26.0, *) {
                            List {
                                ForEach(sectionKeys, id: \.self) { letter in
                                    wordSection(for: letter)
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .darkGradientBackground(colorScheme: colorScheme)
                            .safeAreaPadding(.bottom, listBottomPadding)
                            .listSectionIndexVisibility(.visible)
                        } else {
                            List {
                                ForEach(sectionKeys, id: \.self) { letter in
                                    wordSection(for: letter)
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .darkGradientBackground(colorScheme: colorScheme)
                            .safeAreaPadding(.bottom, listBottomPadding)
                        }
                    }
                }
            }
            .searchable(text: $appManager.searchedWord, isPresented: $appManager.isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a word")
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(action: openFilterOptions) {
                            Label("Filter options", systemImage: "slider.horizontal.3")
                        }
                        .popoverTip(filterTip, arrowEdge: .top)
                        .matchedTransitionSource(id: "filter", in: namespace)
                    } else {
                        Button(action: openFilterOptions) {
                            Label("Filter options", systemImage: "slider.horizontal.3")
                        }
                        .popoverTip(filterTip, arrowEdge: .top)
                    }
                }
            }
            .sheet(isPresented: $isShowingFilterOptions) {
                filterGameRecords()
            } content: {
                filterOptionsSheet
            }
            .onChange(of: appManager.isSearching) {
                adManager.shouldShowAds = !appManager.isSearching
            }
            .onChange(of: appManager.searchedWord) {
                searchTextChanged()
            }
            .onChange(of: filterState) {
                filterGameRecords()
            }
            .onChange(of: appManager.selectedLanguage) {
                selectedLanguageChanged()
            }
            .onAppear {
                viewAppeared()
            }
        }
    }
    
    @available(iOS 17.1, *)
    private func emptySearchState(title: String, description: String, buttonTitle: String, action: @escaping () -> Void) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.primary)
        } description: {
            Text(description)
        } actions: {
            Button(buttonTitle, action: action)
                .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .darkGradientBackground(colorScheme: colorScheme)
    }
    
    @available(iOS 17.1, *)
    @ViewBuilder
    private func wordSection(for letter: String) -> some View {
        if #available(iOS 26.0, *) {
            baseWordSection(for: letter)
                .sectionIndexLabel(letter)
        } else {
            baseWordSection(for: letter)
        }
    }
    
    @available(iOS 17.1, *)
    private func baseWordSection(for letter: String) -> some View {
        let sectionWords = groupedWords[letter] ?? []
        
        return Section {
            ForEach(Array(sectionWords.enumerated()), id: \.offset) { index, word in
                wordRow(index: index, word: word, count: sectionWords.count)
            }
        } header: {
            SectionHeaderView(letter: letter)
        }
        .listSectionSeparator(.hidden)
        .wordlrListSectionBackground()
        .id(letter)
    }
    
    @available(iOS 17.1, *)
    private func wordRow(index: Int, word: String, count: Int) -> some View {
        NavigationLink {
            WordDefinitionView(word: word, language: appManager.selectedLanguage)
        } label: {
            HStack {
                Text(word)
                    .font(.title3)
                    .foregroundStyle(.primary)
                Spacer()
            }
        }
        .contextMenu {
            Button {
                appManager.useWord(word: word)
                dismiss()
            } label: {
                Label("Use the word", systemImage: "checkmark.circle")
            }
        }
        .wordlrListSectionRowBackground(index: index, count: count)
    }
    
    @ViewBuilder
    private var filterOptionsSheet: some View {
        if #available(iOS 26.0, *) {
            FilterOptionsView(isShowingFilterOptions: $isShowingFilterOptions)
                .environment(appManager)
                .presentationDetents(UIDevice.current.userInterfaceIdiom == .phone ? [.large, .fraction(0.8)] : [.large], selection: $selectedDetent)
                .presentationDragIndicator(.hidden)
                .navigationTransition(.zoom(sourceID: "filter", in: namespace))
        } else {
            FilterOptionsView(isShowingFilterOptions: $isShowingFilterOptions)
                .environment(appManager)
        }
    }
    
    private var listBottomPadding: CGFloat {
        guard adManager.isBannerAdLoaded else { return 0 }
        
        let idiom = UIDevice.current.userInterfaceIdiom
        return idiom == .pad || idiom == .mac ? 80 : 54
    }
    
    private var filterState: FilterState {
        FilterState(
            isFilteringSearchWord: appManager.isFilteringSearchWord,
            isFilteringStartWith: appManager.isFilteringStartWith,
            startsWithFilter: appManager.startsWithFilter,
            isFilteringEndsWith: appManager.isFilteringEndsWith,
            endsWithFilter: appManager.endsWithFilter,
            isFilteringIncludedLetters: appManager.isFilteringIncludedLetters,
            selectedIncludedLetters: appManager.selectedIncludedLetters,
            isFilteringExcludeLetters: appManager.isFilteringExcludeLetters,
            selectedExcludedLetters: appManager.selectedExcludedLetters,
            numberOfLetters: appManager.numberOfLetters,
            selectedGameMode: appManager.selectedGameMode,
            isExpertModeEnabled: appManager.isExpertModeEnabled
        )
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
        let sortComparator = String.Comparator(options: .caseInsensitive, locale: appManager.selectedLanguage.sortLocale, order: .forward)
        let sortedWords = filteredWords.sorted(using: sortComparator)
        self.searchResults = sortedWords
        self.groupedWords = Dictionary(grouping: sortedWords, by: { String($0.prefix(1)).uppercased() })
        self.sectionKeys = self.sortedSectionKeys(Array(self.groupedWords.keys), using: sortComparator)
    }

    private func sortedSectionKeys(_ keys: [String], using sortComparator: String.Comparator) -> [String] {
        let alphabetOrder = Dictionary(uniqueKeysWithValues: appManager.selectedLanguage.alphabet.enumerated().map { ($0.element, $0.offset) })
        return keys.sorted { lhs, rhs in
            switch (alphabetOrder[lhs], alphabetOrder[rhs]) {
                case let (lhsIndex?, rhsIndex?):
                    return lhsIndex < rhsIndex
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    return sortComparator.compare(lhs, rhs) == .orderedAscending
            }
        }
    }
    
    private func searchTextChanged() {
        filterGameRecords()
        AnalyticsManager.shared.logDidUseSearchEvent(word: appManager.word, language: appManager.selectedLanguage, numberOfLetters: appManager.numberOfLetters, gameMode: appManager.gameMode)
    }
    
    private func selectedLanguageChanged() {
        appManager.ensureWordsLoadedForSearch()
        filterGameRecords()
    }
    
    private func viewAppeared() {
        AnalyticsManager.shared.logScreenViewed(screenName: "SearchView")
        appManager.ensureWordsLoadedForSearch()
        filterGameRecords()
        adManager.currentSelectView = .searchView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            adManager.shouldShowAds = true
        }
    }
    
    private func openFilterOptions() {
        if didResetFiltersWithLongPress {
            didResetFiltersWithLongPress = false
            return
        }
        
        DispatchQueue.main.async {
            self.isShowingFilterOptions = true
        }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.didResetFiltersWithLongPress = false
        }
    }
    
    private func clearSearch() {
        appManager.searchedWord = ""
        filterGameRecords()
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
