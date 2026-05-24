//
//  FilterView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 20/06/2025.
//

import SwiftUI

struct FilterView: View {
    @Binding var numberOfLetters: Int
    @Binding var selectedLanguage: LanguageSelection
    @Binding var gameMode: GameMode
    @Binding var showsWhenHintsUsed: ShowsWhenHintsUsed
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10) {
                Picker("", selection: $numberOfLetters) {
					ForEach(1...9, id: \.self) { number in
						if number == 1 {
							Text(String(format: NSLocalizedString("%lld letter", comment: "Number of letters singular"), number))
								.font(.title2).bold()
						} else if number != 9 {
							Text(String(format: NSLocalizedString("%lld letters", comment: "Number of letters plural"), number))
								.font(.title2).bold()
						} else {
							Text("Any length")
								.font(.title2).bold()
						}
					}
				}
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
					}
                }
                .conditionalHaptic(.selection, trigger: self.numberOfLetters)
                .modifier(ConditionalGlassEffect())
                
                Picker("", selection: $selectedLanguage) {
                    ForEach(LanguageSelection.allCases) { language in
                        Text(language.localizedName)
                    }
                }
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                    }
                }
                .conditionalHaptic(.selection, trigger: selectedLanguage)
                .modifier(ConditionalGlassEffect())
                
                Picker("", selection: $gameMode) {
                    ForEach(GameMode.allCases) { mode in
                        Text(mode.localizedName)
                    }
                }
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                    }
                }
                .conditionalHaptic(.selection, trigger: gameMode)
                .modifier(ConditionalGlassEffect())
	                
	                Picker("", selection: $showsWhenHintsUsed) {
	                    ForEach(ShowsWhenHintsUsed.allCases) { mode in
							Text(mode.localizedName)
	                    }
	                }
                .pickerStyle(.menu)
                .foregroundStyle(.primary)
                .accentColor(.primary)
                .background {
                    if #unavailable(iOS 26.0, ) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                    }
                }
                .conditionalHaptic(.selection, trigger: showsWhenHintsUsed)
                .modifier(ConditionalGlassEffect())
            }
            .padding(.leading)
			.padding(.bottom, 5)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    FilterView(numberOfLetters: .constant(9), selectedLanguage: .constant(.all), gameMode: .constant(.both), showsWhenHintsUsed: .constant(.both))
}
