//
//  GameRecordView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 17/06/2025.
//

import SwiftUI

struct GameRecordView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var appManager: AppManager
    var gameRecord: GameRecord
    @State private var didTap: Bool = false
    @State private var hasSharedResult: Bool = false
    @State private var timeUsedString: String = ""
    
    private let formatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeZone = TimeZone(identifier: "CET")
        return formatter
    }()
    
    var colorForUnused: Color {
        switch colorScheme {
            case .light:
                return Color(UIColor.lightGray)
            case .dark:
                return .primary
            @unknown default:
                return .primary
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text("\(gameRecord.word)")
                            .font(.largeTitle).bold()
                            .conditionalShadow(color: .black.opacity(0.5), radius: 10, x: 6, y: 6)
                        
                        Spacer()
                        if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .padding(12)
                                .background {
                                    Circle()
                                        .foregroundStyle(LinearGradient(colors: [.orange, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing))
//                                        .padding(5)
                                        .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
                                        .conditionalShadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
                                }
                                .font(.system(size: 40))
                                
                                
                            
                        } else {
                            Image(systemName: gameRecord.state == .won ? "checkmark" : "xmark")
                                .foregroundStyle(.white)
                                .padding(12)
                                .background {
                                    Circle()
                                        .foregroundColor(gameRecord.state == .won ? .green : .red)
                                        .conditionalShadow(color: .black.opacity(0.3), radius: 3, x: 4, y: 4)
//                                        .conditionalShadow(color: .black.opacity(0.5), radius: 5, x: 4, y: 4)
                                }
                                .font(.system(size: 40))
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom) {
                            Text("Date: ")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                            Spacer()
                            if gameRecord.mode == .dailyWord && gameRecord.state == .won {
//                                GradientShadowView(text: "\(String(formatter1.string(from: gameRecord.date)))", gradient: appManager.gradient, alignment: .trailing, blurRadius: 1)
                                Text("\(String(formatter1.string(from: gameRecord.date)))")
                                    .font(.title2)
                                    .foregroundStyle(appManager.gradient)
//                                    .gradientShadow(gradient: appManager.shadowGradient, radius: 1, x: 0, y: 0)
                                    .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                            } else {
                                Text("\(String(formatter1.string(from: gameRecord.date)))")
                                    .font(.title2)
                                
                            }
                        }
                        .padding(.bottom, 5)
                        
                        HStack(alignment: .bottom) {
                            Text("Number of Letters:")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                            Spacer()
                            if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                                Text("\(gameRecord.numberOfLetters)")
                                    .font(.title2)
                                    .foregroundStyle(appManager.gradient)
//                                    .gradientShadow(gradient: appManager.shadowGradient, radius: 1, x: 0, y: 0)
                                    .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                            } else {
                                Text("\(gameRecord.numberOfLetters)")
                                    .font(.title2)
                            }
                            
                        }
                        .padding(.bottom, 5)
                        
                       
                        
                        HStack(alignment: .bottom) {
                            Text("Language:")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                            Spacer()
                            if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                                Text("\(gameRecord.language.localizedName)")
                                    .font(.title2)
                                    .foregroundStyle(appManager.gradient)
//                                    .gradientShadow(gradient: appManager.shadowGradient, radius: 1, x: 0, y: 0)
                                    .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                            } else {
                                Text("\(gameRecord.language.localizedName)")
                                    .font(.title2)
                            }
                            
                        }
                        .padding(.bottom, 5)
                        
                        HStack(alignment: .bottom) {
                            Text("Mode:")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                            Spacer()
                            if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                                Text("\(gameRecord.mode.localizedName)")
                                    .font(.title2)
                                    .foregroundStyle(appManager.gradient)
//                                    .gradientShadow(gradient: appManager.shadowGradient, radius: 1, x: 0, y: 0)
                                    .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                            } else {
                                Text("\(gameRecord.mode.localizedName)")
                                    .font(.title2)
                            }
                        }
                        .padding(.bottom, 5)
                        
                        HStack(alignment: .bottom) {
                            Text("Number of Guesses:")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                            Spacer()
                            if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                                Text("\(gameRecord.numberOfGuesses)")
                                    .font(.title2)
                                    .foregroundStyle(appManager.gradient)
//                                    .gradientShadow(gradient: appManager.shadowGradient, radius: 1, x: 0, y: 0)
                                    .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                            } else {
                                Text("\(gameRecord.numberOfGuesses)")
                                    .font(.title2)
                            }
                            
                        }
                        .padding(.bottom, 5)
                        
                        
                        if let hintsUsed = gameRecord.hintsUsed, hintsUsed > 0 {
                            HStack(alignment: .bottom) {
                                Text("Hints used:")
                                    .foregroundStyle(.secondary)
                                    .font(.title3)
                                Spacer()
                                if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                                    Text("\(hintsUsed)")
                                        .font(.title2)
                                        .foregroundStyle(appManager.gradient)
//                                        .gradientShadow(gradient: appManager.shadowGradient, radius: 1, x: 0, y: 0)
                                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                        
                                } else {
                                    Text("\(hintsUsed)")
                                        .font(.title2)
                                }
                            }
                            .padding(.bottom, 5)
                        }
                        
                        if !self.timeUsedString.isEmpty {
                            HStack(alignment: .bottom) {
                                Text("Time Used: ")
                                    .foregroundStyle(.secondary)
                                    .font(.title3)
                                Spacer()
                                if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                                    Text(self.timeUsedString)
                                        .font(.title2)
                                        .foregroundStyle(appManager.gradient)
//                                        .gradientShadow(gradient: appManager.shadowGradient, radius: 1, x: 0, y: 0)
                                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                } else {
                                    Text(self.timeUsedString)
                                        .font(.title2)
                                }
                            }
                            .padding(.bottom, 5)
                        }
                    }
                    .padding()
                    
                    NavigationLink(destination: WordDefinitionView(word: gameRecord.word).environmentObject(appManager)) {
                        Text("Show Definition")
                            .foregroundColor(.white)
                            .conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)
                            .font(.title2).bold()
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                            }
                            .padding(.horizontal, 40)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        self.didTap.toggle()
                    })
                    .padding(.vertical, 10)
                    .sensoryFeedback(.impact, trigger: self.didTap)
                    .buttonStyle(GrowingButton())
                    .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                    
                    
                    if let board = gameRecord.board {
                        NavigationLink(destination: BoardView(gameRecord: self.gameRecord, board: board).environmentObject(appManager)) {
                            Text("View The Board")
                                .foregroundColor(.white)
                                .conditionalShadow(color: .black.opacity(0.1), radius: 1.5, x: 1, y: 1)
                                .font(.title2).bold()
                                .padding(14)
                                .frame(maxWidth: .infinity)
                                .background {
                                    if gameRecord.mode == .dailyWord && gameRecord.state == .won {
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(appManager.gradient)
                                            .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
                                    } else {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.orange)
                                    }
                                }
                                .padding(.horizontal, 40)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            self.didTap.toggle()
                        })
                        .padding(.vertical, 10)
                        .sensoryFeedback(.impact, trigger: self.didTap)
                        .buttonStyle(GrowingButton())
                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                    }
                    
                    if let board = gameRecord.board, gameRecord.mode == .dailyWord {
                        HStack {
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    if let endDate = gameRecord.endDate {
                                        UIPasteboard.general.string = appManager.getShareResult(row: gameRecord.numberOfGuesses, numberOfLetters: gameRecord.numberOfLetters, date: gameRecord.date, board: board, timeUsedString: appManager.getTimeUsedString(startDate: self.gameRecord.date, endDate: endDate))
                                    } else {
                                        UIPasteboard.general.string = appManager.getShareResult(row: gameRecord.numberOfGuesses, numberOfLetters: gameRecord.numberOfLetters, date: gameRecord.date, board: board)
                                    }
                                    self.hasSharedResult = true
                                    self.didTap.toggle()
                                }
                            } label: {
                                if gameRecord.state == .won {
                                    Label("Copy Result", systemImage: hasSharedResult ? "doc.on.doc.fill" : "doc.on.doc")
                                        .font(.title2).bold()
                                        .contentTransition(.symbolEffect(.replace))
                                        .foregroundStyle(appManager.gradient)
//                                        .gradientShadow(gradient: appManager.shadowGradient, radius: 2, x: 0, y: 0)
//                                        .shadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                        
                                } else {
                                    Label("Copy Result", systemImage: hasSharedResult ? "doc.on.doc.fill" : "doc.on.doc")
                                        .font(.title2).bold()
                                        .contentTransition(.symbolEffect(.replace))
                                }
                                
                            }
                            .padding(.vertical, 15)
                            .sensoryFeedback(.impact, trigger: self.didTap)
                            
                            Spacer()
                            
                        }
                    }
                    
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
                
                
            }
            .navigationTitle(gameRecord.word)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let endDate = gameRecord.endDate {
                    self.timeUsedString = appManager.getTimeUsedString(startDate: self.gameRecord.date, endDate: endDate).trimmingCharacters(in: .whitespaces)
                }
            }
            
        }
    }
}


#Preview {
    GameRecordView(gameRecord: GameRecord(date: Date(), state: .won, mode: .dailyWord, word: "Word", language: .english, numberOfLetters: 4, numberOfGuesses: 2, hintsUsed: 0, board: [[Letter(letter: "W", state: .correctPosition), Letter(letter: "O", state: .correctPosition), Letter(letter: "R", state: .correctPosition), Letter(letter: "D", state: .correctPosition)], [Letter(letter: "W", state: .correctPosition), Letter(letter: "O", state: .correctPosition), Letter(letter: "R", state: .correctPosition), Letter(letter: "D", state: .correctPosition)]]))
        .environmentObject(AppManager())
}
