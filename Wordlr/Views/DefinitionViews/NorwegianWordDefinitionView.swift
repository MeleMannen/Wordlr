//
//  WordDescriptionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 12/01/2025.
//

import SwiftUI

struct NorwegianWordDefinitionView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(AdManager.self) private var adManager
	@EnvironmentObject private var definitionManager: DefinitionManager
	@State var processedWords: [NorwegianDefinition] = []
	@State var word: String
	@State var isLoading: Bool = true
	@State var didTap: Bool = false
	@State private var fetchResult: DefinitionFetchResult<[NorwegianDefinition]>?
	private let initialDefinitions: [NorwegianDefinition]?

	init(word: String, initialDefinitions: [NorwegianDefinition]? = nil) {
		self._word = State(initialValue: word)
		self.initialDefinitions = initialDefinitions
		self._processedWords = State(initialValue: initialDefinitions ?? [])
		self._isLoading = State(initialValue: initialDefinitions == nil)
	}
	
	var body: some View {
		VStack {
			if !self.isLoading {
				GeometryReader { geometry in
					ScrollView {
						if !self.processedWords.isEmpty {
							ForEach(self.processedWords) { processedWord in
								VStack {
									VStack(alignment: .leading) {
										if let words = processedWord.words {
											Text(words.joined(separator: ", ").lowercased(with: Locale(identifier: "nb")))
												.font(.system(.largeTitle, design: .serif, weight: .bold))
										} else {
											Text(self.word.lowercased(with: Locale(identifier: "nb")))
												.font(.system(.largeTitle, design: .serif, weight: .bold))
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
										
										if let definitions = processedWord.definitions, !definitions.isEmpty {
											Text("EXPLANATION AND USAGE")
												.font(.headline)
												.padding(.bottom, 3)
											ForEach(Array(definitions.enumerated()), id: \.element.id) { index, definition in
												NorwegianDefinitionTreeView(definition: definition, level: 0, index: index + 1)
											}
										}
									}
									.padding(25)
									.padding(.bottom, self.sourceURL == nil ? 0 : 26)
								}
									.wordlrSurface(cornerRadius: 20)
								.overlay(alignment: .bottomTrailing) {
									if let sourceURL = self.sourceURL {
										if #available(iOS 26.0, *) {
											Link("ordbokene.no", destination: sourceURL)
												.font(.body)
												.fontWeight(.semibold)
												.padding(.trailing, 16)
												.padding(.bottom, 14)
												.onOpenURL(prefersInApp: true)
										} else {
											Link("ordbokene.no", destination: sourceURL)
												.font(.body)
												.fontWeight(.semibold)
												.padding(.trailing, 16)
												.padding(.bottom, 14)
										}
									}
								}
								.padding(.horizontal, 15)
								.padding(.top, 20)
							}
						} else if self.isNetworkError {
							self.centeredUnavailableContent(minHeight: geometry.size.height) {
								ContentUnavailableView(
									"No internet connection",
									systemImage: "wifi.slash",
									description: Text("We couldn't load the definition right now. Check your connection and try again.")
								)
							}
						} else {
							self.centeredUnavailableContent(minHeight: geometry.size.height) {
								ContentUnavailableView {
									Label("No definition found", systemImage: "book.closed")
								} description: {
									Text("We couldn't find a definition for this word. It might be a name or a place name.")
								} actions: {
									NavigationLink(destination: NAOBView(word: self.word)) {
										Text("Search on NAOB")
											.foregroundStyle(.blue)
											.font(.headline)
									}
									.simultaneousGesture(TapGesture().onEnded {
										self.didTap.toggle()
									})
									.conditionalHaptic(.impact, trigger: self.didTap)
								}
							}
						}
					}
					.refreshable {
						definitionManager.getNorwegianDefinition(for: self.word) { result in
							self.apply(result)
						}
					}
					.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : 75) : 0)
				}
			} else {
				DefinitionLoadingView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.navigationTitle("Definition")
		.darkGradientBackground(colorScheme: colorScheme)
		.onAppear {
			guard initialDefinitions == nil else { return }
			definitionManager.getNorwegianDefinition(for: self.word) { result in
				self.apply(result)
				AnalyticsManager.shared.logDidViewWordDefinitionEvent(word: self.word, language: .norwegian, numberOfLetters: self.word.count, viewSuccess: !self.processedWords.isEmpty)
			}
		}
	}
	
	private var sourceURL: URL? {
		let encodedWord = self.word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self.word
		return URL(string: "https://ordbokene.no/nob/bm,nn/\(encodedWord)")
	}
	
	private func centeredUnavailableContent<Content: View>(
		minHeight: CGFloat,
		@ViewBuilder content: () -> Content
	) -> some View {
		VStack {
			Spacer(minLength: 0)
			content()
			Spacer(minLength: 0)
		}
		.frame(maxWidth: .infinity, minHeight: minHeight)
	}
	
	private var isNetworkError: Bool {
		if case .networkError = self.fetchResult {
			return true
		}
		return false
	}
	
	private func apply(_ result: DefinitionFetchResult<[NorwegianDefinition]>) {
		self.fetchResult = result
		self.isLoading = false
		
		switch result {
			case .success(let processedWords):
				self.processedWords = processedWords
				print("ProcessedWord: \(String(describing: self.processedWords))")
				dump(self.processedWords)
			case .notFound, .networkError:
				self.processedWords = []
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

private struct NorwegianDefinitionTreeView: View {
	let definition: ProcessedDefinition
	let level: Int
	let index: Int

	var body: some View {
		VStack(alignment: .leading, spacing: 14) {
			self.definitionText
			self.examples

			ForEach(Array(self.definition.nestedDefinitions.enumerated()), id: \.element.id) { childIndex, nestedDefinition in
				NorwegianDefinitionTreeView(definition: nestedDefinition, level: self.level + 1, index: childIndex + 1)
			}

			ForEach(self.definition.subArticles) { subArticle in
				VStack(alignment: .leading, spacing: 10) {
					Text("FIXED EXPRESSIONS")
						.font(.headline)
					Text(subArticle.title.lowercased(with: Locale(identifier: "nb")))
						.font(.headline)
					ForEach(Array(subArticle.definitions.enumerated()), id: \.element.id) { subIndex, subDefinition in
						NorwegianDefinitionTreeView(definition: subDefinition, level: 0, index: subIndex + 1)
					}
				}
				.padding(.top, 12)
			}
		}
		.padding(.bottom, self.level == 0 ? 6 : 2)
		.padding(.leading, self.level > 1 ? 36 : 0)
	}

	@ViewBuilder
	private var definitionText: some View {
		if !self.definition.explanations.isEmpty {
			HStack(alignment: .firstTextBaseline, spacing: 12) {
				if self.showsNumber {
					Text("\(self.index).")
						.bold()
						.frame(minWidth: 24, alignment: .trailing)
				} else if self.level > 1 {
					Text("•")
						.frame(minWidth: 24, alignment: .trailing)
				}

				Text(self.definition.explanations.joined(separator: ";\n"))
					.fixedSize(horizontal: false, vertical: true)
			}
			.foregroundStyle(.secondary)
		}
	}

	@ViewBuilder
	private var examples: some View {
		let allExamples = self.definition.examples + self.definition.quotes.map {
			ProcessedExample(text: $0, explanation: "")
		}
		if !allExamples.isEmpty {
			VStack(alignment: .leading, spacing: 8) {
				if self.level < 2 {
					Text("Example")
						.font(.headline)
				}
				ForEach(allExamples) { example in
					Text(self.exampleText(example))
						.italic()
						.foregroundStyle(.secondary)
						.fixedSize(horizontal: false, vertical: true)
				}
			}
			.padding(.leading, self.showsNumber || self.level > 1 ? 36 : 0)
		}
	}

	private var showsNumber: Bool {
		self.level == 1 || (self.level == 0 && self.definition.nestedDefinitions.isEmpty)
	}

	private func exampleText(_ example: ProcessedExample) -> String {
		guard !example.explanation.isEmpty else { return example.text }
		return "\(example.text) – \(example.explanation)"
	}
}


#Preview {
	NorwegianWordDefinitionView(word: "Sessing")
		.environmentObject(DefinitionManager())
}
