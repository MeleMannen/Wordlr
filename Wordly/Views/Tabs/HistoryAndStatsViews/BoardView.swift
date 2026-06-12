//
//  BoardView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 30/06/2025.
//

import SwiftUI

struct BoardView: View {
    @Environment(\.colorScheme) private var colorScheme
	@Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Environment(AdManager.self) private var adManager
    @AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
    @State var gameRecord: GameRecord
    @State var board: [[Letter]]
	@State private var hasCopiedResult = false
	@State private var didTapAction = false
    let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
    let shadowGradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    private var device: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
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
    
    private var keyboardRows: [[String]] {
        switch self.gameRecord.language {
            case .english:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
			case .french:
				return [["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"], ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"], ["W", "X", "C", "V", "B", "N"]]
            case .norwegian:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Å"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ø", "Æ"], ["Z", "X", "C", "V", "B", "N", "M"]]
            case .spanish:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ñ"], ["Z", "X", "C", "V", "B", "N", "M"]]
			case .polish:
				return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
            case .all:
                return [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
        }
    }
    
    private func state(for key: String) -> LetterState {
        var bestState: LetterState = .notUsed
        
        for row in self.board {
            for letter in row where letter.letter == key {
                switch letter.state {
                    case .correctPosition:
                        return .correctPosition
                    case .correctLetter:
                        bestState = bestState == .usedButNotCorrect ? .correctLetter : bestState == .correctPosition ? .correctPosition : .correctLetter
                    case .usedButNotCorrect:
                        if bestState == .notUsed {
                            bestState = .usedButNotCorrect
                        }
                    case .notUsed:
                        continue
                }
            }
        }
        
        return bestState
    }
    
    private func color(for state: LetterState) -> Color {
        switch state {
            case .correctPosition:
                return .green
            case .correctLetter:
                return .orange
            case .usedButNotCorrect:
                return Color(UIColor.darkGray)
            case .notUsed:
                return self.colorForUnused
        }
    }
    
