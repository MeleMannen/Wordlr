//
//  FilterView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 20/06/2025.
//

import SwiftUI

struct FilterView: View {
    @Binding var numberOfLetters: Int
    @Binding var selectedLanguage: LanguageSelection
    @Binding var gameMode: GameMode
    @Binding var showsWhenHintsUsed: ShowsWhenHintsUsed
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                Picker("", selection: $numberOfLetters) {
                    ForEach(1...9, id: \.self) { number in
                        if number != 9 {
                            Text("\(number) letters")
                                .font(.title2).bold()
                        } else {
                            Text("All letters")
                                .font(.title2).bold()
                        }
                    }
                }
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
//                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
//                    }
                }
                .sensoryFeedback(.selection, trigger: self.numberOfLetters)
                .modifier(ConditionalGlassEffect())
                
                Picker("", selection: $selectedLanguage) {
                    ForEach(LanguageSelection.allCases) { language in
                        Text(language.localizedName.capitalized)
                    }
                }
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
//                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
//                    }
                }
                .sensoryFeedback(.selection, trigger: selectedLanguage)
                .modifier(ConditionalGlassEffect())
                
                Picker("", selection: $gameMode) {
                    ForEach(GameMode.allCases) { mode in
                        Text(mode.localizedName.capitalized)
                    }
                }
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
//                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
//                    }
                }
                .sensoryFeedback(.selection, trigger: gameMode)
                .modifier(ConditionalGlassEffect())
                
                Picker("", selection: $showsWhenHintsUsed) {
                    ForEach(ShowsWhenHintsUsed.allCases) { mode in
                        if mode == .both {
                            Text("Both Hint Usage")
                        } else if mode == .neverUsed {
                            Text("Hints Never Used")
                        } else if mode == .onlyWhenUsed {
                            Text("Only When Hints Was Used")
                        }
                    }
                }
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
//                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
//                    }
                }
                .sensoryFeedback(.selection, trigger: showsWhenHintsUsed)
                .modifier(ConditionalGlassEffect())
            }
            .padding(.leading)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    FilterView(numberOfLetters: .constant(9), selectedLanguage: .constant(.all), gameMode: .constant(.both), showsWhenHintsUsed: .constant(.both))
}
