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
                Spacer(minLength: geometry.size.height*2 / 5)
            }
            .padding(.top, 15)
        }
        .navigationTitle("The Board")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    BoardView()
//}
