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
//    @State private var selectedLetter: String = ""
//    @State private var lastScrolledLetter: String = ""
//    @State private var lastScrollTime: Date = Date()
    
    var searchResults: [String] {
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
        if appManager.isFilteringSearchWord && !appManager.searchedWord.isEmpty {
            filteredWords = filteredWords.filter { $0.contains(appManager.searchedWord.uppercased()) }
        }
        if appManager.isFilteringStartWith && !appManager.startsWithFilter.isEmpty {
            filteredWords = filteredWords.filter { $0.hasPrefix(appManager.startsWithFilter.uppercased()) }
        }
        if appManager.isFilteringEndsWith && !appManager.endsWithFilter.isEmpty {
            filteredWords = filteredWords.filter { $0.hasSuffix(appManager.endsWithFilter.uppercased()) }
        }
        
        if appManager.isFilteringExcludeLetters && !appManager.selectedExcludedLetters.isEmpty {
            let excludedCharacters = Set(appManager.selectedExcludedLetters.joined())
            filteredWords = filteredWords.filter { word in
                excludedCharacters.isDisjoint(with: word.uppercased())
            }
        }
        
        return filteredWords
        
    }
    
    private var groupedWords: [String: [String]] {
        Dictionary(grouping: searchResults.sorted()) { String($0.prefix(1)).uppercased() }
    }
    
    private var sectionKeys: [String] {
        groupedWords.keys.sorted()
    }
    
    var body: some View {
        VStack {
            if self.searchResults.isEmpty && !appManager.searchedWord.isEmpty {
                ContentUnavailableView.search(text: appManager.searchedWord)
            } else {
                ScrollViewReader { proxy in
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
                        
//                        if searchResults.count < 200 {
//                            VStack {
//                                Spacer()
//                                GeometryReader { geometry in
//                                    let letterHeight: CGFloat = 15
//                                    let totalLetterHeight = CGFloat(sectionKeys.count) * letterHeight
//                                    let startY = (geometry.size.height - totalLetterHeight) / 2
//                                    
//                                    VStack(spacing: 1) {
//                                        ForEach(Array(sectionKeys.enumerated()), id: \.offset) { index, letter in
//                                            Text(letter)
//                                                .font(.system(size: 12, weight: .bold))
//                                                .foregroundColor(.blue)
//                                                .frame(width: 15, height: letterHeight)
//                                                .contentShape(Rectangle())
//                                                .onTapGesture {
//                                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                                        proxy.scrollTo(letter, anchor: .top)
//                                                    }
//                                                }
//                                        }
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
//                                    .gesture(
//                                        DragGesture(minimumDistance: 0)
//                                            .onChanged { value in
//                                                let adjustedY = value.location.y - startY
//                                                let index = Int(adjustedY / letterHeight)
//                                                let clampedIndex = min(max(index, 0), sectionKeys.count - 1)
//                                                
//                                                if clampedIndex >= 0 && clampedIndex < sectionKeys.count {
//                                                    let newSelectedLetter = sectionKeys[clampedIndex]
//                                                    
//                                                    // Only scroll and trigger feedback if letter changed
//                                                    if lastScrolledLetter != newSelectedLetter {
//                                                        let now = Date()
//                                                        
//                                                        // Throttle scrolling to max 60fps (16ms intervals)
//                                                        if now.timeIntervalSince(lastScrollTime) >= 0.016 {
//                                                            selectedLetter = newSelectedLetter
//                                                            lastScrolledLetter = newSelectedLetter
//                                                            lastScrollTime = now
//                                                            
//                                                            // Provide haptic feedback
//                                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
//                                                            impactFeedback.impactOccurred()
//                                                            
//                                                            // Immediate scroll with very subtle animation
////                                                            withAnimation(.linear(duration: 0.05)) {
//                                                                proxy.scrollTo(newSelectedLetter, anchor: .top)
////                                                            }
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                            .onEnded { _ in
//                                                // Reset tracking when drag ends
//                                                lastScrolledLetter = ""
//                                                lastScrollTime = Date()
//                                            }
//                                    )
//                                }
//                                Spacer()
//                            }
//                            .frame(width: 15)
//                        }
                        
                    }
                }
            }
        }
        .searchable(text: $appManager.searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Phrase")
        .navigationTitle("Search")
        
        .overlay(alignment: .bottomTrailing) {
            NavigationLink(destination: FilterOptionsView().environmentObject(appManager).navigationTransition(.zoom(sourceID: "filter", in: namespace)), label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .clipShape(Circle())
                    .sensoryFeedback(.selection, trigger: appManager.isShowingFilterOptions)
                    .matchedTransitionSource(id: "filter", in: namespace)
//                    .glassEffect(in: .circle)
//                    .glassEffectID("filter", in: namespace)
                    
                
            })
            .padding(.trailing, 25)
            .padding(.bottom, 25)
            .transition(.scale)
//            .buttonStyle(.glass)
            
        }
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