    @ViewBuilder
    private func hiddenKeyboard(in geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            ForEach(Array(self.keyboardRows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: self.device == .pad ? 8 : 5) {
                    if rowIndex == self.keyboardRows.count - 1 {
                        Text("Z")
                            .hidden()
							.accessibilityHidden(true)
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                        
                        Text("Z")
                            .hidden()
							.accessibilityHidden(true)
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                    }
                    
                    ForEach(row, id: \.self) { key in
                        let keyState = self.state(for: key)
                        Text(key)
                            .font(.title3).bold()
                            .foregroundStyle(keyState == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
                            .hidden()
							.accessibilityHidden(true)
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(self.color(for: keyState))
                                    .hidden()
                            }
                    }
                    
                    if rowIndex == self.keyboardRows.count - 1 {
                        Text("Z")
                            .hidden()
							.accessibilityHidden(true)
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                        
                        Text("Z")
                            .hidden()
							.accessibilityHidden(true)
                            .frame(minWidth: geometry.size.width / CGFloat(14), maxWidth: geometry.size.width / CGFloat(12), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                    }
                }
            }
            
            HStack {
                Text("Z")
                    .hidden()
					.accessibilityHidden(true)
                    .frame(minWidth: geometry.size.width / CGFloat(9), maxWidth: geometry.size.width / CGFloat(7), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                
                Spacer()
                
                Text("SUBMIT WORD")
                    .font(.title).bold()
                    .hidden()
					.accessibilityHidden(true)
                    .frame(minWidth: (geometry.size.width * 7) / CGFloat(14) + CGFloat(self.device == .pad ? 60 : 30), maxWidth: (geometry.size.width * 7) / CGFloat(12) + CGFloat(self.device == .pad ? 60 : 30), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
                
                Spacer()
                
                Text("Z")
                    .hidden()
					.accessibilityHidden(true)
                    .frame(minWidth: geometry.size.width / CGFloat(9), maxWidth: geometry.size.width / CGFloat(7), minHeight: geometry.size.height / CGFloat(10), idealHeight: geometry.size.height / CGFloat(8), maxHeight: geometry.size.height / CGFloat(6))
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            
            Spacer()
        }
        .padding(.horizontal, 5)
    }
    
    var body: some View {
        GeometryReader { geometry in
			let isDailyWord = gameRecord.mode == .dailyWord
			let definitionButtonHeight: CGFloat = 58
			let copyResultHeight: CGFloat = isDailyWord ? 48 : 0
			let actionGroupSpacing: CGFloat = isDailyWord ? (device == .phone ? 24 : 28) : 0
			let actionGroupHeight = definitionButtonHeight + copyResultHeight + actionGroupSpacing
			let bottomSpacing: CGFloat = if adManager.isBannerAdLoaded {
				device == .pad || device == .mac ? 104 : 74
			} else {
				device == .phone ? 18 : 26
			}
			let boardTopSpacing: CGFloat = device == .phone ? 20 : 42
			let minimumOuterGap: CGFloat = device == .phone ? 22 : 30
			let tileSize = boardTileSize(
				availableSize: geometry.size,
				actionHeight: actionGroupHeight,
				bottomSpacing: bottomSpacing,
				topSpacing: boardTopSpacing,
				minimumOuterGap: minimumOuterGap
			)
			let boardHeight = CGFloat(max(board.count, 1)) * tileSize + CGFloat(max(board.count - 1, 0)) * boardSpacing
			let remainingSpace = geometry.size.height - bottomSpacing - boardTopSpacing - boardHeight - actionGroupHeight
			let outerGap = max(minimumOuterGap, remainingSpace / 2)

            VStack(spacing: 0) {
				Spacer()
					.frame(height: boardTopSpacing)

				boardGrid(tileSize: tileSize)
				.frame(height: boardHeight)

				Spacer()
					.frame(height: outerGap)

				VStack(spacing: actionGroupSpacing) {
					NavigationLink(destination: WordDefinitionView(word: gameRecord.word, language: gameRecord.language)) {
						Text("Show definition")
							.foregroundColor(.white)
							.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
							.font(.title2).bold()
							.lineLimit(2)
							.minimumScaleFactor(0.8)
							.multilineTextAlignment(.center)
							.frame(maxWidth: .infinity, minHeight: definitionButtonHeight, maxHeight: definitionButtonHeight)
							.background {
								BoardActionButtonBackground(
									isCelebrationStyle: !userWantsNormalTheme && colorScheme == .dark && gameRecord.mode == .dailyWord && gameRecord.state == .won,
									baseColor: Color(uiColor: .systemGreen),
									gradient: gradient,
									shadowGradient: shadowGradient
								)
							}
					}
					.modifier(BoardActionGlassModifier(tint: .green))
					.accessibilityHint("Opens the definition for this word.")
					.simultaneousGesture(TapGesture().onEnded {
						didTapAction.toggle()
					})

					if isDailyWord {
						Button {
							withAnimation {
								UIPasteboard.general.string = GameResultShareFormatter.shareText(for: gameRecord)
								AnalyticsManager.shared.logDidCopyResultEvent(copySource: "board_detail_button")
								hasCopiedResult = true
								didTapAction.toggle()
							}
						} label: {
							Label("Copy result", systemImage: hasCopiedResult ? "doc.on.doc.fill" : "doc.on.doc")
								.font(.title2).bold()
								.frame(height: copyResultHeight)
								.contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
								.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
								.tint(.primary)
						}
						.accessibilityHint("Copies the shareable result for this game.")
						.accessibilityInputLabels(["Copy result", "Copy"])
						.disabled(GameResultShareFormatter.shareText(for: gameRecord) == nil)
					}
				}
				.padding(.horizontal, 40)

				Spacer()
					.frame(height: outerGap)

				Spacer()
					.frame(height: bottomSpacing)
            }
        }
        .navigationTitle("The board")
        .navigationBarTitleDisplayMode(.inline)
        .darkGradientBackground(colorScheme: colorScheme)
		.conditionalHaptic(.impact, trigger: didTapAction)
		.onAppear {
			AnalyticsManager.shared.logScreenViewed(screenName: "BoardView")
		}
    }

	@ViewBuilder
	private func boardGrid(tileSize: CGFloat) -> some View {
		VStack(spacing: boardSpacing) {
			ForEach(self.board.indices, id: \.self) { rowIndex in
				HStack(spacing: boardSpacing) {
					ForEach(self.board[rowIndex].indices, id: \.self) { colIndex in
						let letter = self.board[rowIndex][colIndex]
						Text(letter.letter)
							.font(.largeTitle).bold()
							.foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
							.frame(width: tileSize, height: tileSize)
							.background {
								tileBackground(for: letter, rowIndex: rowIndex)
							}
							.overlay(alignment: .bottomTrailing) {
								if differentiateWithoutColor, let symbolName = letter.state.accessibilitySymbolName {
									Image(systemName: symbolName)
										.font(.caption.bold())
										.foregroundStyle(letter.state == .notUsed ? .black : .white)
										.padding(4)
										.accessibilityHidden(true)
								}
							}
							.accessibilityHidden(true)
					}
				}
				.accessibilityElement(children: .ignore)
				.accessibilityLabel(WordlrAccessibilityFormatter.rowLabel(row: self.board[rowIndex], rowIndex: rowIndex, currentRow: gameRecord.numberOfGuesses - 1))
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.accessibilityElement(children: .contain)
		.accessibilityLabel(WordlrAccessibilityFormatter.boardLabel(board: board, currentRow: gameRecord.numberOfGuesses - 1, isGameOver: true))
		.accessibilityValue(WordlrAccessibilityFormatter.boardValue(numberOfLetters: gameRecord.numberOfLetters, rowCount: board.count))
	}

	private var boardSpacing: CGFloat {
		device == .phone ? 8 : 10
	}

	private func boardTileSize(
		availableSize: CGSize,
		actionHeight: CGFloat,
		bottomSpacing: CGFloat,
		topSpacing: CGFloat,
		minimumOuterGap: CGFloat
	) -> CGFloat {
		let columns = CGFloat(max(gameRecord.numberOfLetters, 1))
		let rows = CGFloat(max(board.count, 1))
		let isLandscape = availableSize.width > availableSize.height
		let horizontalInset: CGFloat = if device == .phone {
			72
		} else if isLandscape {
			min(availableSize.width * 0.28, 420)
		} else {
			min(availableSize.width * 0.18, 220)
		}
		let availableWidth = max(0, availableSize.width - horizontalInset)
		let availableHeight = max(0, availableSize.height - actionHeight - bottomSpacing - topSpacing - minimumOuterGap * 2)
		let widthLimitedTileSize = (availableWidth - (columns - 1) * boardSpacing) / columns
		let heightLimitedTileSize = (availableHeight - (rows - 1) * boardSpacing) / rows
		let maxTileSize: CGFloat = if device == .phone {
			62
		} else if isLandscape {
			88
		} else {
			108
		}
		return max(34, min(widthLimitedTileSize, heightLimitedTileSize, maxTileSize))
	}

	@ViewBuilder
	private func tileBackground(for letter: Letter, rowIndex: Int) -> some View {
		if !userWantsNormalTheme && gameRecord.mode == .dailyWord && gameRecord.state == .won && (rowIndex == gameRecord.numberOfGuesses - 1 || rowIndex == board.count) {
			RoundedRectangle(cornerRadius: 5)
				.foregroundStyle(gradient)
				.gradientShadow(gradient: shadowGradient, radius: 3, x: 0, y: 0)
		} else {
			RoundedRectangle(cornerRadius: 5)
				.fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : colorForUnused)))
		}
	}
}

//#Preview {
//    BoardView()
//}

private struct BoardActionButtonBackground: View {
	let isCelebrationStyle: Bool
	let baseColor: Color
	let gradient: LinearGradient
	let shadowGradient: LinearGradient

	var body: some View {
		if isCelebrationStyle {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(gradient)
				.gradientShadow(gradient: shadowGradient, radius: 3, x: 0, y: 0)
		} else {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(baseColor)
		}
	}
}

private struct BoardActionGlassModifier: ViewModifier {
	let tint: Color

	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			content
				.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: 15))
				.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
		} else {
			content
				.buttonStyle(GrowingButton())
				.conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
		}
	}
}
