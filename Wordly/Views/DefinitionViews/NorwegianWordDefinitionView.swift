//
//  WordDescriptionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct NorwegianWordDefinitionView: View {
	@Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var definitionManager: DefinitionManager
	@AppStorage("userWantsAds") private var userWantsAds: Bool = false
    @State var processedWords: [ProcessedWord] = []
    @State var word: String
    @State var isLoading: Bool = true
    @State var didTap: Bool = false
    
    var body: some View {
        VStack {
            if !self.isLoading {
                ScrollView {
                    if !self.processedWords.isEmpty {
                        ForEach(self.processedWords) { processedWord in
                            VStack {
                                VStack(alignment: .leading) {
                                    if let words = processedWord.words {
                                        Text(words.joined(separator: ", ").uppercased())
                                            .font(.largeTitle)
                                            .bold()
                                    } else {
                                        Text(self.word.uppercased())
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
								RoundedRectangle(cornerRadius: 20)
									.foregroundStyle(Color(uiColor: .secondarySystemBackground))
                            }
							.overlay(alignment: .bottomTrailing) {
								Text("ordbokene.no")
									.font(.body)
									.fontWeight(.semibold)
									.foregroundColor(.secondary)
									.padding(.trailing, 10)
									.padding(.bottom, 8)
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
                                    .padding(.bottom, 10)
                                
                                HStack {
                                    Text("We couldn't find a definition for this Word. That might be because it is a name or a place name.")
                                        .font(.title3)
                                    
                                    Spacer()
                                }
								Text("You could try to search in the Dictionary NAOB: ")
									.font(.headline)
									.padding(.top, 10)
								
								if #available(iOS 26.0, *) {
									NavigationLink(destination: NAOBView(word: self.word)) {
										Text("Search \(self.word.uppercased())")
											.foregroundColor(.white)
											.font(.title2).bold()
											.padding(14)
											.frame(maxWidth: .infinity)
											.background {
												if self.scenePhase == .background {
													RoundedRectangle(cornerRadius: 15)
														.foregroundStyle(Color(uiColor: .systemGreen))
												}
											}
									}
									.glassEffect(.regular.tint(.green).interactive(), in: .rect(cornerRadius: 15.0))
									.simultaneousGesture(TapGesture().onEnded {
										self.didTap.toggle()
									})
									.padding(.top, 10)
									
									.padding(.horizontal, 40)
									.sensoryFeedback(.impact, trigger: self.didTap)
								} else {
									NavigationLink(destination: NAOBView(word: self.word)) {
										Text("Search \(self.word.uppercased())")
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
									.padding(.top, 10)
									.sensoryFeedback(.impact, trigger: self.didTap)
									.buttonStyle(GrowingButton())
								}
                            }
                            .padding(25)
                            
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 20)
								.foregroundStyle(Color(uiColor: .secondarySystemBackground))
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                        
                    }
                    
                }
                .refreshable {
                    definitionManager.getDefinition(for: self.word) { processedWords in
						self.processedWords = processedWords
						self.isLoading = false
						print("ProcessedWord: \(String(describing: self.processedWords))")
						dump(self.processedWords)
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
            definitionManager.getDefinition(for: self.word) { processedWords in
                self.processedWords = processedWords
                self.isLoading = false
                print("ProcessedWord: \(String(describing: self.processedWords))")
                dump(self.processedWords)
				AnalyticsManager.shared.logDidViewWordDefinitionEvent(word: self.word, language: .norwegian, numberOfLetters: self.word.count, viewSuccess: !self.processedWords.isEmpty)
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
            
            if !self.definition.nestedDefinitions.isEmpty {
                ForEach(Array(self.definition.nestedDefinitions.enumerated()), id: \.offset) { i, nestedDefinition in
                    DefinitionView(definition: nestedDefinition, isNested: true, index: self.definition.explanations.isEmpty ? self.index + i : (self.index + i))
                }
            }
        }
    }
}


#Preview {
    NorwegianWordDefinitionView(word: "Sessing")
        .environmentObject(DefinitionManager())
}
