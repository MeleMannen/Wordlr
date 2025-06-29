//
//  StatsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 11/06/2025.
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var appManager: AppManager
    @AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .both
    @AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
    @AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
    @AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
    @State var hasFixedDefualtValues: Bool = false
    @State var numberOfLetters: Int = 9
    @State var selectedLanguage: LanguageSelection = .both
    @State var gameMode: GameMode = .both
    @State var showsWhenHintsUsed: ShowsWhenHintsUsed = .both
    
    var selectedGameRecords: [GameRecordEntity] {
        var gameRecords = appManager.gameRecords
        
        if self.numberOfLetters != 9 {
            gameRecords = gameRecords.filter { $0.gameRecord.numberOfLetters == self.numberOfLetters }
        }
        
        if self.selectedLanguage != .both {
            gameRecords = gameRecords.filter { $0.gameRecord.language == self.selectedLanguage }
        }
        
        if self.gameMode != .both {
            gameRecords = gameRecords.filter { $0.gameRecord.mode == self.gameMode }
        }
        
        if self.showsWhenHintsUsed == .neverUsed {
            gameRecords = gameRecords.filter { $0.gameRecord.hintsUsed ?? 0 == 0 }
        } else if self.showsWhenHintsUsed == .onlyWhenUsed {
            gameRecords = gameRecords.filter { $0.gameRecord.hintsUsed ?? 0 > 0 }
        }
        
        return gameRecords
    }
    
    var maxNumberOfRows: Int {
        if self.numberOfLetters > 7 {
            return 8
        } else if self.numberOfLetters == 6 {
            return 7
        } else {
            return 6
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
                    .environmentObject(appManager)
                
                    
                if selectedGameRecords.isEmpty {
                    ContentUnavailableView.init("No stats available for this selection.", systemImage: "exclamationmark.triangle.fill", description: Text("Try playing a game first or changing the selction."))
                        .padding(.bottom, 20)
                } else {
                    List {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Played:")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer()
                                    Text("\(selectedGameRecords.count)")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                            }
                            .padding(.bottom, 10)
                            
                        }
                        // Chart for Win Rate, where the x-axis is the either won or lost, and the y-axis is the win rate (1 for won, 0 for lost)
                        VStack(alignment: .leading) {
                            let wonCount = selectedGameRecords.filter { $0.gameRecord.state == .won }.count
                            let lostCount = selectedGameRecords.filter { $0.gameRecord.state == .lost }.count
                            let totalCount = wonCount + lostCount
                            let winRate = totalCount > 0 ? Double(wonCount) / Double(totalCount) : 0.0
                            HStack {
                                Text("Win Rate:")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Text("\(String(format: "%.0f%%", winRate * 100))")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Chart {
                                
                                BarMark(
                                    x: .value("Count", wonCount),
                                    y: .value("State", "✅"),
                                    width: .fixed(20.0)
                                )
                                .foregroundStyle(Color.green)
                                .annotation(position: .overlay) {
                                    if wonCount > 0 {
                                        Text("\(wonCount)")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                    
                                }
                                
                                BarMark(
                                    x: .value("Count", lostCount),
                                    y: .value("State", "❌"),
                                    width: .fixed(20.0)
                                )
                                .foregroundStyle(Color.red)
                                .annotation(position: .overlay) {
                                    if lostCount > 0 {
                                        Text("\(lostCount)")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                    
                                }
                            }
                            .chartYAxis {
                                AxisMarks(preset: .extended, position: .leading) { _ in
                                    AxisValueLabel(horizontalSpacing: 15)
                                        .font(.footnote)
                                }
                            }
                        }
                        
                        // Chart for Number of Guesses, where the y-axis is the number of guesses, from 1-6, and the x-axis is the amount of guesses
                        VStack(alignment: .leading) {
                            Text("Number of Guesses:")
                                .font(.title2)
                                .bold()
                            
                            Chart {
                                ForEach(1...self.maxNumberOfRows, id: \.self) { guess in
                                    let count = selectedGameRecords.filter { $0.gameRecord.numberOfGuesses == guess && $0.gameRecord.state == .won }.count
                                    
                                    BarMark(
                                        x: .value("Count", count),
                                        y: .value("Number of Guesses", " \(guess) "),
                                        width: .fixed(20.0)
                                    )
                                    .foregroundStyle(Color.green)
                                    .annotation(position: .overlay) {
                                        if count > 0 {
                                            Text("\(count)")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks(preset: .extended, position: .leading) { _ in
                                    AxisValueLabel(horizontalSpacing: 15)
                                        .font(.footnote)
                                }
                            }
                            .frame(minHeight: 250)
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
        .onAppear {
            if !self.hasFixedDefualtValues {
                self.setDefaultValues()
                self.hasFixedDefualtValues = true
            }
        }
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
        .environmentObject(AppManager())
}
