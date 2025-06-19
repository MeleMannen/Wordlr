//
//  HistoryView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 17/06/2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appManager: AppManager
    @AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .both
    @AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
    @AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
    @State var hasFixedDefualtValues: Bool = false
    @State private var numberOfLetters: Int = 9
    @State private var selectedLanguage: LanguageSelection = .both
    @State private var gameMode: GameMode = .both
    
    var searchResults: [GameRecordEntity] {
        var filteredRecords = appManager.gameRecords
        if !appManager.searchedWord.isEmpty {
            filteredRecords = filteredRecords.filter { $0.gameRecord.word.contains(appManager.searchedWord.uppercased()) }
        }
        if self.numberOfLetters != 9 {
            filteredRecords = filteredRecords.filter { $0.gameRecord.numberOfLetters == self.numberOfLetters }
        }
        
        if self.selectedLanguage != .both {
            filteredRecords = filteredRecords.filter { $0.gameRecord.language == self.selectedLanguage }
        }
        
        if self.gameMode != .both {
            filteredRecords = filteredRecords.filter { $0.gameRecord.mode == self.gameMode }
        }
        
        return filteredRecords
        
    }
    
    private var groupedWords: [String: [GameRecordEntity]] {
        return Dictionary(grouping: searchResults.sorted { $0.gameRecord.date > $1.gameRecord.date }, by: { String(formatter1.string(from: $0.gameRecord.date)) })
            
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
                FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode)
                    .environmentObject(appManager)
                if self.searchResults.isEmpty && !appManager.searchedWord.isEmpty {
                    ContentUnavailableView.search(text: appManager.searchedWord)
                } else if self.searchResults.isEmpty {
                    ContentUnavailableView.init("History is not available with this selction!", systemImage: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", description: Text("Try playing a game first."))
                } else {
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
                                                .background {
                                                    Circle()
                                                        .fill(.primary)
                                                        .padding(5)
                                                }
                                                .font(.title)
                                            
                                            
                                            Text(gameRecordEntity.gameRecord.word)
                                                .font(.title3)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                        }
                                    })
                                    
                                }
                                .onDelete { indexSet in
                                    withAnimation {
                                        indexSet.forEach { index in
                                            if let gameRecordEntity2 = groupedWords[date]?[index] {
                                                appManager.deleteGameRecord(gameRecordEntity2)
                                            }
                                        }
                                    }
                                }
                            } header: {
                                SectionHeaderView(letter: date)
                            }
                            .listSectionSeparator(.hidden)
                        }
                    }
                }
            }
            .searchable(text: $appManager.searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Phrase")
            .navigationTitle("History")
            .onAppear {
                if !self.hasFixedDefualtValues {
                    self.setDefaultValues()
                    self.hasFixedDefualtValues = true
                }
            }
        }
    }
    
    func setDefaultValues() {
        self.selectedLanguage = self.defaultStatLanguage
        self.numberOfLetters = self.defaultStatNumberOfLetters
        self.gameMode = self.defaultStatGameMode
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppManager())
}

