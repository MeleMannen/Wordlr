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
    @EnvironmentObject var appManager: AppManager
	@Environment(AdManager.self) private var adManager: AdManager
    @FocusState var focusedField: FilterOptionsFields?
	@AppStorage("userWantsAds") var userWantsAds: Bool = true
	@State private var didTap: Bool = false
	@Binding var isShowingFilterOptions: Bool
    
    
    
    var body: some View {
		NavigationStack {
			List {
				VStack {
					Toggle(isOn: $appManager.isFilteringSearchWord) {
						Text("Search")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Search for a Word", text: $appManager.searchedWord)
						.textFieldStyle(ThePhraseTextFieldStyle())
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
						Text("Starts With")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Enter Starting Letters", text: $appManager.startsWithFilter)
						.textFieldStyle(ThePhraseTextFieldStyle())
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
						Text("Ends With")
							.font(.headline)
					}
					.tint(.green)
					
					TextField("Enter Ending Letters", text: $appManager.endsWithFilter)
						.textFieldStyle(ThePhraseTextFieldStyle())
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
						Text("Included Letters")
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
						Text("Exclude Letters")
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
				
				VStack {
					HStack {
						Spacer()
						Button {
							print("Resetting Filters")
							appManager.resetFilters()
							
						} label: {
							Text("Reset Filter")
								.font(.headline)
								.foregroundStyle(.red)
						}
						.simultaneousGesture(
							TapGesture()
								.onEnded { _ in
									appManager.resetFilters()
								}
						)
						Spacer()
					}
					.padding(.vertical, 5)
				}
			}
			        .padding(.top, -20)
			.simultaneousGesture(
				TapGesture()
					.onEnded { _ in
						focusedField = nil
					}
			)
			.navigationTitle("Filter Options")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				if #available(iOS 26.0, *) {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel", systemImage: "xmark") {
							self.isShowingFilterOptions = false
						}
						.sensoryFeedback(.selection, trigger: self.didTap)
					}
					
				} else {
					ToolbarItem(placement: .cancellationAction) {
						Button("Back", role: .cancel) {
							self.isShowingFilterOptions = false
						}
						.sensoryFeedback(.selection, trigger: self.didTap)
//						.tint(.red)
					}
				}
			}
		}
//        .scrollDisabled(true)
//		.safeAreaPadding(.bottom, (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac) && self.userWantsAds ? 80 : (self.userWantsAds ? 54 : 0))
//		.onAppear {
//			adManager.currentSelectView = .filterOptionsView
//			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//				adManager.shouldShowAds = true
//			}
//		}
//        .onDisappear {
//            withAnimation {
//                DispatchQueue.main.async {
//                    self.focusedField = nil
//                }
//            }
//        }
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

struct ThePhraseTextFieldStyle: TextFieldStyle {
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
