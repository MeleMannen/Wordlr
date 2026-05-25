//
//  GameRecordView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 17/06/2025.
//

import SwiftUI

struct GameRecordView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Environment(AdManager.self) private var adManager
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
	var gameRecord: GameRecord
	@State private var didTap: Bool = false
	@State private var hasSharedResult: Bool = false
	@State private var timeUsedString: String = ""
	
	@Namespace private var namespace
	
	let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
	let shadowGradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
	
	private let formatter1: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeZone = TimeZone(identifier: "CET")
		return formatter
	}()
	
	var body: some View {
		GeometryReader { geometry in
			ScrollView {
				VStack(alignment: .leading) {
					HStack(alignment: .center) {
						Text("\(gameRecord.word)")
							.font(.largeTitle).bold()
							.conditionalShadow(color: .black.opacity(0.5), radius: 3, x: 6, y: 6)
						
						Spacer()
						if #available(iOS 26.0, *) {
							if !self.userWantsNormalTheme && self.colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won {
								Image(systemName: "checkmark")
									.foregroundStyle(.white)
									.conditionalShadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
									.padding(12)
									.background {
										Circle()
											.foregroundStyle(LinearGradient(colors: [.orange, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing))
											.gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
											.conditionalShadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
									}
									.glassEffect(.regular.interactive(), in: .circle)
									.font(.largeTitle).bold()
									.onTapGesture(count: 10) {
										self.userWantsThePhraseNameBack.toggle()
										self.setAppIcon()
										print("Toggled userWantsThePhraseNameBack to \(self.userWantsThePhraseNameBack)")
									}
									.simultaneousGesture(TapGesture(count: 1).onEnded {
										self.didTap.toggle()
									})
									.accessibilityHidden(true)
							} else {
								Image(systemName: gameRecord.state == .won ? "checkmark" : "xmark")
									.foregroundStyle(.white)
									.conditionalShadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
									.padding(12)
									.background {
											Circle()
												.foregroundStyle(gameRecord.state == .won ? Color(uiColor: .systemGreen) : Color(uiColor: .systemRed))
									}
									.glassEffect(.regular.tint(gameRecord.state == .won ? Color(uiColor: .systemGreen) : Color(uiColor: .systemRed)).interactive())
									.font(.largeTitle).bold()
									.conditionalShadow(color: .black.opacity(0.3), radius: 3, x: 4, y: 4)
									.onTapGesture(count: 10) {
										self.userWantsThePhraseNameBack.toggle()
										self.setAppIcon()
										print("Toggled userWantsThePhraseNameBack to \(self.userWantsThePhraseNameBack)")
									}
									.simultaneousGesture(TapGesture(count: 1).onEnded {
										self.didTap.toggle()
									})
									.accessibilityHidden(true)
							}
						} else {
							if !self.userWantsNormalTheme && self.colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won {
								Image(systemName: "checkmark")
									.foregroundStyle(.white)
									.conditionalShadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
									.padding(12)
									.background {
										Circle()
											.foregroundStyle(LinearGradient(colors: [.orange, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing))
											.gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
											.conditionalShadow(color: .black.opacity(0.5), radius: 3, x: 4, y: 4)
									}
									.font(.largeTitle).bold()
									.onTapGesture(count: 10) {
										self.userWantsThePhraseNameBack.toggle()
										self.setAppIcon()
										print("Toggled userWantsThePhraseNameBack to \(self.userWantsThePhraseNameBack)")
									}
									.simultaneousGesture(TapGesture(count: 1).onEnded {
										self.didTap.toggle()
									})
									.accessibilityHidden(true)
							} else {
								Image(systemName: gameRecord.state == .won ? "checkmark" : "xmark")
									.foregroundStyle(.white)
									.conditionalShadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
									.padding(12)
									.background {
										Circle()
											.foregroundStyle(gameRecord.state == .won ? .green : .red)
											.conditionalShadow(color: .black.opacity(0.3), radius: 3, x: 4, y: 4)
									}
									.font(.largeTitle).bold()
									.onTapGesture(count: 10) {
										self.userWantsThePhraseNameBack.toggle()
										self.setAppIcon()
										print("Toggled userWantsThePhraseNameBack to \(self.userWantsThePhraseNameBack)")
									}
									.simultaneousGesture(TapGesture(count: 1).onEnded {
										self.didTap.toggle()
									})
									.accessibilityHidden(true)
							}
						}
					}
					.padding(.top)
					.padding(.horizontal)
					.accessibilityElement(children: .combine)
					.accessibilityLabel(WordlrAccessibilityFormatter.gameRecordSummary(gameRecord, timeUsed: self.timeUsedString))
					
					
					VStack(alignment: .leading) {
						HStack(alignment: .bottom) {
							Text("Date")
								.foregroundStyle(.secondary)
								.font(.title3)
							Spacer()
							if gameRecord.mode == .dailyWord && gameRecord.state == .won {
								Text("\(String(formatter1.string(from: gameRecord.date)))")
									.font(.title2)
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
							} else {
								Text("\(String(formatter1.string(from: gameRecord.date)))")
									.font(.title2)
							}
						}
						.padding(.bottom, 5)

						HStack(alignment: .bottom) {
							Text("Word length")
								.foregroundStyle(.secondary)
								.font(.title3)
							Spacer()
							if gameRecord.mode == .dailyWord && gameRecord.state == .won {
								Text("\(gameRecord.numberOfLetters)")
									.font(.title2)
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
							} else {
								Text("\(gameRecord.numberOfLetters)")
									.font(.title2)
							}

						}
						.padding(.bottom, 5)



						HStack(alignment: .bottom) {
							Text("Language")
								.foregroundStyle(.secondary)
								.font(.title3)
							Spacer()
							if gameRecord.mode == .dailyWord && gameRecord.state == .won {
								Text("\(gameRecord.language.localizedName)")
									.font(.title2)
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
							} else {
								Text("\(gameRecord.language.localizedName)")
									.font(.title2)
							}

						}
						.padding(.bottom, 5)

						HStack(alignment: .bottom) {
							Text("Mode")
								.foregroundStyle(.secondary)
								.font(.title3)
							Spacer()
							if gameRecord.mode == .dailyWord && gameRecord.state == .won {
								Text("\(gameRecord.mode.localizedName)")
									.font(.title2)
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)

							} else {
								Text("\(gameRecord.mode.localizedName)")
									.font(.title2)
							}
						}
						.padding(.bottom, 5)

						HStack(alignment: .bottom) {
							Text("Number of guesses")
								.foregroundStyle(.secondary)
								.font(.title3)
							Spacer()
							if gameRecord.mode == .dailyWord && gameRecord.state == .won {
								Text("\(gameRecord.numberOfGuesses)")
									.font(.title2)
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)

							} else {
								Text("\(gameRecord.numberOfGuesses)")
									.font(.title2)
							}

						}
						.padding(.bottom, 5)


						if let hintsUsed = gameRecord.hintsUsed, hintsUsed > 0 {
							HStack(alignment: .bottom) {
								Text("Hints used")
									.foregroundStyle(.secondary)
									.font(.title3)
								Spacer()
								if gameRecord.mode == .dailyWord && gameRecord.state == .won {
									Text("\(hintsUsed)")
										.font(.title2)
										.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)

								} else {
									Text("\(hintsUsed)")
										.font(.title2)
								}
							}
							.padding(.bottom, 5)
						}

						if !self.timeUsedString.isEmpty {
							HStack(alignment: .bottom) {
								Text("Time used")
									.foregroundStyle(.secondary)
									.font(.title3)
								Spacer()
								if gameRecord.mode == .dailyWord && gameRecord.state == .won {
									Text(self.timeUsedString)
										.font(.title2)
										.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
								} else {
									Text(self.timeUsedString)
										.font(.title2)
								}
							}
							.padding(.bottom, 5)
						}
					}
					.padding()
					
					if #available(iOS 26.0, *) {
						NavigationLink(destination: WordDefinitionView(word: gameRecord.word, language: gameRecord.language)) {
							Text("Show definition")
								.foregroundColor(.white)
								.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
								.font(.title2).bold()
								.lineLimit(2)
								.minimumScaleFactor(0.8)
								.multilineTextAlignment(.center)
								.padding(14)
								.frame(maxWidth: .infinity)
								.background {
									if !self.userWantsNormalTheme && self.colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won {
										RoundedRectangle(cornerRadius: 15)
											.foregroundStyle(self.gradient)
											.gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
									} else {
										RoundedRectangle(cornerRadius: 15)
											.foregroundStyle(Color(uiColor: .systemGreen))
									}
								}
						}
						.accessibilityHint("Opens the definition for this word.")
						.glassEffect(!self.userWantsNormalTheme && self.colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won ? .regular.interactive() : .regular.tint(.green).interactive(), in: .rect(cornerRadius: 15.0))
						.glassEffectID("definition", in: self.namespace)
						.simultaneousGesture(TapGesture().onEnded {
							self.didTap.toggle()
						})
						.padding(.vertical, 10)
						
						.padding(.horizontal, 40)
						.conditionalHaptic(.impact, trigger: self.didTap)
						//						.buttonStyle(GrowingButton())
						.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
						
						
						if let board = gameRecord.board {
							NavigationLink(destination: BoardView(gameRecord: self.gameRecord, board: board)) {
								Text("View the board")
									.foregroundColor(.white)
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
									.font(.title2).bold()
									.lineLimit(2)
									.minimumScaleFactor(0.8)
									.multilineTextAlignment(.center)
									.padding(14)
									.frame(maxWidth: .infinity)
									.background {
											let useGreen = !self.userWantsNormalTheme && self.colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won
											RoundedRectangle(cornerRadius: 15)
												.foregroundStyle(Color(uiColor: useGreen ? .systemGreen : .systemOrange))
									}

							}
							.accessibilityHint("Opens the completed board with letter feedback.")
							.glassEffect(!self.userWantsNormalTheme && self.colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won ? .regular.tint(.green).interactive() : .regular.tint(.orange).interactive(), in: .rect(cornerRadius: 15.0))
							.glassEffectID("board", in: self.namespace)
							.simultaneousGesture(TapGesture().onEnded {
								self.didTap.toggle()
							})
							.padding(.vertical, 10)
							.padding(.horizontal, 40)
							.conditionalHaptic(.impact, trigger: self.didTap)
							.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
						}
					} else {
						NavigationLink(destination: WordDefinitionView(word: gameRecord.word, language: gameRecord.language)) {
							Text("Show definition")
								.foregroundColor(.white)
								.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
								.font(.title2).bold()
								.lineLimit(2)
								.minimumScaleFactor(0.8)
								.multilineTextAlignment(.center)
								.padding(14)
								.frame(maxWidth: .infinity)
								.background {
									if !self.userWantsNormalTheme && self.colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won {
										RoundedRectangle(cornerRadius: 15)
											.foregroundStyle(self.gradient)
											.gradientShadow(gradient: self.shadowGradient, radius: 3, x: 0, y: 0)
									} else {
										RoundedRectangle(cornerRadius: 15)
											.fill(Color.green)
											.conditionalShadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
									}
								}
								.padding(.horizontal, 40)
						}
						.accessibilityHint("Opens the definition for this word.")
						.simultaneousGesture(TapGesture().onEnded {
							self.didTap.toggle()
						})
						.padding(.vertical, 10)
						.conditionalHaptic(.impact, trigger: self.didTap)
						.buttonStyle(GrowingButton())
						.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)


						if let board = gameRecord.board {
							NavigationLink(destination: BoardView(gameRecord: self.gameRecord, board: board)) {
								Text("View the board")
									.foregroundColor(.white)
									.conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
									.font(.title2).bold()
									.lineLimit(2)
									.minimumScaleFactor(0.8)
									.multilineTextAlignment(.center)
									.padding(14)
									.frame(maxWidth: .infinity)
									.background {
										RoundedRectangle(cornerRadius: 15)
											.fill(Color.orange)
									}
									.padding(.horizontal, 40)
							}
							.accessibilityHint("Opens the completed board with letter feedback.")
							.simultaneousGesture(TapGesture().onEnded {
								self.didTap.toggle()
							})
							.padding(.vertical, 10)
							.conditionalHaptic(.impact, trigger: self.didTap)
							.buttonStyle(GrowingButton())
							.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
						}
					}
					
					if gameRecord.mode == .dailyWord {
						HStack {
							Spacer()
							
							Button {
								withAnimation {
									UIPasteboard.general.string = GameResultShareFormatter.shareText(for: gameRecord)
									self.hasSharedResult = true
									self.didTap.toggle()
								}
							} label: {
								Label("Copy result", systemImage: self.hasSharedResult ? "doc.on.doc.fill" : "doc.on.doc")
									.font(.title2).bold()
									.contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
									.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
									.tint(.primary)
								
							}
							.accessibilityHint("Copies the shareable result for this game.")
							.accessibilityInputLabels(["Copy result", "Copy"])
							.padding(.vertical, 15)
							.conditionalHaptic(.impact, trigger: self.didTap)
							
							Spacer()
							
						}
					}
					
				}
				.padding(10)
				.wordlrSurface(cornerRadius: 20)
				.padding(.horizontal, 15)
				.padding(.top, 20)
				
				
			}
			.darkGradientBackground(colorScheme: colorScheme)
			.navigationTitle(gameRecord.word)
			.navigationBarTitleDisplayMode(.inline)
			.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : 75) : 0)
			.onAppear {
				AnalyticsManager.shared.logScreenViewed(screenName: "GameRecordView")
				if let endDate = gameRecord.endDate {
					self.timeUsedString = GameResultShareFormatter.timeUsedString(startDate: self.gameRecord.date, endDate: endDate).trimmingCharacters(in: .whitespaces)
				}
			}
			
		}
	}

	func getTimeUsedString(startDate: Date, endDate: Date) -> String {
		print("End date: \(endDate)")
		print("startDate: \(startDate)")
		let timeInterval = max(0, endDate.timeIntervalSince(startDate))
		print("Time interval: \(timeInterval)")
		let hours = Int(timeInterval) / 3600
		let minutes = (Int(timeInterval) % 3600) / 60
		let seconds = Int(timeInterval) % 60
		
		var timeUsedString = ""
		if hours > 0 {
			let hourFormatString = NSLocalizedString("hour_string", comment: "String for the hours")
			if hourFormatString.contains("%@") {
				timeUsedString += String(format: hourFormatString, "\(hours)")
			} else if hourFormatString.contains("%d") || hourFormatString.contains("%ld") {
				timeUsedString += String(format: hourFormatString, hours)
			} else {
				timeUsedString += "\(hours)h "
			}
		}
		if minutes > 0 {
			timeUsedString += "\(minutes)m "
		}
		if seconds > 0 {
			timeUsedString += "\(seconds)s"
		}
		print("Time used string: \(timeUsedString)")
		return timeUsedString
	}
	
	private func setAppIcon() {
		guard UIApplication.shared.supportsAlternateIcons else { return }
		var iconName: String? = nil
		if self.userWantsThePhraseNameBack {
			iconName = "ThePhraseAppIcon"
		} else {
			iconName = nil
		}
		UIApplication.shared.setAlternateIconName(iconName) { error in
			if let error = error {
				print("Icon change failed: \(error.localizedDescription)")
			}
		}
	}
}


#Preview {
	GameRecordView(gameRecord: GameRecord(date: Date(), state: .won, mode: .dailyWord, word: "Word", language: .english, numberOfLetters: 4, numberOfGuesses: 2, maxRows: 6, hintsUsed: 0, board: [[Letter(letter: "W", state: .correctPosition), Letter(letter: "O", state: .correctPosition), Letter(letter: "R", state: .correctPosition), Letter(letter: "D", state: .correctPosition)], [Letter(letter: "W", state: .correctPosition), Letter(letter: "O", state: .correctPosition), Letter(letter: "R", state: .correctPosition), Letter(letter: "D", state: .correctPosition)]]))
}
