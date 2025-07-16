//
//  HistoryView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 17/06/2025.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @EnvironmentObject var appManager: AppManager
    @AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .both
    @AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
    @AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
    @AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
    @State private var hasFixedDefualtValues: Bool = false
    @State private var numberOfLetters: Int = 9
    @State private var selectedLanguage: LanguageSelection = .both
    @State private var gameMode: GameMode = .both
    @State private var showsWhenHintsUsed: ShowsWhenHintsUsed = .both
    @State private var searchedWord: String = ""
    @State private var searchResults: [GameRecordEntity] = []
    @State private var groupedWords: [String: [GameRecordEntity]] = [:]
    @State private var sectionKeys: [String] = []
    
    private let formatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack {
                FilterView(numberOfLetters: $numberOfLetters, selectedLanguage: $selectedLanguage, gameMode: $gameMode, showsWhenHintsUsed: $showsWhenHintsUsed)
//                    .environmentObject(appManager)
                if self.searchResults.isEmpty && !self.searchedWord.isEmpty {
                    ContentUnavailableView.search(text: self.searchedWord)
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
                                            if gameRecordEntity.gameRecord.mode == .dailyWord && gameRecordEntity.gameRecord.state == .won {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.white)
                                                    .padding(10)
                                                    .background {
                                                        Circle()
                                                            .foregroundStyle(LinearGradient(colors: [.orange, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing))
                                                        //                                        .padding(5)
                                                            .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
                                                            .conditionalShadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                                                    }
                                                    .font(.title2)
                                                    
                                            } else {
                                                Image(systemName: gameRecordEntity.gameRecord.state == .won ? "checkmark" : "xmark")
                                                    .foregroundStyle(.white)
                                                    .padding(10)
                                                    .background {
                                                        Circle()
                                                            .foregroundColor(gameRecordEntity.gameRecord.state == .won ? .green : .red)
                                                            .conditionalShadow(color: .black.opacity(0.3), radius: 3, x: 4, y: 4)
                                                        //                                        .conditionalShadow(color: .black.opacity(0.5), radius: 5, x: 4, y: 4)
                                                    }
                                                    .font(.title2)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text(gameRecordEntity.gameRecord.word)
                                                    .font(.title3)
                                                    .foregroundStyle(.primary)
                                                    .conditionalShadow(color: .black.opacity(0.3), radius: 1.5, x: 4, y: 4)
                                                if gameRecordEntity.gameRecord.mode == .dailyWord && gameRecordEntity.gameRecord.state == .won {
//                                                    GradientShadowView(text: gameRecordEntity.gameRecord.mode.localizedName + " - \(gameRecordEntity.gameRecord.numberOfLetters) letters", gradient: appManager.gradient, alignment: .leading, blurRadius: 5)
//                                                        .font(.caption)
//                                                        .padding(.top, -5)
                                                    let localizedString = String(format: NSLocalizedString("number_letters", comment: "Daily Word Mode with number of letters"))
                                                    Text(gameRecordEntity.gameRecord.mode.localizedName + " - " + localizedString)
                                                        .font(.caption)
                                                        .foregroundStyle(appManager.gradient)
                                                        .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
                                                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
//                                                        .spreadGradientShadow(appManager.shadowGradient, spread: 3)
//
                                                } else if gameRecordEntity.gameRecord.mode == .dailyWord {
                                                    Text(gameRecordEntity.gameRecord.mode.localizedName + " - \(gameRecordEntity.gameRecord.numberOfLetters) letters")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
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
            .searchable(text: self.$searchedWord, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Phrase")
            .navigationTitle("History")
            .onChange(of: self.searchedWord) {
                self.filterGameRecords()
            }
            .onChange(of: self.numberOfLetters) {
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
            .onAppear {
                if !self.hasFixedDefualtValues {
                    self.setDefaultValues()
                    self.hasFixedDefualtValues = true
                }
                self.filterGameRecords()
            }
        }
    }
    
    func filterGameRecords() {
        var filteredRecords = appManager.gameRecords
        if !self.searchedWord.isEmpty {
            filteredRecords = filteredRecords.filter { $0.gameRecord.word.contains(self.searchedWord.uppercased()) }
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
        
        if self.showsWhenHintsUsed == .neverUsed {
            filteredRecords = filteredRecords.filter { $0.gameRecord.hintsUsed ?? 0 == 0 }
        } else if self.showsWhenHintsUsed == .onlyWhenUsed {
            filteredRecords = filteredRecords.filter { $0.gameRecord.hintsUsed ?? 0 > 0 }
        }
        self.searchResults = filteredRecords
        print("Filtered Results: \(self.searchResults.count)")
        self.groupedWords = Dictionary(grouping: searchResults.sorted { $0.gameRecord.date > $1.gameRecord.date }, by: { String(formatter1.string(from: $0.gameRecord.date)) })
        self.sectionKeys = groupedWords.keys.sorted { date1, date2 in
            guard let date1 = formatter1.date(from: date1), let date2 = formatter1.date(from: date2) else {
                return false
            }
            return date1 > date2
        }
    }
    
    func setDefaultValues() {
        self.selectedLanguage = self.defaultStatLanguage
        self.numberOfLetters = self.defaultStatNumberOfLetters
        self.gameMode = self.defaultStatGameMode
        self.showsWhenHintsUsed = self.defaultStatHintsUsed
    }
}

extension View {
    func gradientShadow(gradient: LinearGradient, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self.overlay(
            self.mask(gradient)
                .blur(radius: radius)
                .offset(x: x, y: y)
        )
    }
}

struct GradientShadowView: View {
    let text: String
    let gradient: LinearGradient
    let alignment: Alignment
    let blurRadius: CGFloat
    
    var body: some View {
        ZStack(alignment: alignment) {
            gradient
                .mask(alignment: alignment) {
                    Text(text)
                        .fixedSize()
                }
                .blur(radius: blurRadius)
            
                .overlay(alignment: alignment) {
                    Text(text)
                        .foregroundStyle(gradient)
                        .blur(radius: 0.2)
                }
                .frame(maxWidth: .infinity, alignment: alignment)
        }
    }
}

//struct GradientShadowText: View {
//    let text: String
//    let gradient: LinearGradient
//    
//    var body: some View {
////        ZStack(alignment: .leading) {
//            // 1) the “shadow” behind, masked to the text’s shape
//            gradient
//                .mask(
//                    Text(text)
//                )
//                .blur(radius: 3)
//                .overlay(
//                    Text(text)
//                        .foregroundStyle(gradient)
//                )
//            
//            // 2) the actual, sharp text on top
////            Text(text)
////                .foregroundStyle(gradient)
////        }
//    }
//}
//
//struct SpreadGradientShadow: ViewModifier {
//    let gradient: LinearGradient
//    let spread: CGFloat
//    
//    func body(content: Content) -> some View {
//        ZStack {
//            ForEach(
//                [CGPoint(x: -spread, y: -spread),
//                 CGPoint(x:  spread, y: -spread),
//                 CGPoint(x: -spread, y:  spread),
//                 CGPoint(x:  spread, y:  spread)],
//                id: \.self
//            ) { point in
//                gradient
//                    .mask(content)
//                    .offset(x: point.x, y: point.y)
//            }
//            
//            content
//        }
//    }
//}
//
//extension View {
//    func spreadGradientShadow(
//        _ gradient: LinearGradient,
//        spread: CGFloat = 2
//    ) -> some View {
//        modifier(SpreadGradientShadow(gradient: gradient, spread: spread))
//    }
//}

#Preview {
    HistoryView()
        .environmentObject(AppManager())
}

