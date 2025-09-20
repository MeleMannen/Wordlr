//
//  EnglishWordDefinitionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 09/06/2025.
//

import SwiftUI
import AVFoundation

struct EnglishWordDefinitionView: View {
    @EnvironmentObject private var definitionManager: DefinitionManager
	@AppStorage("userWantsAds") private var userWantsAds: Bool = false
    @State var englishDefinition: [EnglishDefinition] = []
    @State var word: String = ""
    @State var isLoading: Bool = true
    
    var body: some View {
        VStack {
            if !self.isLoading {
                ScrollView {
                    if !self.englishDefinition.isEmpty {
                        ForEach(self.englishDefinition) { definition in
                            ForEach(definition.meanings) { meaning in
                                VStack {
                                    VStack(alignment: .leading) {
                                        Text(self.word.uppercased())
                                            .font(.largeTitle)
                                            .bold()
                                        
                                        HStack {
                                            Text("\(meaning.partOfSpeech.uppercased())  ")
                                                .font(.subheadline)
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 2)
                                        .padding(.bottom, 10)
                                        
                                        if !definition.phonetics.isEmpty {
                                            VStack(alignment: .leading) {
                                                HStack(alignment: .top) {
                                                    Text("PRONUNCIATION   ")
                                                        .font(.headline)
                                                    
                                                    Spacer()
                                                }
                                                .padding(.bottom, 3)
                                                
                                                VStack(alignment: .leading) {
                                                    ForEach(Array(definition.phonetics.enumerated()), id: \.offset) { index, phonetic in
                                                        if let text = phonetic.text, !text.isEmpty {
                                                            HStack(alignment: .center) {
                                                                Text("\(index+1).")
                                                                    .foregroundColor(.gray)
                                                                    .bold()
                                                                    .frame(width: 25, alignment: .leading)
                                                                Text("  ")
                                                                    .foregroundColor(.gray)
																
                                                                if let sourceURL = phonetic.sourceURL, !sourceURL.isEmpty {
                                                                    Link("\(text.replacingOccurrences(of: "/", with: ""))", destination: URL(string: "\(sourceURL)")!)
                                                                        .foregroundColor(.blue)
                                                                        .lineLimit(nil)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                } else {
                                                                    Text("\(text.replacingOccurrences(of: "/", with: ""))")
                                                                        .foregroundColor(.gray)
                                                                        .lineLimit(nil)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                }
                                                                if !phonetic.audio.isEmpty {
                                                                    Image(systemName: "play.fill")
                                                                        .foregroundColor(.blue)
                                                                        .onTapGesture {
                                                                            definitionManager.playAudio(from: phonetic.audio)
                                                                        }
                                                                }
                                                            }
                                                            .padding(.bottom, 5)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.bottom, 10)
                                            
                                        } else if let pronunciation = definition.phonetic {
                                            HStack(alignment: .top) {
                                                Text("PRONUNCIATION   ")
                                                    .font(.headline)
                                                
                                                
                                                Text(pronunciation.replacingOccurrences(of: "/", with: ""))
                                                    .italic()
                                                    .foregroundColor(.gray)
                                                
                                                Spacer()
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.bottom, 10)
                                            
                                        }
                                        Text("EXPLANATION AND USAGE")
                                            .font(.headline)
                                            .padding(.bottom, 3)
                                            .bold()
                                        ForEach(Array(meaning.definitions.enumerated()), id: \.offset) { index, def in
                                            HStack(alignment: .top) {
                                                Text("\(index+1).")
                                                    .foregroundColor(.gray)
                                                    .bold()
                                                    .frame(width: 25, alignment: .leading)
                                                Text("  ")
                                                    .foregroundColor(.gray)
                                                
                                                VStack(alignment: .leading) {
                                                    Text("\(def.definition.replacingOccurrences(of: "(see usage)", with: ""))")
                                                        .foregroundColor(.gray)
                                                        .padding(.bottom, 10)
                                                        .lineLimit(nil)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    
                                                    if let example = def.example {
                                                        let examples: [String] = example.split(separator: ";").map { String($0) }
                                                        
                                                        VStack(alignment: .leading) {
                                                            Text("Example")
                                                                .padding(.bottom, 2)
                                                                .font(.headline)
                                                            ForEach(examples, id: \.self) { ex in
                                                                HStack(alignment: .top) {
                                                                    Text("•")
                                                                        .font(.body)
                                                                        .italic()
                                                                        .foregroundColor(.gray)
                                                                    VStack(alignment: .leading) {
                                                                        Text("\(ex.trimmingCharacters(in: .whitespacesAndNewlines))")
                                                                            .font(.body)
                                                                            .italic()
                                                                            .foregroundColor(.gray)
                                                                            .lineLimit(nil)
                                                                            .fixedSize(horizontal: false, vertical: true)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        .padding(.bottom, 20)
                                                        .padding(.leading, 2)
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 10)
                                            .padding(.leading, 2)
                                        }
										
                                        if !meaning.synonyms.isEmpty {
                                            Text("SYNONYMS")
                                                .font(.headline)
                                                .padding(.bottom, 3)
                                                .bold()
                                            ForEach(Array(meaning.synonyms.enumerated()), id: \.offset) { index, synonym in
                                                HStack(alignment: .top) {
                                                    Text("\(index+1).")
                                                        .foregroundColor(.gray)
                                                        .bold()
                                                        .frame(width: 25, alignment: .leading)
                                                    Text("  ")
                                                        .foregroundColor(.gray)
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text("\(synonym)")
                                                            .foregroundColor(.gray)
                                                            .padding(.bottom, 10)
                                                            .lineLimit(nil)
                                                            .fixedSize(horizontal: false, vertical: true)
                                                    }
                                                    .padding(.leading, 2)
                                                }
                                                .padding(.bottom, 10)
                                                .padding(.leading, 2)
                                            }
                                        }
                                        
                                        if !meaning.antonyms.isEmpty {
                                            Text("ANTONYMS")
                                                .font(.headline)
                                                .padding(.bottom, 3)
                                                .bold()
                                            ForEach(Array(meaning.antonyms.enumerated()), id: \.offset) { index, antonym in
                                                HStack(alignment: .top) {
                                                    Text("\(index+1).")
                                                        .foregroundColor(.gray)
                                                        .bold()
                                                        .frame(width: 25, alignment: .leading)
                                                    Text("  ")
                                                        .foregroundColor(.gray)
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text("\(antonym)")
                                                            .foregroundColor(.gray)
                                                            .padding(.bottom, 10)
                                                            .lineLimit(nil)
                                                            .fixedSize(horizontal: false, vertical: true)
                                                    }
                                                    .padding(.leading, 2)
                                                }
                                                .padding(.bottom, 10)
                                                .padding(.leading, 2)
                                            }
                                        }
                                    }
                                    .padding(25)
                                }
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
                                Text(self.word.uppercased())
                                    .font(.largeTitle)
                                    .bold()
                                HStack {
                                    Text("We couldn't find a definition for this Word. That might be because it is a name or a place name.")
                                        .font(.title3)
                                    
                                    Spacer()
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
                .refreshable {
                    definitionManager.getEnglishDefinition(for: self.word) { englishDefinition in
                        self.englishDefinition = englishDefinition
                        print("EnglishDefinition: \(String(describing: self.englishDefinition))")
                        dump(self.englishDefinition)
                    }
                }
				.safeAreaPadding(.bottom, (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac) && self.userWantsAds ? 80 : (self.userWantsAds ? 54 : 0))
                
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .font(.largeTitle)
            }
        }
        .navigationTitle("\(self.word)")
        .onAppear {
            definitionManager.getEnglishDefinition(for: self.word) { englishDefinition in
                self.englishDefinition = englishDefinition
                self.isLoading = false
                print("EnglishDefinition: \(String(describing: self.englishDefinition))")
                dump(self.englishDefinition)
            }
        }
    }
}

#Preview {
    EnglishWordDefinitionView(word: "World")
        .environmentObject(DefinitionManager())
}
