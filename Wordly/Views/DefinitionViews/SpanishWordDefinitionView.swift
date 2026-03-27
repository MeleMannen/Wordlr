//
//  SpanishWordDefinitionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 14/08/2025.
//

import SwiftUI

struct SpanishWordDefinitionView: View {
	@Environment(AdManager.self) private var adManager: AdManager
	@EnvironmentObject private var definitionManager: DefinitionManager
	@State var spanishDefinition: SpanishDefinition?
	@State var word: String = ""
	@State var isLoading: Bool = true
	@State private var fetchResult: DefinitionFetchResult<SpanishDefinition>?
	
	var body: some View {
		VStack {
			if !self.isLoading {
				GeometryReader { geometry in
					ScrollView {
						if let spanishDefinition = self.spanishDefinition {
							ForEach(spanishDefinition.entries) { entry in
								VStack {
									VStack(alignment: .leading) {
										Text(self.word.uppercased())
											.font(.largeTitle)
											.bold()
										
										HStack {
											Text("\(entry.partOfSpeech.uppercased())  ")
												.font(.subheadline)
											
											Spacer()
										}
										.padding(.top, 2)
										.padding(.bottom, 10)
										
										if !entry.pronunciations.isEmpty {
											VStack(alignment: .leading) {
												HStack(alignment: .top) {
													Text("PRONUNCIATION   ")
														.font(.headline)
													
													Spacer()
												}
												.padding(.bottom, 3)
												
												VStack(alignment: .leading) {
													ForEach(Array(entry.pronunciations.enumerated()), id: \.offset) { index, pronunciation in
														if !pronunciation.text.isEmpty {
															HStack(alignment: .center) {
																Text("\(index+1).")
																	.foregroundColor(.gray)
																	.bold()
																	.frame(width: 25, alignment: .leading)
																Text("  ")
																	.foregroundColor(.gray)
																Text("\(pronunciation.text)")
																	.foregroundColor(.gray)
																	.lineLimit(nil)
																	.fixedSize(horizontal: false, vertical: true)
															}
															.padding(.bottom, 5)
														}
													}
												}
											}
											.padding(.vertical, 10)
											.padding(.bottom, 10)
										}
										
										Text("EXPLANATION AND USAGE")
											.font(.headline)
											.padding(.bottom, 3)
											.bold()
										
										ForEach(Array(entry.senses.enumerated()), id: \.offset) { index, sense in
											HStack(alignment: .top) {
												Text("\(index+1).")
													.foregroundColor(.gray)
													.bold()
													.frame(width: 26, alignment: .leading)
												Text("  ")
													.foregroundColor(.gray)
												
												VStack(alignment: .leading) {
													Text("\(sense.definition)")
														.foregroundColor(.gray)
														.padding(.bottom, 10)
														.lineLimit(nil)
														.fixedSize(horizontal: false, vertical: true)
													
													if !sense.examples.isEmpty {
														VStack(alignment: .leading) {
															Text("EXAMPLE")
																.padding(.bottom, 2)
																.font(.headline)
															ForEach(sense.examples, id: \.self) { ex in
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
													
													if !sense.synonyms.isEmpty {
														VStack(alignment: .leading) {
															Text("SYNONYMS")
																.font(.headline)
																.padding(.bottom, 3)
																.bold()
															ForEach(sense.synonyms, id: \.self) { synonym in
																HStack(alignment: .top) {
																	Text("•")
																		.font(.body)
																		.italic()
																		.foregroundColor(.gray)
																	VStack(alignment: .leading) {
																		Text("\(synonym.trimmingCharacters(in: .whitespacesAndNewlines))")
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
													
													if !sense.antonyms.isEmpty {
														VStack(alignment: .leading) {
															Text("ANTONYMS")
																.font(.headline)
																.padding(.bottom, 3)
																.bold()
															ForEach(sense.antonyms, id: \.self) { antonym in
																HStack(alignment: .top) {
																	Text("•")
																		.font(.body)
																		.italic()
																		.foregroundColor(.gray)
																	VStack(alignment: .leading) {
																		Text("\(antonym.trimmingCharacters(in: .whitespacesAndNewlines))")
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
									}
									.padding(25)
								}
								.background {
									RoundedRectangle(cornerRadius: 20)
										.foregroundStyle(Color(uiColor: .secondarySystemBackground))
								}
								.overlay(alignment: .bottomTrailing) {
									if let sourceURL = URL(string: spanishDefinition.source.url) {
										if #available(iOS 26.0, *) {
											Link(sourceURL.host() ?? "wiktionary.org", destination: sourceURL)
												.font(.body)
												.fontWeight(.semibold)
												.lineLimit(nil)
												.fixedSize(horizontal: false, vertical: true)
												.padding(.trailing, 16)
												.padding(.bottom, 14)
												.onOpenURL(prefersInApp: true)
										} else {
											Link(sourceURL.host() ?? "wiktionary.org", destination: sourceURL)
												.font(.body)
												.fontWeight(.semibold)
												.lineLimit(nil)
												.fixedSize(horizontal: false, vertical: true)
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
									"No Internet Connection",
									systemImage: "wifi.slash",
									description: Text("We couldn't load the definition right now. Check your connection and try again.")
								)
							}
						} else {
							self.centeredUnavailableContent(minHeight: geometry.size.height) {
								ContentUnavailableView(
									"No Definition Found",
									systemImage: "book.closed",
									description: Text("We couldn't find a definition for this word. It might be a name or a place name.")
								)
							}
						}
					}
					.refreshable {
						definitionManager.getSpanishDefinition(for: self.word) { result in
							self.apply(result)
						}
					}
					.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
				}
			} else {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle())
					.font(.largeTitle)
			}
		}
		.navigationTitle("\(self.word)")
		.onAppear {
			definitionManager.getSpanishDefinition(for: self.word) { result in
				self.apply(result)
				if let spanishDefinition = self.spanishDefinition {
					AnalyticsManager.shared.logDidViewWordDefinitionEvent(word: self.word, language: .spanish, numberOfLetters: self.word.count, viewSuccess: !spanishDefinition.entries.isEmpty)
				} else {
					AnalyticsManager.shared.logDidViewWordDefinitionEvent(word: self.word, language: .spanish, numberOfLetters: self.word.count, viewSuccess: false)
				}
			}
		}
	}
	
	private var wordForms: [Form] {
		guard let forms = self.spanishDefinition?.entries.first?.forms else {
			return []
		}
		return forms.filter { form in
			!form.tags.contains("table-tags") && !form.tags.contains("inflection-template") && !form.tags.contains("class") && !form.tags.contains("combined-form")
		}.sorted { $0.word < $1.word }
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
	
	private func apply(_ result: DefinitionFetchResult<SpanishDefinition>) {
		self.fetchResult = result
		self.isLoading = false
		
		switch result {
			case .success(let spanishDefinition):
				self.spanishDefinition = spanishDefinition
				print("SpanishDefinition: \(String(describing: self.spanishDefinition))")
				dump(self.spanishDefinition)
			case .notFound, .networkError:
				self.spanishDefinition = nil
		}
	}
}

#Preview {
	SpanishWordDefinitionView(word: "World")
		.environmentObject(DefinitionManager())
}
