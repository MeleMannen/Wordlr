//
//  BoardView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 30/06/2025.
//

import SwiftUI

struct BoardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
    @State var gameRecord: GameRecord
    @State var board: [[Letter]]
    let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
    let shadowGradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    private var device: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
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
    
    private var keyboardRows: [[String]] {
        switch self.gameRecord.language {
            case .english:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
            case .norwegian:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Å"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ø", "Æ"], ["Z", "X", "C", "V", "B", "N", "M"]]
            case .spanish:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ñ"], ["Z", "X", "C", "V", "B", "N", "M"]]
            case .all:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
        }
    }
    
    private func state(for key: String) -> LetterState {
        var bestState: LetterState = .notUsed
        
        for row in self.board {
            for letter in row where letter.letter == key {
                switch letter.state {
                    case .correctPosition:
                        return .correctPosition
                    case .correctLetter:
                        bestState = bestState == .usedButNotCorrect ? .correctLetter : bestState == .correctPosition ? .correctPosition : .correctLetter
                    case .usedButNotCorrect:
                        if bestState == .notUsed {
                            bestState = .usedButNotCorrect
                        }
                    case .notUsed:
                        continue
                }
            }
        }
        
        return bestState
    }
    
    private func color(for state: LetterState) -> Color {
        switch state {
            case .correctPosition:
                return .green
            case .correctLetter:
                return .orange
            case .usedButNotCorrect:
                return Color(UIColor.darkGray)
            case .notUsed:
                return self.colorForUnused
        }
    }
    
    @ViewBuilder
    private func hiddenKeyboard(in geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            ForEach(Array(self.keyboardRows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: self.device == .pad ? 8 : 5) {
                    if rowIndex == self.keyboardRows.count - 1 {
                        Text("Z")
                            .hidden()
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                        
                        Text("Z")
                            .hidden()
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                    }
                    
                    ForEach(row, id: \.self) { key in
                        let keyState = self.state(for: key)
                        Text(key)
                            .font(.title3).bold()
                            .foregroundStyle(keyState == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
                            .hidden()
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(self.color(for: keyState))
                                    .hidden()
                            }
                    }
                    
                    if rowIndex == self.keyboardRows.count - 1 {
                        Text("Z")
                            .hidden()
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                        
                        Text("Z")
                            .hidden()
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                    }
                }
            }
            
            HStack {
                Text("Z")
                    .hidden()
                    .frame(minWidth: geometry.size.width / CGFloat(9), maxWidth: geometry.size.width / CGFloat(7), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                
                Spacer()
                
                Text("SUBMIT WORD")
                    .font(.title).bold()
                    .hidden()
                    .frame(minWidth: (geometry.size.width * 7) / CGFloat(14) + CGFloat(self.device == .pad ? 60 : 30), maxWidth: (geometry.size.width * 7) / CGFloat(12) + CGFloat(self.device == .pad ? 60 : 30), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                
                Spacer()
                
                Text("Z")
                    .hidden()
                    .frame(minWidth: geometry.size.width / CGFloat(9), maxWidth: geometry.size.width / CGFloat(7), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            
            Spacer()
        }
        .padding(.horizontal, 5)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                GeometryReader { geometry2 in
                    VStack {
                        ForEach(self.board.indices, id: \.self) { rowIndex in
                            HStack {
                                ForEach(self.board[rowIndex].indices, id: \.self) { colIndex in
                                    let letter = self.board[rowIndex][colIndex]
                                    if self.gameRecord.numberOfLetters < 5 {
                                        Text(letter.letter)
                                            .font(.largeTitle).bold()
                                            .foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
                                            .frame(width: geometry2.size.height / CGFloat(6), height: geometry2.size.height / CGFloat(6))
                                            .background {
                                                if !self.userWantsNormalTheme && self.colorScheme == .dark && self.gameRecord.mode == .dailyWord && self.gameRecord.state == .won && (rowIndex == self.gameRecord.numberOfGuesses - 1 || rowIndex == self.board.count) {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .foregroundStyle(self.gradient)
                                                        .gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused)))
                                                }
                                            }
                                        
                                    } else {
                                        Text(letter.letter)
                                            .font(.largeTitle).bold()
                                            .foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
                                            .frame(width: geometry2.size.height / CGFloat(self.gameRecord.numberOfLetters + 1), height: geometry2.size.height / CGFloat(self.gameRecord.numberOfLetters + 1))
                                            .background {
                                                if !self.userWantsNormalTheme && self.gameRecord.mode == .dailyWord && self.gameRecord.state == .won && (rowIndex == self.gameRecord.numberOfGuesses - 1 || rowIndex == self.board.count) {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .foregroundStyle(self.gradient)
                                                        .gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused)))
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
                    
                }
                GeometryReader { geometry2 in
                    self.hiddenKeyboard(in: geometry2)
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 2 / 5)
            }
            .padding(.top, 15)
        }
        .navigationTitle("The board")
        .navigationBarTitleDisplayMode(.inline)
		.onAppear {
			AnalyticsManager.shared.logScreenViewed(screenName: "BoardView")
		}
    }
}

//#Preview {
//    BoardView()
//}
