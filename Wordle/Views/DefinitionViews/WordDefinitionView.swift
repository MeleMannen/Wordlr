//
//  WordDefinitionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 09/06/2025.
//

import SwiftUI

struct WordDefinitionView: View {
    @State var word: String = ""
    @State var language: LanguageSelection = .english
    
    var body: some View {
        if self.language == .english {
            EnglishWordDefinitionView(word: self.word)
                .environmentObject(DefinitionManager())
        } else if self.language == .norwegian {
            NorwegianWordDefinitionView(word: self.word)
                .environmentObject(DefinitionManager())
        }
    }
}

#Preview {
    WordDefinitionView(word: "Hello")
        .environmentObject(AppManager())
}
