//
//  WordDescriptionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct WordDescriptionView: View {
    @EnvironmentObject var appManager: AppManager
    @State var processedWords: [ProcessedWord] = []
    @State var word: String
    @State var isLoading: Bool = true
    
    var body: some View {
        VStack {
            if !self.isLoading {
                ScrollView {
                    if !self.processedWords.isEmpty {
                        ForEach(self.processedWords) { processedWord in
                            VStack {
                                VStack(alignment: .leading) {
                                    if let words = processedWord.words {
                                        Text(words.joined(separator: ", "))
                                            .font(.largeTitle)
                                            .bold()
                                    } else {
                                        Text(self.word.lowercased())
                                            .font(.largeTitle)
                                        
                                            .bold()
                                    }
                                    
                                    
                                    HStack {
                                        if let wordClass = processedWord.wordClass {
                                            Text("\(wordClass)  ")
                                                .font(.subheadline)
                                        }
                                        
                                        if let gender = processedWord.gender {
                                            Text(gender.capitalized)
                                                .font(.subheadline)
                                                .italic()
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 2)
                                    .padding(.bottom, 10)
                                    
                                    
                                    
                                    if let pronunciation = processedWord.pronunciation {
                                        HStack(alignment: .top) {
                                            Text("PRONUNCIATION   ")
                                                .font(.headline)
                                            
                                            
                                            Text(pronunciation)
                                                .italic()
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 10)
                                        
                                    }
                                    
                                    if let etymology = processedWord.etymology {
                                        HStack(alignment: .top) {
                                            Text("ORIGIN   ")
                                                .font(.headline)
                                            
                                            
                                            Text(etymology.joined(separator: ", "))
                                                .italic()
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.bottom, 10)
                                        
                                    }
                                    
                                    if let definitions = processedWord.definitions {
                                        ForEach(definitions, id: \.id) { definition in
                                            DefinitionView(definition: definition, isNested: false, index: 1)
                                        }
                                    }
                                }
                                .padding(25)
                                
                                
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: .quaternarySystemFill))
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 20)
                            
                            
                        }
                        
                        
                        
                    }
                    else {
                        VStack {
                            VStack(alignment: .leading) {
                                Text(self.word)
                                    .font(.largeTitle)
                                    .bold()
                                
                                Text("We couldn't find a definition for this word.")
                                    .font(.title3)
                            }
                            .padding(25)
                            
                            
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(uiColor: .quaternarySystemFill))
                        }
                        .padding(.horizontal, 5)
                        .padding(.top, 20)
                    }
                    
                }
                .refreshable {
                    appManager.getDefinition(for: self.word) { processedWords in
                        if !processedWords.isEmpty {
                            self.processedWords = processedWords
                            //                        self.isLoading = false
                            print("ProcessedWord: \(String(describing: self.processedWords))")
                            dump(self.processedWords)
                        }
                    }
                }
                
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                
            }
        }
        .navigationTitle("\(self.word)")
        .toolbarBackground(.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            appManager.getDefinition(for: self.word) { processedWords in
                self.processedWords = processedWords
                self.isLoading = false
                print("ProcessedWord: \(String(describing: self.processedWords))")
                dump(self.processedWords)
            }
        }
    }
}





struct DefinitionView: View {
    let definition: ProcessedDefinition
    var isNested: Bool
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            if !self.isNested {
                if !self.definition.explanations.isEmpty || !self.definition.nestedDefinitions.isEmpty || !self.definition.quotes.isEmpty {
                    Text("EXPLANATION AND USAGE")
                        .font(.headline)
                        .padding(.bottom, 3)
                        .bold()
                }
            }
            
            
            if !self.definition.explanations.isEmpty {
                HStack(alignment: .top) {
                    Text("\(self.index).")
                        .foregroundColor(.gray)
                        .bold()
                    Text("  ")
                        .foregroundColor(.gray)
                    VStack(alignment: .leading) {
                        Text("\(self.definition.explanations.joined(separator: ";\n"))")
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if !self.definition.quotes.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Example")
                                    .padding(.bottom, 2)
                                    .font(.headline)
                                ForEach(self.definition.quotes, id: \.self) { quote in
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .font(.body)
                                            .italic()
                                            .foregroundColor(.gray)
                                        VStack(alignment: .leading) {
                                            Text("\(quote)")
                                                .font(.body)
                                                .italic()
                                                .foregroundColor(.gray)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                    
                        
                }
                .padding(.bottom, 20)
                .padding(.leading, 2)
                
            } else if !self.definition.quotes.isEmpty {
                VStack(alignment: .leading) {
                    Text("Example")
                        .padding(.bottom, 2)
                        .font(.headline)
                    ForEach(self.definition.quotes, id: \.self) { quote in
                        HStack(alignment: .top) {
                            Text("•")
                                .font(.body)
                                .italic()
                                .foregroundColor(.gray)
                            VStack(alignment: .leading) {
                                Text("\(quote)")
                                    .font(.body)
                                    .italic()
                                    .foregroundColor(.gray)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                        }
                    }
                }
                
            }
            
                
            
            
//            if !self.definition.examples.isEmpty {
//                Text("Examples:")
//                    .font(.headline)
//                ForEach(self.definition.examples) { example in
//                    Text("• \(example.text): \(example.explanation)")
//                        .font(.body)
//                }
//            }
            
            if !self.definition.nestedDefinitions.isEmpty {
//                Text("Nested Definitions:")
//                    .font(.headline)
                ForEach(Array(self.definition.nestedDefinitions.enumerated()), id: \.offset) { i, nestedDefinition in
                    DefinitionView(definition: nestedDefinition, isNested: true, index: self.definition.explanations.isEmpty ? self.index + i : (self.index + i))
//                        .padding(.leading, 10)
                }
            }
        }
    }
}


#Preview {
    WordDescriptionView(word: "Hei")
        .environmentObject(AppManager())
}
