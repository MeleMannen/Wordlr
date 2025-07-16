//
//  SearchView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appManager: AppManager
    @Namespace private var namespace
    @State var searchedWord: String = ""
    @State var isShowingFilterOptions: Bool = false
    @State var isFilteringSearchWord: Bool = true
    @State var isFilteringStartWith: Bool = false
    @State var startsWithFilter: String = ""
    @State var isFilteringEndsWith: Bool = false
    @State var endsWithFilter: String = ""
    @State var isFilteringExcludeLetters: Bool = false
    @State var isFilteringIncludedLetters: Bool = false
    @State var selectedExcludedLetters: [String] = []
    @State var selectedIncludedLetters: [String] = []
    @State private var searchResults: [String] = []
    @State private var groupedWords: [String: [String]] = [:]
    @State private var sectionKeys: [String] = []
    
//    var searchResults: [String] {
//        var filteredWords = appManager.words?.wordGroups["\(appManager.numberOfLetters)"] ?? []
////        let shuffledWords = filteredWords.shuffled()
////        for word in shuffledWords {
////            if word == shuffledWords.last {
////                print("\"\(word)\"")
////                print("fini")
////            } else {
////                print("\"\(word)\",")
////            }
////            
////        }
//        if self.isFilteringSearchWord && !self.searchedWord.isEmpty {
//            filteredWords = filteredWords.filter { $0.contains(self.searchedWord.uppercased()) }
//        }
//        if self.isFilteringStartWith && !self.startsWithFilter.isEmpty {
//            filteredWords = filteredWords.filter { $0.hasPrefix(self.startsWithFilter.uppercased()) }
//        }
//        if self.isFilteringEndsWith && !self.endsWithFilter.isEmpty {
//            filteredWords = filteredWords.filter { $0.hasSuffix(self.endsWithFilter.uppercased()) }
//        }
//        
//        if self.isFilteringIncludedLetters && !self.selectedIncludedLetters.isEmpty {
//            let excludedCharacters = Set(self.selectedIncludedLetters.joined())
//            filteredWords = filteredWords.filter { word in
//                excludedCharacters.isDisjoint(with: word.uppercased())
//            }
//        }
//        
//        if self.isFilteringExcludeLetters && !self.selectedExcludedLetters.isEmpty {
//            let excludedCharacters = Set(self.selectedExcludedLetters.joined())
//            filteredWords = filteredWords.filter { word in
//                excludedCharacters.isDisjoint(with: word.uppercased())
//            }
//        }
//        
//        return filteredWords
//        
//    }
//    
//    private var groupedWords: [String: [String]] {
//        Dictionary(grouping: searchResults.sorted()) { String($0.prefix(1)).uppercased() }
//    }
//    
//    private var sectionKeys: [String] {
//        groupedWords.keys.sorted()
//    }
    
    var body: some View {
        VStack {
            if self.searchResults.isEmpty && !self.searchedWord.isEmpty {
                ContentUnavailableView.search(text: self.searchedWord)
            } else {
                HStack(spacing: 0) {
                    List {
                        ForEach(sectionKeys, id: \.self) { letter in
                            Section {
                                ForEach(Array((groupedWords[letter] ?? []).enumerated()), id: \.offset) { index, word in
                                    LazyVStack(spacing: 0) {
                                        NavigationLink(destination: {
                                            WordDefinitionView(word: word)
                                                .environmentObject(appManager)
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
                    
                }
            }
        }
        .searchable(text: self.$searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Phrase")
        .navigationTitle("Search")
        .onChange(of: self.searchedWord) {
            self.filterGameRecords()
        }
        .onChange(of: self.isFilteringSearchWord) {
            self.filterGameRecords()
        }
        .onChange(of: self.startsWithFilter) {
            self.filterGameRecords()
        }
        .onChange(of: self.isFilteringStartWith) {
            self.filterGameRecords()
        }
        .onChange(of: self.endsWithFilter) {
            self.filterGameRecords()
        }
        .onChange(of: self.isFilteringEndsWith) {
            self.filterGameRecords()
        }
        .onChange(of: self.selectedIncludedLetters) {
            self.filterGameRecords()
        }
        .onChange(of: self.isFilteringIncludedLetters) {
            self.filterGameRecords()
        }
        .onChange(of: self.selectedExcludedLetters) {
            self.filterGameRecords()
        }
        .onChange(of: self.isFilteringExcludeLetters) {
            self.filterGameRecords()
        }
        .overlay(alignment: .bottomTrailing) {
            NavigationLink(destination: FilterOptionsView(searchedWord: self.$searchedWord, isFilteringSearchWord: self.$isFilteringSearchWord, isFilteringStartWith: self.$isFilteringStartWith, startsWithFilter: self.$startsWithFilter, isFilteringEndsWith: self.$isFilteringEndsWith, endsWithFilter: self.$endsWithFilter, isFilteringExcludeLetters: self.$isFilteringExcludeLetters, isFilteringIncludedLetters: self.$isFilteringIncludedLetters, selectedExcludedLetters: self.$selectedExcludedLetters, selectedIncludedLetters: self.$selectedIncludedLetters).environmentObject(appManager).navigationTransition(.zoom(sourceID: "filter", in: namespace)), label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .clipShape(Circle())
                    .sensoryFeedback(.selection, trigger: self.isShowingFilterOptions)
                    .matchedTransitionSource(id: "filter", in: namespace)
//                    .glassEffect(in: .circle)
//                    .glassEffectID("filter", in: namespace)
                    
                    
                
            })
            .padding(.trailing, 25)
            .padding(.bottom, 25)
            .transition(.scale)
            .buttonStyle(GrowingButton())
            .simultaneousGesture(TapGesture().onEnded {
                self.isShowingFilterOptions.toggle()
            })
//            .buttonStyle(.glass)
            
        }
        .onAppear {
            self.filterGameRecords()
        }
    }
    
    func filterGameRecords() {
        var filteredWords = appManager.words?.wordGroups["\(appManager.numberOfLetters)"] ?? []
        //        let shuffledWords = filteredWords.shuffled()
        //        for word in shuffledWords {
        //            if word == shuffledWords.last {
        //                print("\"\(word)\"")
        //                print("fini")
        //            } else {
        //                print("\"\(word)\",")
        //            }
        //
        //        }
        if self.isFilteringSearchWord && !self.searchedWord.isEmpty {
            filteredWords = filteredWords.filter { $0.contains(self.searchedWord.uppercased()) }
        }
        if self.isFilteringStartWith && !self.startsWithFilter.isEmpty {
            filteredWords = filteredWords.filter { $0.hasPrefix(self.startsWithFilter.uppercased()) }
        }
        if self.isFilteringEndsWith && !self.endsWithFilter.isEmpty {
            filteredWords = filteredWords.filter { $0.hasSuffix(self.endsWithFilter.uppercased()) }
        }
        
        if self.isFilteringIncludedLetters && !self.selectedIncludedLetters.isEmpty {
            let excludedCharacters = Set(self.selectedIncludedLetters.joined())
            filteredWords = filteredWords.filter { word in
                excludedCharacters.isDisjoint(with: word.uppercased())
            }
        }
        
        if self.isFilteringExcludeLetters && !self.selectedExcludedLetters.isEmpty {
            let excludedCharacters = Set(self.selectedExcludedLetters.joined())
            filteredWords = filteredWords.filter { word in
                excludedCharacters.isDisjoint(with: word.uppercased())
            }
        }
        self.searchResults = filteredWords
        self.groupedWords = Dictionary(grouping: self.searchResults.sorted(), by: { String($0.prefix(1)).uppercased() })
        self.sectionKeys = groupedWords.keys.sorted()
//        self.searchResults = appManager.gameRecords
//        if !self.searchedWord.isEmpty {
//            self.searchResults = self.searchResults.filter { $0.gameRecord.word.contains(self.searchedWord.uppercased()) }
//        }
//        if self.numberOfLetters != 9 {
//            self.searchResults = self.searchResults.filter { $0.gameRecord.numberOfLetters == self.numberOfLetters }
//        }
//        
//        if self.selectedLanguage != .both {
//            self.searchResults = self.searchResults.filter { $0.gameRecord.language == self.selectedLanguage }
//        }
//        
//        if self.gameMode != .both {
//            self.searchResults = self.searchResults.filter { $0.gameRecord.mode == self.gameMode }
//        }
//        
//        if self.showsWhenHintsUsed == .neverUsed {
//            self.searchResults = self.searchResults.filter { $0.gameRecord.hintsUsed ?? 0 == 0 }
//        } else if self.showsWhenHintsUsed == .onlyWhenUsed {
//            self.searchResults = self.searchResults.filter { $0.gameRecord.hintsUsed ?? 0 > 0 }
//        }
//        print("Filtered Results: \(self.searchResults.count)")
//        self.groupedWords = Dictionary(grouping: searchResults.sorted { $0.gameRecord.date > $1.gameRecord.date }, by: { String(formatter1.string(from: $0.gameRecord.date)) })
//        self.sectionKeys = groupedWords.keys.sorted { date1, date2 in
//            guard let date1 = formatter1.date(from: date1), let date2 = formatter1.date(from: date2) else {
//                return false
//            }
//            return date1 > date2
//        }
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
