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
		} else if self.language == .spanish {
			SpanishWordDefinitionView(word: self.word)
				.environmentObject(DefinitionManager())
		
		}
    }
}

struct DefinitionLoadingView: View {
	var body: some View {
		ProgressView()
			.progressViewStyle(CircularProgressViewStyle())
			.font(.largeTitle)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview {
    WordDefinitionView(word: "Hello")
}
