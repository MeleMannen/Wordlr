//
//  GameView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import GoogleMobileAds
import TipKit

struct GameView26: View {
    @EnvironmentObject var appManager: AppManager
	@Environment(AdManager.self) private var adManager: AdManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("userWantsAds") var userWantsAds: Bool = true
    
    @State var didTapSubmitButton: Bool = false
    @State var didTapBackButton: Bool = false
    @State var didTapResetButton: Bool = false
    @State var didTapNewGameButton: Bool = false
    @State var didTapShowDefinitionButton: Bool = false
    @State var isShowingCurrentDefinition: Bool = false
    @State var alertItem: AlertItem?
	
	@Namespace private var namespace
    
    private var device : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var colorForUnused: Color {
        switch colorScheme {
            case .light:
                return Color(UIColor.lightGray)
            case .dark:
                return .primary
			@unknown default:
				return .primary
		}
	}
	
	var body: some View {
		if #available(iOS 26.0, *) {
			GeometryReader { geometry in
				VStack {
					GeometryReader { geometry2 in
						VStack {
							ForEach(appManager.board.indices, id: \.self) { rowIndex in
								HStack {
									ForEach(appManager.board[rowIndex].indices, id: \.self) { colIndex in
										let letter = appManager.board[rowIndex][colIndex]
										if appManager.numberOfLetters < 5 {
											Text(letter.letter)
												.font(.largeTitle).bold()
												.foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
												.frame(width: geometry2.size.height / CGFloat(6), height: geometry2.size.height / CGFloat(6))
												.background {
													if !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .dailyWord && appManager.didWinGame == .won && appManager.isGameOver && (rowIndex == appManager.currentRow - 1 || rowIndex == appManager.board.count) {
														RoundedRectangle(cornerRadius: 5)
															.foregroundStyle(appManager.gradient)
															.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
													} else {
														RoundedRectangle(cornerRadius: 5)
															.fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused)))
													}
												}
												.rotationEffect(.degrees(letter.degreee), anchor: .center)
												.animation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
													.speed(1)
													.delay(0), value: letter.degreee)
												.animation(.easeInOut(duration: 0.5), value: appManager.didWinGame)
												.scaleEffect(letter.scale, anchor: .center)
												.offset(x: rowIndex == appManager.currentRow ? (appManager.isShaking ? -15 : 0) : 0)
												.onChange(of: letter.state) {
													if letter.state != .notUsed {
														appManager.flipCard(rowIndex: rowIndex, colIndex: colIndex)
													}
												}
												.onChange(of: letter.letter) {
													if !letter.letter.isEmpty {
														appManager.animateTappedLetter(rowIndex: rowIndex, colIndex: colIndex)
													} else {
														appManager.animateRemovingLetter(rowIndex: rowIndex, colIndex: colIndex)
													}
												}
											
										} else {
											Text(letter.letter)
												.font(.largeTitle).bold()
												.foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
												.frame(width: geometry2.size.height / CGFloat(appManager.numberOfLetters + 1), height: geometry2.size.height / CGFloat(appManager.numberOfLetters + 1))
												.background {
													if !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .dailyWord && appManager.didWinGame == .won && appManager.isGameOver && (rowIndex == appManager.currentRow - 1 || rowIndex == appManager.board.count) {
														RoundedRectangle(cornerRadius: 5)
															.foregroundStyle(appManager.gradient)
															.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
													} else {
														RoundedRectangle(cornerRadius: 5)
															.fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused)))
													}
												}
												.rotationEffect(.degrees(letter.degreee), anchor: .center)
												.animation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
													.speed(1)
													.delay(0), value: letter.degreee)
												.animation(.easeInOut(duration: 0.5), value: appManager.didWinGame)
												.scaleEffect(letter.scale, anchor: .center)
												.offset(x: rowIndex == appManager.currentRow ? (appManager.isShaking ? -15 : 0) : 0)
												.onChange(of: letter.state) {
													if letter.state != .notUsed {
														appManager.flipCard(rowIndex: rowIndex, colIndex: colIndex)
													}
												}
												.onChange(of: letter.letter) {
													if !letter.letter.isEmpty {
														appManager.animateTappedLetter(rowIndex: rowIndex, colIndex: colIndex)
													} else {
														appManager.animateRemovingLetter(rowIndex: rowIndex, colIndex: colIndex)
													}
												}
											
										}
									}
								}
							}
						}
						.padding(.top, 5)
						.frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
						
					}
					GeometryReader { geometry2 in
						ZStack {
							GlassEffectContainer {
								VStack {
									Spacer()
									VStack {
										ForEach(appManager.keyboard.indices, id: \.self) { rowIndex in
											let keyboardRow = appManager.keyboard[rowIndex]
											HStack(spacing: self.device == .pad ? 8 : 5) {
												ForEach(appManager.keyboard[rowIndex].indices, id: \.self) { colIndex in
													let keyBoardKey = keyboardRow[colIndex]
													if appManager.keyboard.last == keyboardRow && keyboardRow.first?.letter == keyBoardKey.letter {
														Text("Z")
															.hidden()
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
														
														
														Text("Z")
															.hidden()
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
														
													}
													Button(action: {
														if appManager.currentIndex < appManager.numberOfLetters {
															appManager.board[appManager.currentRow][appManager.currentIndex].letter = keyBoardKey.letter
															appManager.currentIndex += 1
														}
														appManager.keyboard[rowIndex][colIndex].didTapButton.toggle()
													}, label: {
														Text(keyBoardKey.letter)
															.font(.title2).bold()
															.foregroundStyle(keyBoardKey.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
															.glassEffect(.regular.tint(keyBoardKey.state == .correctPosition ? .green : (keyBoardKey.state == .correctLetter ? .orange : (keyBoardKey.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused))).interactive(), in: .rect(cornerRadius: 5.0))
															.glassEffectID("\(keyBoardKey.letter)", in: self.namespace)
													})
													.keyboardShortcut(KeyEquivalent(Character(keyBoardKey.letter.lowercased())), modifiers: [])
													.sensoryFeedback(.impact, trigger: keyBoardKey.didTapButton)
													
													
													
													
													if appManager.keyboard.last == keyboardRow && keyboardRow.last?.letter == keyBoardKey.letter {
														Text("Z")
															.hidden()
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
														
														Text("Z")
															.hidden()
															.frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
													}
												}
											}
										}
									}
									HStack {
										Button(action: {
											self.didTapResetButton.toggle()
											if appManager.selectedGameMode == .normal {
												self.alertItem = AlertItem(
													title: Text("Are you sure you want to Restart?"),
													message: Text("You will lose your word and you cannot undo this action!"),
													primaryButton: .destructive(Text("Restart")) {
														self.alertItem = AlertItem(
															title: Text("The Word Was: \(appManager.word)!"),
															message: Text("Do you want to see the definition?"),
															primaryButton: .default(Text("Show Definition")) {
																self.isShowingCurrentDefinition = true
																
																DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
																	print("reseting...")
																	appManager.resetBoard()
																}
															},
															secondaryButton: .cancel(Text("Dismiss")) {
																print("reseting...")
																appManager.resetBoard()
															})
													}, secondaryButton: .cancel())
											}
											
										}, label: {
											Image(systemName: "arrow.clockwise")
												.font(.title2).bold()
												.foregroundStyle(.black)
												.frame(minWidth: geometry2.size.width / CGFloat(9),
													   maxWidth: geometry2.size.width / CGFloat(7),
													   minHeight: geometry2.size.height / CGFloat(10),
													   idealHeight: geometry2.size.height / CGFloat(8),
													   maxHeight: geometry2.size.height / CGFloat(6))
										})
										.keyboardShortcut("r", modifiers: .command)
										.sensoryFeedback(.impact, trigger: self.didTapResetButton)
										.alert(item: self.$alertItem) { item in
											if let dismissButton = item.dismissButton {
												Alert(title: item.title, message: item.message, dismissButton: dismissButton)
											} else if let primaryButton = item.primaryButton, let secondaryButton = item.secondaryButton {
												Alert(title: item.title, message: item.message, primaryButton: primaryButton, secondaryButton: secondaryButton)
											} else {
												Alert(title: item.title)
											}
											
										}
										.glassEffect(.regular.tint(self.colorForUnused.opacity(appManager.selectedGameMode == .dailyWord ? 0.4 : 1.0)).interactive(), in: .rect(cornerRadius: 10.0))
										.glassEffectID("reset", in: self.namespace)
										.sensoryFeedback(.warning, trigger: self.alertItem?.title)
										.sensoryFeedback(.warning, trigger: self.didTapResetButton)
										
										
										
										Spacer()
										
										
										Button(action: {
											self.didTapSubmitButton.toggle()
											if !appManager.isAnimating {
												appManager.didTapSubmit()
											}
										}, label: {
											Text("SUBMIT WORD")
												.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 3, y: 3)
												.font(.title).bold()
												.frame(minWidth: (geometry2.size.width*7) / CGFloat(14) + CGFloat(self.device == .pad ? 60 : 30), maxWidth: (geometry2.size.width*7) / CGFloat(12) + CGFloat(self.device == .pad ? 60 : 30), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
												.foregroundStyle(.white)
												.background {
													if !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .dailyWord {
														RoundedRectangle(cornerRadius: 10)
															.foregroundStyle(appManager.gradient)
															.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
															.opacity(appManager.submitOpacity)
													}
													
												}
										})
										.keyboardShortcut(.defaultAction)
										.glassEffectID("submit", in: self.namespace)
										.glassEffect(self.userWantsNormalTheme || !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .normal ? .regular.tint(.green.opacity(appManager.submitOpacity)).interactive() : .regular.interactive(), in: .rect(cornerRadius: 10.0))
										.animation(.easeInOut(duration: 0.2), value: appManager.submitOpacity)
										.sensoryFeedback(.alignment, trigger: appManager.submitOpacity)
										.onChange(of: appManager.wordIsValidForSubmitButton()) { _, newValue in
											withAnimation {
												if newValue {
													appManager.submitOpacity = 1.0
												} else {
													appManager.submitOpacity = 0.5
												}
											}
										}
										.sensoryFeedback(trigger: self.didTapSubmitButton) {
											if appManager.isAnimating {
												return .impact
											} else {
												return .error
											}
										}
										
										Spacer()
										
										Button(action: {
											self.didTapBackButton.toggle()
											if !appManager.isAnimating && appManager.currentIndex > 0 {
												appManager.currentIndex -= 1
												appManager.board[appManager.currentRow][appManager.currentIndex].letter = ""
											}
											
										}, label: {
											Image(systemName: "delete.left")
												.font(.title2).bold()
												.foregroundStyle(.black)
												.frame(minWidth: geometry2.size.width / CGFloat(9), maxWidth: geometry2.size.width / CGFloat(7), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
											
										})
										.keyboardShortcut(.delete, modifiers: [])
										.glassEffect(.regular.tint(self.colorForUnused).interactive(), in: .rect(cornerRadius: 10.0))
										.glassEffectID("delete", in: self.namespace)
										.buttonRepeatBehavior(.enabled)
										.sensoryFeedback(.impact, trigger: self.didTapBackButton)
										
									}
									.padding(.top, 5)
									.padding(.bottom, 5)
								}
							}
							.opacity((appManager.isGameOver && !appManager.isAnimating) ? 0 : 1)
							
							
							VStack(alignment: .center) {
								Spacer()
								Spacer()
								
								Text(appManager.message)
									.font(.title2).bold()
									.padding(.top, 5)
								
								Spacer()
								
								Button(action: {
									if appManager.selectedGameMode == .normal {
										self.didTapNewGameButton.toggle()
										appManager.resetBoard()
										Task {
											await HintTip.getHintEvent.donate()
										}
									} else {
										dismiss()
									}
								}, label: {
									Text(appManager.selectedGameMode == .normal ? "New Game" : "Play Something Else")
										.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
										.font(.title2).bold()
										.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
										.foregroundStyle(.white)
								})
								.keyboardShortcut("n", modifiers: .command)
								.glassEffect(.regular.tint(.green).interactive(), in: .rect(cornerRadius: 10.0))
								.glassEffectID("new", in: self.namespace)
								.padding(.horizontal, 20)
								.sensoryFeedback(.impact, trigger: self.didTapNewGameButton)
								.conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)
								
								Spacer()
								
								NavigationLink(destination: WordDefinitionView(word: appManager.word, language: appManager.selectedLanguage), label: {
									if !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .dailyWord {
										Text("Show Definition")
											.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
											.font(.title2).bold()
											.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
											.foregroundStyle(.white)
											.background {
												RoundedRectangle(cornerRadius: 10)
													.foregroundStyle(appManager.gradient)
													.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
											}
									} else {
										Text("Show Definition")
											.conditionalShadow(color: .black.opacity(0.2), radius: 2, x: 4, y: 4)
											.font(.title2).bold()
											.frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
											.foregroundStyle(.white)
									}
								})
								.simultaneousGesture(TapGesture().onEnded {
									self.didTapShowDefinitionButton.toggle()
									adManager.shouldShowAds = true
								})
								.glassEffect(self.userWantsNormalTheme || !self.userWantsNormalTheme && self.colorScheme == .dark && appManager.selectedGameMode == .normal ? .regular.tint(.orange).interactive() : .regular.interactive(), in: .rect(cornerRadius: 10.0))
								.glassEffectID("definition", in: self.namespace)
								.conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)
								.sensoryFeedback(.impact, trigger: self.didTapShowDefinitionButton)
								.padding(.horizontal, 20)
								
								Spacer()
								
								if appManager.selectedGameMode == .dailyWord {
									Button {
										withAnimation {
											appManager.hasSharedResult = true
											self.didTapBackButton.toggle()
											UIPasteboard.general.string = appManager.getShareResult(row: appManager.currentRow, numberOfLetters: appManager.numberOfLetters, date: appManager.startDate, board: appManager.board, timeUsedString: appManager.getTimeUsedString(startDate: appManager.startDate, endDate: appManager.endDate))
											
											
										}
									} label: {
										Label("Copy Result", systemImage: appManager.hasSharedResult ? "doc.on.doc.fill" : "doc.on.doc")
											.font(.title2).bold()
											.contentTransition(.symbolEffect(.replace))
											.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
											.tint(.primary)
									}
									.keyboardShortcut("c", modifiers: .command)
									
									Spacer()
								}
								
								
								
							}
							.opacity((appManager.isGameOver && !appManager.isAnimating) ? 1 : 0)
							.sensoryFeedback(.success, trigger: (appManager.isGameOver && !appManager.isAnimating))
							
						}
						.padding(.horizontal, 5)
					}
					.frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
				}
				.navigationDestination(isPresented: self.$isShowingCurrentDefinition, destination: {
					WordDefinitionView(word: appManager.word)
						.environmentObject(appManager)
				})
				.navigationTitle("Guess the Word")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItemGroup(placement: .topBarTrailing) {
						if appManager.isHintAvailable() && appManager.shouldShowAdButton {
							AdButton()
								.environmentObject(appManager)
								.keyboardShortcut("h", modifiers: .command)
							
							SearchToolbarItem()
								.environmentObject(appManager)
							
						} else {
							SearchToolbarItem()
								.environmentObject(appManager)
						}
					}
				}
				.animation(.default, value: appManager.isHintAvailable() && appManager.shouldShowAdButton)
			}
			.onAppear {
				if appManager.word.isEmpty || appManager.selectedLanguage != appManager.language || appManager.gameMode != appManager.selectedGameMode || appManager.message == "" && appManager.isGameOver {
					appManager.getWords()
				} else if appManager.word.count != appManager.numberOfLetters {
					appManager.resetBoard()
				}
				adManager.currentSelectView = .gameView
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
					adManager.shouldShowAds = false
				}
				
			}
			.onDisappear {
				adManager.currentSelectView = .selectView
			}
			.task {
				if userWantsAds {
					await appManager.loadAd()
					appManager.hasLoadedAd = true
				}
			}
		}
		
    }
}

