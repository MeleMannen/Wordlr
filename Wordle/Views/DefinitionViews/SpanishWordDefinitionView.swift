//
//  SpanishWordDefinitionView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 14/08/2025.
//

import SwiftUI

struct SpanishWordDefinitionView: View {
	@EnvironmentObject private var definitionManager: DefinitionManager
	@AppStorage("userWantsAds") private var userWantsAds: Bool = false
	@State var spanishDefinition: SpanishDefinition?
	@State var word: String = ""
	@State var isLoading: Bool = true
	
	var body: some View {
		VStack {
			if !self.isLoading {
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
//									VStack(alignment: .leading, spacing: 16) {
//										if !wordForms.isEmpty {
//											NavigationLink("View All Word Forms") {
//												CompactConjugationView(word: self.word, forms: wordForms)
//											}
//											.padding()
//											.background(Color.blue.opacity(0.1))
//											.cornerRadius(8)
//										}
//									}
//									.padding()
									
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
						}
						.background {
							RoundedRectangle(cornerRadius: 10)
								.fill(Color(uiColor: .quaternarySystemFill))
						}
						.overlay(alignment: .bottomTrailing) {
							Link("wiktionary.org", destination: URL(string: "\(spanishDefinition.source.url)")!)
								.foregroundColor(.blue)
								.font(.body)
								.fontWeight(.semibold)
								.lineLimit(nil)
								.fixedSize(horizontal: false, vertical: true)
								.padding(.trailing, 10)
								.padding(.bottom, 8)
						}
						.padding(.horizontal, 15)
						.padding(.top, 20)
							
					} else {
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
					definitionManager.getSpanishDefinition(for: self.word) { spanishDefinition in
						self.spanishDefinition = spanishDefinition
						print("EnglishDefinition: \(String(describing: self.spanishDefinition))")
						dump(self.spanishDefinition)
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
			definitionManager.getSpanishDefinition(for: self.word) { spanishDefinition in
				self.spanishDefinition = spanishDefinition
				self.isLoading = false
				print("SpanishDefinition: \(String(describing: self.spanishDefinition))")
				dump(self.spanishDefinition)
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
}

#Preview {
	SpanishWordDefinitionView(word: "World")
		.environmentObject(DefinitionManager())
}

//struct CompactConjugationView: View {
//	let word: String
//	let forms: [Form]
//	
//	var body: some View {
//		GeometryReader { geometry in
//			
//			ScrollView(.horizontal) {
//				VStack(spacing: 0) {
//					// Header with verb name
//					Text("Conjugation of \(self.word)")
//						.font(.headline)
//						.padding(.bottom, 8)
//					
//					// Main conjugation table
//					LazyVGrid(columns: createColumns(), spacing: 1) {
//						// Headers
//						headerCell("")
//						headerCell("first singular\nyo")
//						headerCell("second singular\ntú")
//						headerCell("third singular\nél/ella")
//						headerCell("first plural\nnosotros/nós")
//						headerCell("second plural\nvosotros/vós")
//						headerCell("third plural\nellos")
//						
//						
//						
//						// Present tense
//						sectionCell("present")
//						conjugationCell(getForm(tense: "present", person: "first", number: "singular"))
//						conjugationCell(getForm(tense: "present", person: "second", number: "singular"))
//						conjugationCell(getForm(tense: "present", person: "third", number: "singular"))
//						conjugationCell(getForm(tense: "present", person: "first", number: "plural"))
//						conjugationCell(getForm(tense: "present", person: "second", number: "plural"))
//						conjugationCell(getForm(tense: "present", person: "third", number: "plural"))
//						
//						// Imperfect tense
//						sectionCell("imperfect")
//						conjugationCell(getForm(tense: "imperfect", person: "first", number: "singular"))
//						conjugationCell(getForm(tense: "imperfect", person: "second", number: "singular"))
//						conjugationCell(getForm(tense: "imperfect", person: "third", number: "singular"))
//						conjugationCell(getForm(tense: "imperfect", person: "first", number: "plural"))
//						conjugationCell(getForm(tense: "imperfect", person: "second", number: "plural"))
//						conjugationCell(getForm(tense: "imperfect", person: "third", number: "plural"))
//						
//						// Preterite tense
//						sectionCell("preterite")
//						conjugationCell(getForm(tense: "preterite", person: "first", number: "singular"))
//						conjugationCell(getForm(tense: "preterite", person: "second", number: "singular"))
//						conjugationCell(getForm(tense: "preterite", person: "third", number: "singular"))
//						conjugationCell(getForm(tense: "preterite", person: "first", number: "plural"))
//						conjugationCell(getForm(tense: "preterite", person: "second", number: "plural"))
//						conjugationCell(getForm(tense: "preterite", person: "third", number: "plural"))
//						
//						// Future tense
//						sectionCell("future")
//						conjugationCell(getForm(tense: "future", person: "first", number: "singular"))
//						conjugationCell(getForm(tense: "future", person: "second", number: "singular"))
//						conjugationCell(getForm(tense: "future", person: "third", number: "singular"))
//						conjugationCell(getForm(tense: "future", person: "first", number: "plural"))
//						conjugationCell(getForm(tense: "future", person: "second", number: "plural"))
//						conjugationCell(getForm(tense: "future", person: "third", number: "plural"))
//						
//						// Conditional tense
//						sectionCell("conditional")
//						conjugationCell(getForm(tense: "conditional", person: "first", number: "singular"))
//						conjugationCell(getForm(tense: "conditional", person: "second", number: "singular"))
//						conjugationCell(getForm(tense: "conditional", person: "third", number: "singular"))
//						conjugationCell(getForm(tense: "conditional", person: "first", number: "plural"))
//						conjugationCell(getForm(tense: "conditional", person: "second", number: "plural"))
//						conjugationCell(getForm(tense: "conditional", person: "third", number: "plural"))
//					}
//				}
//				.padding(.horizontal, 8)
//				.frame(width: geometry.size.width*2)
//			}
//			Spacer()
//		}
////		.navigationTitle("Conjugation of \(self.word)")
//	}
//	
//	private func createColumns() -> [GridItem] {
//		Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
//	}
//	
//	private func headerCell(_ text: String) -> some View {
//		Text(text)
//			.font(.caption)
//			.fontWeight(.semibold)
//			.frame(maxWidth: .infinity, minHeight: 50)
//			.background(Color.gray.opacity(0.3))
//			.foregroundColor(.primary)
//			.multilineTextAlignment(.center)
//	}
//	
//	private func sectionCell(_ text: String) -> some View {
//		Text(text)
//			.font(.caption2)
//			.fontWeight(.medium)
//			.frame(maxWidth: .infinity, minHeight: 50)
//			.background(Color.blue.opacity(0.2))
//			.foregroundColor(.primary)
//	}
//	
//	private func conjugationCell(_ text: String) -> some View {
//		Text(text)
//			.font(.caption2)
//			.frame(maxWidth: .infinity, minHeight: 50)
//			.background(Color.gray.opacity(0.1))
//			.foregroundColor(.primary)
//	}
//	
//	private func getForm(tense: String, person: String, number: String) -> String {
//		let matchingForms = self.forms.filter { form in
//			form.tags.contains(tense) &&
//			form.tags.contains("\(person)-person") &&
//			form.tags.contains(number) &&
//			form.tags.contains("indicative")
//		}
//		return matchingForms.first?.word ?? "-"
//	}
//}

