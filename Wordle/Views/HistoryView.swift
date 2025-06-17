//
//  HistoryView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 17/06/2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appManager: AppManager
    @Namespace private var namespace
    
    var searchResults: [GameRecordEntity] {
        var filteredWords = appManager.gameRecords
        if !appManager.searchedWord.isEmpty {
            filteredWords = filteredWords.filter { $0.gameRecord.word.contains(appManager.searchedWord.uppercased()) }
        }
        
        return filteredWords
        
    }
    
    private var groupedWords: [String: [GameRecordEntity]] {
        return Dictionary(grouping: searchResults, by: { String(formatter1.string(from: $0.gameRecord.date)) })
            
    }
    
    private var sectionKeys: [String] {
        return groupedWords.keys.sorted { date1, date2 in
            guard let date1 = formatter1.date(from: date1), let date2 = formatter1.date(from: date2) else {
                return false
            }
            return date1 > date2
        }
    }
    
    private let formatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            
            VStack {
                if self.searchResults.isEmpty && !appManager.searchedWord.isEmpty {
                    ContentUnavailableView.search(text: appManager.searchedWord)
                } else if self.searchResults.isEmpty {
                    ContentUnavailableView.init("History is not available yet!", systemImage: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", description: Text("Try playing a game first."))
                } else {
                    ScrollViewReader { proxy in
                        HStack(spacing: 0) {
                            List {
                                ForEach(sectionKeys, id: \.self) { date in
                                    Section {
                                        ForEach(groupedWords[date] ?? [], id: \.id) { gameRecordEntity in
                                            NavigationLink(destination: {
                                                GameRecordView(gameRecord: gameRecordEntity.gameRecord)
                                                    .environmentObject(appManager)
                                                
                                            }, label: {
                                                HStack {
                                                    Image(systemName: gameRecordEntity.gameRecord.state == .won ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                        .foregroundColor(gameRecordEntity.gameRecord.state == .won ? .green : .red)
                                                        .font(.title)
                                                        .padding(.leading, 10)
                                                    
                                                    Text(gameRecordEntity.gameRecord.word)
                                                        .font(.title3)
                                                        .foregroundStyle(.primary)
                                                    Spacer()
                                                }
                                            })
                                            
                                        }
                                    } header: {
                                        SectionHeaderView(letter: date)
                                    }
                                    .listSectionSeparator(.hidden)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $appManager.searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Phrase")
            .navigationTitle("History")
        }
        
        
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppManager())
}

