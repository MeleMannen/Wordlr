//
//  Untitled.swift
//  Wordle
//
//  Created by Kristoffer Melen on 08/06/2025.
//

import SwiftUI

enum FilterOptionsFields: Hashable {
	case search
	case startsWith
	case endsWith
}

struct FilterOptionsView: View {
	@Environment(AppManager.self) private var appManager
	@Environment(AdManager.self) private var adManager
	@Environment(StoreManager.self) private var storeManager
	@FocusState var focusedField: FilterOptionsFields?
	@State private var didTapGameClues: Bool = false
	@State private var didTapReset: Bool = false
	@State private var showProAlert: Bool = false
	@Binding var isShowingFilterOptions: Bool
	
	
	
	var body: some View {
		@Bindable var appManager = appManager
		
		NavigationStack {
			List {
				VStack {
					Toggle(isOn: $appManager.isFilteringSearchWord) {
						Text("Search")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Search for a word", text: $appManager.searchedWord)
						.textFieldStyle(WordlrTextFieldStyle())
						.autocorrectionDisabled()
						.focused($focusedField, equals: .search)
						.simultaneousGesture(
							TapGesture()
								.onEnded { _ in
									self.focusedField = .search
								}
						)
						.onSubmit {
							self.focusNextField()
						}
						.onChange(of: appManager.searchedWord) { oldValue, newValue in
							if newValue.count > 0 && !appManager.isFilteringSearchWord {
								appManager.isFilteringSearchWord = true
							}
						}
						.modifier(ConditionalGlassEffect())
				}
				
				VStack {
					Toggle(isOn: $appManager.isFilteringStartWith) {
						Text("Starts with")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Enter starting letters", text: $appManager.startsWithFilter)
						.textFieldStyle(WordlrTextFieldStyle())
						.autocorrectionDisabled()
						.focused($focusedField, equals: .startsWith)
						.simultaneousGesture(
							TapGesture()
								.onEnded { _ in
									self.focusedField = .startsWith
								}
						)
						.onSubmit {
							self.focusNextField()
						}
						.onChange(of: appManager.startsWithFilter) { oldValue, newValue in
							if newValue.count == 0 {
								appManager.isFilteringStartWith = false
							} else {
								appManager.isFilteringStartWith = true
							}
						}
						.modifier(ConditionalGlassEffect())
				}
				
				VStack {
					Toggle(isOn: $appManager.isFilteringEndsWith) {
						Text("Ends with")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Enter ending letters", text: $appManager.endsWithFilter)
						.textFieldStyle(WordlrTextFieldStyle())
						.autocorrectionDisabled()
						.focused($focusedField, equals: .endsWith)
						.simultaneousGesture(
							TapGesture()
								.onEnded { _ in
									self.focusedField = .endsWith
								}
						)
						.onSubmit {
							self.focusNextField()
						}
						.onChange(of: appManager.endsWithFilter) { oldValue, newValue in
							if newValue.count == 0 {
								appManager.isFilteringEndsWith = false
							} else {
								appManager.isFilteringEndsWith = true
							}
						}
						.modifier(ConditionalGlassEffect())
				}
				
				VStack {
					Toggle(isOn: $appManager.isFilteringIncludedLetters) {
						Text("Included letters")
							.font(.headline)
					}
					.tint(.green)
					
					HStack {
						Spacer()
						
						Menu {
							ForEach(appManager.selectedLanguage.alphabet, id: \.self) { letter in
								Toggle(
									isOn: Binding(
										get: { appManager.selectedIncludedLetters.contains(letter) },
										set: { isSelected in
											if isSelected {
												appManager.selectedIncludedLetters.append(letter)
											} else {
												appManager.selectedIncludedLetters.removeAll { $0 == letter }
											}
										}
									)
								) {
									Text(letter)
										.font(.title3)
								}
							}
						} label: {
							HStack {
								let includedLettersText = NSLocalizedString("Included letters", comment: "Label for included letters in filter options")
								Text(appManager.selectedIncludedLetters.isEmpty ? includedLettersText : appManager.selectedIncludedLetters.joined(separator: ", "))
									.font(.callout)
									.padding([.vertical, .leading], 5)
								
								Image(systemName: "chevron.up.chevron.down")
									.padding([.vertical, .trailing], 5)
							}
							.padding(5)
							.frame(alignment: .center)
							.modifier(ConditionalGlassEffect())
							
						}
						.accentColor(.primary)
						.menuActionDismissBehavior(.disabled)
						.background {
							if #unavailable(iOS 26.0, ) {
								RoundedRectangle(cornerRadius: 10)
									.foregroundStyle(Color(uiColor: .tertiarySystemBackground))
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
							}
							
						}
						.onChange(of: appManager.selectedIncludedLetters) { oldValue, newValue in
							if newValue.count == 0 {
								appManager.isFilteringIncludedLetters = false
							} else {
								appManager.selectedIncludedLetters = appManager.selectedIncludedLetters.sorted(by: {
									$0.caseInsensitiveCompare($1) == .orderedAscending
								})
								appManager.isFilteringIncludedLetters = true
							}
						}
						.padding(.vertical, 5)
					}
				}
				
				
				VStack {
					Toggle(isOn: $appManager.isFilteringExcludeLetters) {
						Text("Exclude letters")
							.font(.headline)
					}
					.tint(.green)
					
					HStack {
						Spacer()
						
						Menu {
							ForEach(appManager.selectedLanguage.alphabet, id: \.self) { letter in
								Toggle(
									isOn: Binding(
										get: { appManager.selectedExcludedLetters.contains(letter) },
										set: { isSelected in
											if isSelected {
												appManager.selectedExcludedLetters.append(letter)
											} else {
												appManager.selectedExcludedLetters.removeAll { $0 == letter }
											}
										}
									)
								) {
									Text(letter)
										.font(.title3)
								}
							}
						} label: {
							HStack {
								let excludedLettersText = NSLocalizedString("Excluded letters", comment: "Label for excluded letters in filter options")
								Text(appManager.selectedExcludedLetters.isEmpty ? excludedLettersText : appManager.selectedExcludedLetters.joined(separator: ", "))
									.font(.callout)
									.padding([.vertical, .leading], 5)
								Image(systemName: "chevron.up.chevron.down")
									.padding([.vertical, .trailing], 5)
							}
							.padding(5)
							.frame(alignment: .center)
							.modifier(ConditionalGlassEffect())
						}
						.accentColor(.primary)
						.menuActionDismissBehavior(.disabled)
						.background {
							if #unavailable(iOS 26.0, ) {
								RoundedRectangle(cornerRadius: 10)
									.foregroundStyle(Color(uiColor: .tertiarySystemBackground))
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
							}
						}
						.onChange(of: appManager.selectedExcludedLetters) { oldValue, newValue in
							if newValue.count == 0 {
								appManager.isFilteringExcludeLetters = false
							} else {
								appManager.selectedExcludedLetters.sort()
								appManager.isFilteringExcludeLetters = true
							}
						}
						.padding(.vertical, 5)
					}
				}
				
				Button {
					self.didTapGameClues.toggle()
					if storeManager.isAdRemovalPurchased {
						applyGameInfoToFilters()
					} else {
						showProAlert = true
					}
				} label: {
					HStack {
						Spacer()

						Image(systemName: "sparkles")
							.font(.headline)
							.foregroundStyle(.green)

						Text("Use game clues")
							.font(.headline)
							.foregroundStyle(.green)
							.frame(alignment: .center)

						if !storeManager.isAdRemovalPurchased {
							Text("PRO")
								.font(.caption2).bold()
								.foregroundStyle(.white)
								.padding(.horizontal, 6)
								.padding(.vertical, 2)
								.background(Capsule().fill(.green))
						}

						Spacer()
					}
					.padding(.vertical, 5)
				}
				.simultaneousGesture(
					TapGesture()
						.onEnded { _ in
							self.didTapGameClues.toggle()
							if storeManager.isAdRemovalPurchased {
								applyGameInfoToFilters()
							} else {
								showProAlert = true
							}
						}
				)
				.sensoryFeedback(.selection, trigger: self.didTapGameClues)
				.alignmentGuide(.listRowSeparatorLeading) { d in
					d[.leading]
				}

				Button {
					self.didTapReset.toggle()
					appManager.resetFilters()
				} label: {
					HStack {
						Spacer()

						Text("Reset filter")
							.font(.headline)
							.foregroundStyle(.red)

						Spacer()
					}
				}
				.simultaneousGesture(
					TapGesture()
						.onEnded { _ in
							self.didTapReset.toggle()
							appManager.resetFilters()
						}
				)
				.sensoryFeedback(.impact(weight: .medium), trigger: self.didTapReset)
				.padding(.vertical, 5)
			}
			.padding(.top, -20)
			.simultaneousGesture(
				TapGesture()
					.onEnded { _ in
						focusedField = nil
					}
			)
			.navigationTitle("Filter options")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				if #available(iOS 26.0, *) {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel", systemImage: "xmark") {
							self.didTapGameClues.toggle()
							DispatchQueue.main.async {
								self.isShowingFilterOptions = false
							}
						}
						.sensoryFeedback(.selection, trigger: self.didTapGameClues)
					}
					
				} else {
					ToolbarItem(placement: .cancellationAction) {
						Button("Back", role: .cancel) {
							self.didTapGameClues.toggle()
							DispatchQueue.main.async {
								self.isShowingFilterOptions = false
							}
						}
						.sensoryFeedback(.selection, trigger: self.didTapGameClues)
					}
				}
			}
		}
		.alert("Pro Feature", isPresented: $showProAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Upgrade to Pro in Settings to use game clues.")
		}
		.onAppear {
			AnalyticsManager.shared.logScreenViewed(screenName: "FilterOptionsView")
		}
		.onChange(of: self.focusedField) {
			if self.focusedField == nil {
				adManager.shouldShowAds = true
			} else {
				adManager.shouldShowAds = false
			}
		}
	}
	
	private func applyGameInfoToFilters() {
		var included: Set<String> = []
		var excluded: Set<String> = []

		for row in appManager.keyboard {
			for key in row {
				switch key.state {
				case .correctPosition, .correctLetter:
					included.insert(key.letter)
				case .usedButNotCorrect:
					excluded.insert(key.letter)
				case .notUsed:
					break
				}
			}
		}

		let wordLength = appManager.numberOfLetters
		var correctPositions = Array(repeating: "", count: wordLength)
		for row in appManager.board {
			for (index, letter) in row.enumerated() {
				if letter.state == .correctPosition && index < wordLength {
					correctPositions[index] = letter.letter
				}
			}
		}

		var startsWith = ""
		for letter in correctPositions {
			if !letter.isEmpty {
				startsWith += letter
			} else {
				break
			}
		}

		var endsWith = ""
		for letter in correctPositions.reversed() {
			if !letter.isEmpty {
				endsWith = letter + endsWith
			} else {
				break
			}
		}

		appManager.searchedWord = ""

		appManager.startsWithFilter = startsWith
		appManager.isFilteringStartWith = !startsWith.isEmpty

		appManager.endsWithFilter = endsWith
		appManager.isFilteringEndsWith = !endsWith.isEmpty

		appManager.selectedIncludedLetters = included.sorted()
		appManager.isFilteringIncludedLetters = !included.isEmpty

		appManager.selectedExcludedLetters = excluded.sorted()
		appManager.isFilteringExcludeLetters = !excluded.isEmpty
	}

	func focusNextField() {
		guard let currentField = focusedField else { return }
		switch currentField {
			case .search:
				focusedField = .startsWith
			case .startsWith:
				focusedField = .endsWith
			case .endsWith:
				focusedField = nil
		}
	}
}

struct WordlrTextFieldStyle: TextFieldStyle {
	func _body(configuration: TextField<Self._Label>) -> some View {
		if #available(iOS 26.0, *) {
			configuration
				.padding(10)
		} else {
			configuration
				.padding(10)
				.background(.background)
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(.primary)
				)
		}
	}
}

//#Preview {
//    FilterOptionsView()
//        .environmentObject(AppManager())
//}
