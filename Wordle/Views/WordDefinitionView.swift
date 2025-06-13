//
//  WordDefinitionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 09/06/2025.
//

import SwiftUI

struct WordDefinitionView: View {
    @EnvironmentObject var appManager: AppManager
    @State var word: String = ""
    
    var body: some View {
        if appManager.selectedLanguage == .english {
            EnglishWordDefinitionView(word: self.word)
        } else if appManager.selectedLanguage == .norwegian {
            NorwegianWordDefinitionView(word: self.word)
        }
    }
}

#Preview {
    WordDefinitionView(word: "Hello")
        .environmentObject(AppManager())
}
