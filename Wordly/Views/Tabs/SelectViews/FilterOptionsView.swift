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

private enum ActiveFilterOptionsMenu: Equatable {
	case includedLetters
	case excludedLetters
}

struct FilterOptionsView: View {
	@Environment(AppManager.self) private var appManager
	@Environment(AdManager.self) private var adManager
	@Environment(StoreManager.self) private var storeManager
	@FocusState var focusedField: FilterOptionsFields?
	@State private var didTapGameClues: Bool = false
	@State private var didTapReset: Bool = false
	@State private var showProAlert: Bool = false
	@State private var activeMenu: ActiveFilterOptionsMenu?
	@State private var isLiquidGlassInteractionDisabled: Bool = false
	@Binding var isShowingFilterOptions: Bool
	
	
	
	var body: some View {
		@Bindable var appManager = appManager
		
		NavigationStack {
			ZStack {
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
						.disabled(activeMenu != nil)
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
							.modifier(ConditionalGlassEffect(isInteractive: !isLiquidGlassInteractionDisabled))
					}
					.wordlrListSectionRowBackground(.first)
					
					VStack {
					Toggle(isOn: $appManager.isFilteringStartWith) {
						Text("Starts with")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Enter starting letters", text: $appManager.startsWithFilter)
						.textFieldStyle(WordlrTextFieldStyle())
						.autocorrectionDisabled()
						.disabled(activeMenu != nil)
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
							.modifier(ConditionalGlassEffect(isInteractive: !isLiquidGlassInteractionDisabled))
					}
					.wordlrListSectionRowBackground(.middle)
					
					VStack {
					Toggle(isOn: $appManager.isFilteringEndsWith) {
						Text("Ends with")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Enter ending letters", text: $appManager.endsWithFilter)
						.textFieldStyle(WordlrTextFieldStyle())
						.autocorrectionDisabled()
						.disabled(activeMenu != nil)
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
							.modifier(ConditionalGlassEffect(isInteractive: !isLiquidGlassInteractionDisabled))
					}
					.wordlrListSectionRowBackground(.middle)
					
					VStack {
					Toggle(isOn: $appManager.isFilteringIncludedLetters) {
						Text("Included letters")
							.font(.headline)
					}
					.tint(.green)
					
					HStack {
						Spacer()
						
							Button {
								activeMenu = .includedLetters
								focusedField = nil
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
							.modifier(ConditionalGlassEffect(isInteractive: !isLiquidGlassInteractionDisabled))
								
							}
							.buttonStyle(.plain)
							.accentColor(.primary)
							.popover(
								isPresented: Binding(
									get: { activeMenu == .includedLetters },
									set: { isPresented in
										if !isPresented {
											activeMenu = nil
										}
									}
								),
								attachmentAnchor: .rect(.bounds),
								arrowEdge: .bottom
							) {
								LetterFilterPopover(
									letters: appManager.selectedLanguage.alphabet,
									selectedLetters: $appManager.selectedIncludedLetters
								)
								.presentationCompactAdaptation(.popover)
							}
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
					.wordlrListSectionRowBackground(.middle)
					
					
					VStack {
					Toggle(isOn: $appManager.isFilteringExcludeLetters) {
						Text("Exclude letters")
							.font(.headline)
					}
					.tint(.green)
					
					HStack {
						Spacer()
						
							Button {
								activeMenu = .excludedLetters
								focusedField = nil
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
								.modifier(ConditionalGlassEffect(isInteractive: !isLiquidGlassInteractionDisabled))
							}
							.buttonStyle(.plain)
							.accentColor(.primary)
							.popover(
								isPresented: Binding(
									get: { activeMenu == .excludedLetters },
									set: { isPresented in
										if !isPresented {
											activeMenu = nil
										}
									}
								),
								attachmentAnchor: .rect(.bounds),
								arrowEdge: .bottom
							) {
								LetterFilterPopover(
									letters: appManager.selectedLanguage.alphabet,
									selectedLetters: $appManager.selectedExcludedLetters
								)
								.presentationCompactAdaptation(.popover)
							}
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
					.wordlrListSectionRowBackground(.middle)
					
					Button {
					self.didTapGameClues.toggle()
					if storeManager.isAdRemovalPurchased {
						appManager.applyGameInfoToFilters()
					} else {
						showProAlert = true
					}
				} label: {
					HStack {
						Spacer()

//						Image(systemName: "sparkles")
//							.font(.headline)
//							.foregroundStyle(.green)

						Text("Get from game")
							.font(.headline)
							.foregroundStyle(.green)
							.frame(alignment: .center)
							.padding(.leading, storeManager.isAdRemovalPurchased ? 0 : 30)

						if !storeManager.isAdRemovalPurchased {
							Image(systemName: "crown.fill")
								.font(.caption.weight(.bold))
								.foregroundStyle(.white)
								.padding(6)
								.background(.green, in: Circle())
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
								appManager.applyGameInfoToFilters()
							} else {
								showProAlert = true
							}
						}
				)
				.conditionalHaptic(.selection, trigger: self.didTapGameClues)
					.alignmentGuide(.listRowSeparatorLeading) { d in
						d[.leading]
					}
					.wordlrListSectionRowBackground(.middle)

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
					.conditionalHaptic(.impact(weight: .medium), trigger: self.didTapReset)
					.padding(.vertical, 5)
					.wordlrListSectionRowBackground(.last)
				}
				.allowsHitTesting(activeMenu == nil)
				if activeMenu != nil {
					Color.clear
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.contentShape(Rectangle())
						.onTapGesture {
							activeMenu = nil
						}
						.accessibilityHidden(true)
				}
			}
			.padding(.top, -20)
			.simultaneousGesture(
				TapGesture()
					.onEnded { _ in
						focusedField = nil
					}
			)
			.onChange(of: activeMenu) {
				if activeMenu != nil {
					DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
						isLiquidGlassInteractionDisabled = true
					}
				} else {
					isLiquidGlassInteractionDisabled = false
				}
			}
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
						.conditionalHaptic(.selection, trigger: self.didTapGameClues)
					}
					
				} else {
					ToolbarItem(placement: .cancellationAction) {
						Button("Back", role: .cancel) {
							self.didTapGameClues.toggle()
							DispatchQueue.main.async {
								self.isShowingFilterOptions = false
							}
						}
						.conditionalHaptic(.selection, trigger: self.didTapGameClues)
					}
				}
			}
		}
		.alert("Pro Feature", isPresented: $showProAlert) {
			Button("Go to Settings") {
				self.isShowingFilterOptions = false
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					AppState.shared.navigateToSettingsTrigger = true
				}
			}
			Button("OK", role: .cancel) {}
		} message: {
			Text("Game clues automatically fills in filter options based on your current game progress. Upgrade to Pro in Settings to unlock this feature.")
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

private struct LetterFilterPopover: View {
	let letters: [String]
	@Binding var selectedLetters: [String]
	private let columns = Array(repeating: GridItem(.fixed(42), spacing: 8), count: 6)

	var body: some View {
		LazyVGrid(columns: columns, spacing: 8) {
				ForEach(letters, id: \.self) { letter in
					let isSelected = selectedLetters.contains(letter)

					Button {
						withAnimation(.smooth(duration: 0.18)) {
							if isSelected {
								selectedLetters.removeAll { $0 == letter }
							} else {
								selectedLetters.append(letter)
							}
						}
					} label: {
						ZStack(alignment: .topTrailing) {
							Text(letter)
								.font(.title3.weight(.medium))
								.foregroundStyle(.primary)
								.frame(width: 42, height: 42)
								.background {
									RoundedRectangle(cornerRadius: 16)
										.fill(isSelected ? Color.green.opacity(0.16) : Color.clear)
								}

							Image(systemName: "checkmark.circle.fill")
								.font(.caption)
								.foregroundStyle(.green)
								.background(.background, in: Circle())
								.opacity(isSelected ? 1 : 0)
								.scaleEffect(isSelected ? 1 : 0.65)
								.offset(x: 4, y: -4)
						}
						.contentShape(RoundedRectangle(cornerRadius: 8))
					}
					.buttonStyle(.plain)
				}
		}
		.padding(12)
		.frame(width: 308)
		.transaction { transaction in
			transaction.animation = .smooth(duration: 0.18)
		}
	}
}

//#Preview {
//    FilterOptionsView()
//        .environmentObject(AppManager())
//}
