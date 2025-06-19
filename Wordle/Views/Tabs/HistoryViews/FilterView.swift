//
//  FilterView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 20/06/2025.
//

import SwiftUI

struct FilterView: View {
    @EnvironmentObject var appManager: AppManager
    @Binding var numberOfLetters: Int
    @Binding var selectedLanguage: LanguageSelection
    @Binding var gameMode: GameMode
    
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
                .sensoryFeedback(.selection, trigger: gameMode)
                .modifier(ConditionalGlassEffect())
            }
            .padding(.leading)
        }
        .scrollIndicators(.hidden)
    }
}

//#Preview {
//    FilterView(numberOfLetters: 9, selectedLanguage: .both, gameMode: .both)
//        .environmentObject(AppManager())
//}
