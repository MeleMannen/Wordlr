//
//  StatsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 11/06/2025.
//

import SwiftUI
import Charts
import SwiftData

struct StatsView: View {
    @AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .all
    @AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
    @AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
    @AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
	@AppStorage("userWantsAds") private var userWantsAds: Bool = false
    @State private var hasFixedDefualtValues: Bool = false
    @State private var numberOfLetters: Int = 9
    @State private var selectedLanguage: LanguageSelection = .all
    @State private var gameMode: GameMode = .both
    @State private var showsWhenHintsUsed: ShowsWhenHintsUsed = .both
    @State private var maxNumberOfRows: Int = 6
    @State private var filteredGameRecords: [GameRecordEntity] = []
    @State private var wonCount: Int = 0
    @State private var lostCount: Int = 0
    @State private var totalCount: Int = 0
    @State private var winRate: Double = 0.0
    @State private var counts: [Int] = []
    @State private var maxGuessesPerCount: Int = 0
    
    @Query private var gameRecords: [GameRecordEntity]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
                    
                    if self.filteredGameRecords.isEmpty {
                        ContentUnavailableView.init("No stats available for this selection!", systemImage: "exclamationmark.triangle.fill", description: Text("Try playing a game first or changing the selection."))
                            .padding(.bottom, 20)
                    } else {
                        List {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Played:")
                                        .font(.title3).bold()
                                    
                                    Spacer()
                                    
                                    Text("\(self.filteredGameRecords.count)")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Win Rate:")
                                        .font(.title3).bold()
                                    Spacer()
                                    Text("\(String(format: "%.0f%%", self.winRate * 100))")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Chart {
                                    BarMark(
                                        x: .value("Count", self.wonCount),
                                        y: .value("State", "✅"),
                                        width: .fixed(20.0)
                                    )
                                    .foregroundStyle(Color.green)
                                    .annotation(position: self.wonCount < (self.lostCount / 6) ? .trailing : .overlay) {
                                        if self.wonCount > 0 {
                                            Text("\(self.wonCount)")
                                                .foregroundColor(self.wonCount < (self.lostCount / 6) ? .primary : .white)
                                                .font(.headline)
                                        }
                                    }
                                    
                                    BarMark(
                                        x: .value("Count", self.lostCount),
                                        y: .value("State", "❌"),
                                        width: .fixed(20.0)
                                    )
                                    .foregroundStyle(Color.red)
                                    .annotation(position: self.lostCount < (self.wonCount / 6) ? .trailing : .overlay) {
                                        if self.lostCount > 0 {
                                            Text("\(self.lostCount)")
                                                .foregroundColor(self.lostCount < (self.wonCount / 6) ? .primary : .white)
                                                .font(.headline)
                                        }
                                    }
                                }
                                .chartXScale(domain: 0...Double(self.totalCount))
                                .chartYAxis {
                                    AxisMarks(preset: .extended, position: .leading) { _ in
                                        AxisValueLabel(horizontalSpacing: 15)
                                            .font(.footnote)
                                    }
                                }
                                .animation(.easeInOut(duration: 0.5), value: self.filteredGameRecords.count)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Number of Guesses:")
                                    .font(.title3).bold()
                                
                                Chart {
                                    ForEach(Array(self.counts.enumerated()), id: \.offset) { index, count in
                                        BarMark(
                                            x: .value("Count", count),
                                            y: .value("Number of Guesses", " \(index+1) "),
                                            width: .fixed(20.0)
                                        )
                                        .foregroundStyle(Color.green)
                                        .annotation(position: count < (self.maxGuessesPerCount / 6) ? .trailing : .overlay) {
                                            if count > 0 {
                                                Text("\(count)")
                                                    .foregroundColor(count < (self.maxGuessesPerCount / 6) ? .primary : .white)
                                                    .font(.headline)
                                            }
                                        }
                                    }
                                }
                                .chartXScale(domain: 0...Double(self.maxGuessesPerCount))
                                .chartYAxis {
                                    AxisMarks(preset: .extended, position: .leading) { _ in
                                        AxisValueLabel(horizontalSpacing: 15)
                                            .font(.footnote)
                                    }
                                }
                                .animation(.easeInOut(duration: 0.5), value: self.filteredGameRecords.count)
                                .frame(minHeight: 250)
                            }
                        }
						.safeAreaPadding(.bottom, self.userWantsAds ? 54 : 0)
                    }
                }
                .navigationTitle("Stats")
                .onChange(of: self.numberOfLetters) {
                    if self.numberOfLetters > 7 {
                        self.maxNumberOfRows = 8
                    } else if self.numberOfLetters == 6 {
                        self.maxNumberOfRows = 7
                    } else {
                        self.maxNumberOfRows = 6
                    }
                    self.filterGameRecords()
                }
                .onChange(of: self.selectedLanguage) {
                    self.filterGameRecords()
                }
                .onChange(of: self.gameMode) {
                    self.filterGameRecords()
                }
                .onChange(of: self.showsWhenHintsUsed) {
                    self.filterGameRecords()
                }
            }
                
        }
        .onAppear {
            if !self.hasFixedDefualtValues {
                self.setDefaultValues()
                if self.numberOfLetters > 7 {
                    self.maxNumberOfRows = 8
                } else if self.numberOfLetters == 6 {
                    self.maxNumberOfRows = 7
                } else {
                    self.maxNumberOfRows = 6
                }
                self.hasFixedDefualtValues = true
            }
            
            self.filterGameRecords()
        }
    }
    
    func filterGameRecords() {
        var filteredRecords = self.gameRecords
        
        if self.numberOfLetters != 9 {
            filteredRecords = filteredRecords.filter { $0.gameRecord.numberOfLetters == self.numberOfLetters }
        }
        
        if self.selectedLanguage != .all {
            filteredRecords = filteredRecords.filter { $0.gameRecord.language == self.selectedLanguage }
        }
        
        if self.gameMode != .both {
            filteredRecords = filteredRecords.filter { $0.gameRecord.mode == self.gameMode }
        }
        
        if self.showsWhenHintsUsed == .neverUsed {
            filteredRecords = filteredRecords.filter { $0.gameRecord.hintsUsed ?? 0 == 0 }
        } else if self.showsWhenHintsUsed == .onlyWhenUsed {
            filteredRecords = filteredRecords.filter { $0.gameRecord.hintsUsed ?? 0 > 0 }
        }
        self.filteredGameRecords = filteredRecords
        print("Selected game records: \(self.filteredGameRecords.count)")
        self.wonCount = self.filteredGameRecords.filter { $0.gameRecord.state == .won }.count
        self.lostCount = self.filteredGameRecords.filter { $0.gameRecord.state == .lost }.count
        self.totalCount = self.wonCount + self.lostCount
        self.winRate = self.totalCount > 0 ? Double(self.wonCount) / Double(self.totalCount) : 0.0
        
        self.counts.removeAll()
        for i in 1...self.maxNumberOfRows {
            self.counts.append(self.filteredGameRecords.filter { $0.gameRecord.numberOfGuesses == i && $0.gameRecord.state == .won }.count)
        }
        self.maxGuessesPerCount = self.counts.max() ?? 0
    }
    
    func setDefaultValues() {
        self.selectedLanguage = self.defaultStatLanguage
        self.numberOfLetters = self.defaultStatNumberOfLetters
        self.gameMode = self.defaultStatGameMode
        self.showsWhenHintsUsed = self.defaultStatHintsUsed
    }
}

#Preview {
    StatsView()
}
