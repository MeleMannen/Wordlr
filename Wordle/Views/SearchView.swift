//
//  SearchView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        GeometryReader { geometry in
            if searchResults.isEmpty && !appManager.searchedWord.isEmpty {
                ContentUnavailableView.search(text: appManager.searchedWord)
            } else {
                List {
                    ForEach(searchResults, id: \.self) { word in
                        NavigationLink(destination: {
                            WordDescriptionView(word: word)
                                .environmentObject(appManager)
                        }, label: {
                            Text(word)
                        })
                        
                    }
                }
                .contentMargins(12, for: .scrollContent)
                
                
                
            }
            
        }
        .searchable(text: $appManager.searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Phrase")
        .navigationTitle("Search")
        .toolbarBackground(.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            //            appManager.searchedWord = ""
        }
        
    }
    
    var searchResults: [String] {
//        let unfilterdWords = appManager.words?.wordGroups["\(appManager.numberOfLetters)"]?.sorted { $0.localizedCompare($1) == .orderedAscending } ?? []
        let unfilterdWords = appManager.words?.wordGroups["\(appManager.numberOfLetters)"] ?? []
//        for word in unfilterdWords {
//            if word == unfilterdWords.last {
//                print("\"\(word)\"")
//            } else {
//                print("\"\(word)\",")
//            }
//            
//        }
        if appManager.searchedWord.isEmpty {
            return unfilterdWords
        } else {
            return unfilterdWords.filter { $0.contains(appManager.searchedWord.uppercased()) }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(AppManager())
}