struct AdButton: View {
    @EnvironmentObject var appManager: AppManager
    @AppStorage("userWantsAds") var userWantsAds: Bool = true
    @State private var didTap: Bool = false
	let hintTip = HintTip()
    
    var body: some View {
        Button(action: {
            self.didTap.toggle()
			self.hintTip.invalidate(reason: .actionPerformed)
			Task {
				await HintTip.getHintEvent.donate()
			}
			if !appManager.isGameOver && !appManager.isAnimating {
				if appManager.hasLoadedAd {
					appManager.showAd()
					
				} else {
					Task {
						await appManager.loadAd()
						appManager.showAd()
					}
				}
			}
        }, label: {
            Image(systemName: "lightbulb.max.fill")
                .contentShape(Rectangle())
        })
        .task {
			if userWantsAds && !appManager.hasLoadedAd {
                await appManager.loadAd()
				appManager.hasLoadedAd = true
            }
        }
        .sensoryFeedback(.selection, trigger: self.didTap)
		.popoverTip(self.hintTip)
    }
}

struct SearchToolbarItem: View {
	@EnvironmentObject var appManager: AppManager
	@State var didTapSearchButton: Bool = false
	private let searchTip = SearchTip()
	
	var body: some View {
		NavigationLink(destination: SearchView().environmentObject(appManager), label: {
			Image(systemName: "magnifyingglass")
				.contentShape(Rectangle())
		})
		.simultaneousGesture(TapGesture().onEnded {
			self.didTapSearchButton.toggle()
			Task {
				await SearchTip.searchEvent.donate()
			}
		})
		.sensoryFeedback(.selection, trigger: self.didTapSearchButton)
		.popoverTip(self.searchTip)
	}
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ScalingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}



#Preview {
    GameView26()
        .environmentObject(AppManager())
}

