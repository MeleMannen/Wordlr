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
		} else if self.language == .french || self.language == .polish {
			FreeDictionaryWordDefinitionView(word: self.word, language: self.language)
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

struct FreeDictionaryWordDefinitionView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(AdManager.self) private var adManager
	@EnvironmentObject private var definitionManager: DefinitionManager
	@State var word: String = ""
	@State var language: LanguageSelection
	@State private var definition: FreeDictionaryDefinition?
	@State private var isLoading: Bool = true
	@State private var fetchResult: DefinitionFetchResult<FreeDictionaryDefinition>?

	var body: some View {
		VStack {
			if !self.isLoading {
				GeometryReader { geometry in
					ScrollView {
						if let definition {
							ForEach(definition.entries) { entry in
								definitionCard(entry: entry, source: definition.source)
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
								ContentUnavailableView(
									"No definition found",
									systemImage: "book.closed",
									description: Text("We couldn't find a definition for this word. It might be a name or a place name.")
								)
							}
						}
					}
					.refreshable {
						loadDefinition()
					}
					.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : 75) : 0)
				}
			} else {
				DefinitionLoadingView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.navigationTitle("\(self.word)")
		.darkGradientBackground(colorScheme: colorScheme)
		.onAppear {
			loadDefinition(shouldLogAnalytics: true)
		}
	}

	private func definitionCard(entry: Entry2, source: Source) -> some View {
		VStack {
			VStack(alignment: .leading) {
				Text(self.word.uppercased())
					.font(.largeTitle)
					.bold()

				if !entry.partOfSpeech.isEmpty {
					HStack {
						Text("\(entry.partOfSpeech.uppercased())  ")
							.font(.subheadline)
						Spacer()
					}
					.padding(.top, 2)
					.padding(.bottom, 10)
				}

				pronunciationSection(for: entry)

				Text("EXPLANATION AND USAGE")
					.font(.headline)
					.padding(.bottom, 3)
					.bold()

				ForEach(Array(entry.senses.enumerated()), id: \.offset) { index, sense in
					senseSection(sense: sense, index: index)
				}
			}
			.padding(25)
		}
		.wordlrSurface(cornerRadius: 20)
		.overlay(alignment: .bottomTrailing) {
			if let sourceURL = URL(string: source.url) {
				if #available(iOS 26.0, *) {
					Link(sourceURL.host() ?? "freedictionaryapi.com", destination: sourceURL)
						.font(.body)
						.fontWeight(.semibold)
						.lineLimit(nil)
						.fixedSize(horizontal: false, vertical: true)
						.padding(.trailing, 16)
						.padding(.bottom, 14)
						.onOpenURL(prefersInApp: true)
				} else {
					Link(sourceURL.host() ?? "freedictionaryapi.com", destination: sourceURL)
						.font(.body)
						.fontWeight(.semibold)
						.lineLimit(nil)
						.fixedSize(horizontal: false, vertical: true)
						.padding(.trailing, 16)
						.padding(.bottom, 14)
				}
			}
		}
	}

	@ViewBuilder
	private func pronunciationSection(for entry: Entry2) -> some View {
		let pronunciations = entry.pronunciations.filter { !$0.text.isEmpty }
		if !pronunciations.isEmpty {
			VStack(alignment: .leading) {
				HStack(alignment: .top) {
					Text("PRONUNCIATION   ")
						.font(.headline)
					Spacer()
				}
				.padding(.bottom, 3)

				VStack(alignment: .leading) {
					ForEach(Array(pronunciations.enumerated()), id: \.offset) { index, pronunciation in
						HStack(alignment: .center) {
							Text("\(index + 1).")
								.foregroundColor(.gray)
								.bold()
								.frame(width: 25, alignment: .leading)
							Text("  ")
								.foregroundColor(.gray)
							Text(pronunciation.text)
								.foregroundColor(.gray)
								.lineLimit(nil)
								.fixedSize(horizontal: false, vertical: true)
						}
						.padding(.bottom, 5)
					}
				}
			}
			.padding(.vertical, 10)
			.padding(.bottom, 10)
		}
	}

	private func senseSection(sense: Sense, index: Int) -> some View {
		HStack(alignment: .top) {
			Text("\(index + 1).")
				.foregroundColor(.gray)
				.bold()
				.frame(width: 26, alignment: .leading)
			Text("  ")
				.foregroundColor(.gray)

			VStack(alignment: .leading) {
				Text(sense.definition)
					.foregroundColor(.gray)
					.padding(.bottom, 10)
					.lineLimit(nil)
					.fixedSize(horizontal: false, vertical: true)

				wordListSection(title: "EXAMPLE", words: sense.examples)
				wordListSection(title: "SYNONYMS", words: sense.synonyms)
				wordListSection(title: "ANTONYMS", words: sense.antonyms)
			}
		}
		.padding(.bottom, 10)
		.padding(.leading, 2)
	}

	@ViewBuilder
	private func wordListSection(title: LocalizedStringKey, words: [String]) -> some View {
		if !words.isEmpty {
			VStack(alignment: .leading) {
				Text(title)
					.padding(.bottom, 2)
					.font(.headline)
				ForEach(words, id: \.self) { word in
					HStack(alignment: .top) {
						Text("•")
							.font(.body)
							.italic()
							.foregroundColor(.gray)
						VStack(alignment: .leading) {
							Text(word.trimmingCharacters(in: .whitespacesAndNewlines))
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

	private func loadDefinition(shouldLogAnalytics: Bool = false) {
		definitionManager.getFreeDictionaryDefinition(for: self.word, language: self.language) { result in
			self.apply(result)
			if shouldLogAnalytics {
				AnalyticsManager.shared.logDidViewWordDefinitionEvent(word: self.word, language: self.language, numberOfLetters: self.word.count, viewSuccess: self.definition?.entries.isEmpty == false)
			}
		}
	}

	private func apply(_ result: DefinitionFetchResult<FreeDictionaryDefinition>) {
		self.fetchResult = result
		self.isLoading = false

		switch result {
			case .success(let definition):
				self.definition = definition
			case .notFound, .networkError:
				self.definition = nil
		}
	}
}
