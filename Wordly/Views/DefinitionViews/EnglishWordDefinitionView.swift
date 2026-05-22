//
//  EnglishWordDefinitionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 09/06/2025.
//

import SwiftUI
import AVFoundation

struct EnglishWordDefinitionView: View {
	@Environment(AdManager.self) private var adManager
	@EnvironmentObject private var definitionManager: DefinitionManager
	@State var englishDefinition: [EnglishDefinition] = []
	@State var word: String = ""
	@State var isLoading: Bool = true
	@State private var fetchResult: DefinitionFetchResult<[EnglishDefinition]>?
	
	var body: some View {
		VStack {
			if !self.isLoading {
				GeometryReader { geometry in
					ScrollView {
						if !self.englishDefinition.isEmpty {
							ForEach(self.englishDefinition) { definition in
								VStack {
									VStack(alignment: .leading) {
										Text(self.word.uppercased())
											.font(.largeTitle)
											.bold()
										
										self.pronunciationSection(for: definition)
										
										ForEach(Array(definition.meanings.enumerated()), id: \.offset) { index, meaning in
											self.meaningSection(for: meaning)
											
											if index < definition.meanings.count - 1 {
												Divider()
													.padding(.vertical, 8)
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
									if let sourceURL = self.sourceURL(for: definition) {
										if #available(iOS 26.0, *) {
											Link(self.sourceLabel(for: definition), destination: sourceURL)
												.font(.body)
												.fontWeight(.semibold)
												.padding(.trailing, 16)
												.padding(.bottom, 14)
												.onOpenURL(prefersInApp: true)
										} else {
											Link(self.sourceLabel(for: definition), destination: sourceURL)
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
								ContentUnavailableView(
									"No definition found",
									systemImage: "book.closed",
									description: Text("We couldn't find a definition for this word. It might be a name or a place name.")
								)
							}
						}
					}
					.refreshable {
						definitionManager.getEnglishDefinition(for: self.word) { result in
							self.apply(result)
						}
					}
					.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : 75) : 0)
				}
			} else {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle())
					.font(.largeTitle)
			}
		}
		.navigationTitle("\(self.word)")
		.onAppear {
			definitionManager.getEnglishDefinition(for: self.word) { result in
				self.apply(result)
				AnalyticsManager.shared.logDidViewWordDefinitionEvent(word: self.word, language: .english, numberOfLetters: self.word.count, viewSuccess: !self.englishDefinition.isEmpty)
			}
		}
	}
	
	@ViewBuilder
	private func pronunciationSection(for definition: EnglishDefinition) -> some View {
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
	}
	
	private func meaningSection(for meaning: Meaning) -> some View {
		VStack(alignment: .leading) {
			HStack {
				Text("\(meaning.partOfSpeech.uppercased())  ")
					.font(.subheadline)
				
				Spacer()
			}
			.padding(.top, 2)
			.padding(.bottom, 10)
			
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
	}
	
	private func sourceURL(for definition: EnglishDefinition) -> URL? {
		if let source = definition.sourceUrls.first, let url = URL(string: source) {
			return url
		}
		
		return URL(string: definition.license.url)
	}
	
	private func sourceLabel(for definition: EnglishDefinition) -> String {
		self.sourceURL(for: definition)?.host() ?? definition.license.name
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
	
	private func apply(_ result: DefinitionFetchResult<[EnglishDefinition]>) {
		self.fetchResult = result
		self.isLoading = false
		
		switch result {
			case .success(let englishDefinition):
				self.englishDefinition = englishDefinition
				print("EnglishDefinition: \(String(describing: self.englishDefinition))")
				dump(self.englishDefinition)
			case .notFound, .networkError:
				self.englishDefinition = []
		}
	}
}

#Preview {
	EnglishWordDefinitionView(word: "World")
		.environmentObject(DefinitionManager())
}
