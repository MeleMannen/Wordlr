//
//  GameRecordView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 17/06/2025.
//

import SwiftUI

struct GameRecordView: View {
    @EnvironmentObject var appManager: AppManager
    @State var gameRecord: GameRecord
    @State private var didTap: Bool = false
    
    private let formatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("\(gameRecord.word)")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: gameRecord.state == .won ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(gameRecord.state == .won ? .green : .red)
                        .background {
                            Circle()
                                .fill(.white)
                                .padding(5)
                        }
                        .font(.largeTitle)
                }
                .padding(.top)
                .padding(.horizontal)
                
                HStack(alignment: .bottom) {
                    Text("Date: ")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                    Spacer()
                    Text("\(String(formatter1.string(from: gameRecord.date)))")
                        .font(.title2)
                }
                
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        Text("Number of Guesses:")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        Spacer()
                        Text("\(gameRecord.numberOfGuesses)")
                            .font(.title2)
                    }
                    .padding(.bottom, 5)
                    HStack(alignment: .bottom) {
                        Text("Language:")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        Spacer()
                        Text("\(gameRecord.language.localizedName)")
                            .font(.title2)
                    }
                    .padding(.bottom, 5)
                    HStack(alignment: .bottom) {
                        Text("Mode:")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        Spacer()
                        Text("\(gameRecord.mode.localizedName)")
                            .font(.title2)
                    }
                    .padding(.bottom, 5)
                    
                    
                }
                .padding()
//                .padding(.horizontal, 10)
                
                NavigationLink(destination: WordDefinitionView(word: gameRecord.word).environmentObject(appManager)) {
                    Text("Get Definition")
                        .foregroundColor(.white)
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
                
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .quaternarySystemFill))
            }
            .padding(.horizontal, 15)
            .padding(.top, 20)
        }
        .navigationTitle(gameRecord.word)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    GameRecordView(gameRecord: GameRecord(state: .won, mode: .dailyWord, word: "Word", language: .english, numberOfLetters: 4, numberOfGuesses: 2))
        .environmentObject(AppManager())
}
