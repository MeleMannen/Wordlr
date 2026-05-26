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
				if #available(iOS 26.0, *) {
					UIKitMenuPicker(
						selection: $numberOfLetters,
						options: Array(1...9)
					) { number in
						
						if number == 1 {
							return String(
								format: NSLocalizedString(
									"%lld letter",
									comment: "Number of letters singular"
								),
								number
							)
						} else if number != 9 {
							return String(
								format: NSLocalizedString(
									"%lld letters",
									comment: "Number of letters plural"
								),
								number
							)
						} else {
							return NSLocalizedString(
								"Any length",
								comment: ""
							)
						}
					}
					.conditionalHaptic(.selection, trigger: self.numberOfLetters)
					.frame(height: 36)
				} else {
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
				}
				
				if #available(iOS 26.0, *) {
					UIKitMenuPicker(
						selection: $selectedLanguage,
						options: LanguageSelection.allCases,
						title: { $0.localizedName }
					)
					.frame(height: 36)
					.conditionalHaptic(.selection, trigger: self.selectedLanguage)
				} else {
					
					Picker("", selection: $selectedLanguage) {
						ForEach(LanguageSelection.allCases) { language in
							Text(language.localizedName)
						}
					}
					.pickerStyle(.menu)
					.foregroundStyle(.primary)
					.accentColor(.primary)
					.background {
//						if #unavailable(iOS 26.0, ) {
							RoundedRectangle(cornerRadius: 10)
								.foregroundStyle(Color(uiColor: .tertiarySystemBackground))
//						}
					}
					.conditionalHaptic(.selection, trigger: self.selectedLanguage)
					.modifier(ConditionalGlassEffect())
				}
				
				if #available(iOS 26.0, *) {
					UIKitMenuPicker(
						selection: $gameMode,
						options: GameMode.allCases,
						title: { $0.localizedName }
					)
					.frame(height: 36)
					.conditionalHaptic(.selection, trigger: self.gameMode)
				} else {
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
					.conditionalHaptic(.selection, trigger: self.gameMode)
					.modifier(ConditionalGlassEffect())
					
				}
				if #available(iOS 26.0, *) {
					UIKitMenuPicker(
						selection: $showsWhenHintsUsed,
						options: ShowsWhenHintsUsed.allCases,
						title: { $0.localizedName }
					)
					.frame(height: 36)
					.conditionalHaptic(.selection, trigger: self.showsWhenHintsUsed)
				} else {
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
					.conditionalHaptic(.selection, trigger: self.showsWhenHintsUsed)
					.modifier(ConditionalGlassEffect())
				}
            }
            .padding(.leading)
			.padding(.bottom, 5)
        }
        .scrollIndicators(.hidden)
    }
}

@available(iOS 26.0, *)
struct UIKitMenuPicker<T>: UIViewRepresentable
where T: Hashable {
	
	@Binding var selection: T
	
	let options: [T]
	let title: (T) -> String
	
	var useGlassButton: Bool = true
	
	func makeUIView(context: Context) -> UIButton {
		let button = UIButton(type: .system)
		
		button.showsMenuAsPrimaryAction = true
		button.changesSelectionAsPrimaryAction = true
		button.setContentHuggingPriority(.required, for: .horizontal)
		button.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		updateButton(button)
		
		return button
	}
	
	func updateUIView(_ button: UIButton, context: Context) {
		updateButton(button)
	}
	
	private func updateButton(_ button: UIButton) {
		
		if useGlassButton {
			button.configuration = .glass()
		} else {
			button.configuration = .plain()
		}
		
		button.configuration?.title = title(selection)
		
		button.menu = UIMenu(
			children: options.map { value in
				
				UIAction(
					title: title(value),
					state: value == selection ? .on : .off
				) { _ in
					selection = value
				}
			}
		)
	}
}

#Preview {
    FilterView(numberOfLetters: .constant(9), selectedLanguage: .constant(.all), gameMode: .constant(.both), showsWhenHintsUsed: .constant(.both))
}
