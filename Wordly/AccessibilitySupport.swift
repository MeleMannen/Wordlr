//
//  AccessibilitySupport.swift
//  Wordly
//
//  Created by Kristoffer Melen on 25/05/2026.
//

import Foundation
import SwiftUI

extension LetterState {
	var accessibilityDescription: LocalizedStringResource {
		switch self {
			case .correctPosition:
				return "Correct position"
			case .correctLetter:
				return "In the word, wrong position"
			case .usedButNotCorrect:
				return "Not in the word"
			case .notUsed:
				return "Empty"
		}
	}

	var accessibilityShortDescription: LocalizedStringResource {
		switch self {
			case .correctPosition:
				return "Correct"
			case .correctLetter:
				return "Wrong position"
			case .usedButNotCorrect:
				return "Not in word"
			case .notUsed:
				return "Unused"
		}
	}

	var accessibilitySymbolName: String? {
		switch self {
			case .correctPosition:
				return "checkmark"
			case .correctLetter:
				return "arrow.left.arrow.right"
			case .usedButNotCorrect:
				return "xmark"
			case .notUsed:
				return nil
		}
	}
}

enum WordlrAccessibilityFormatter {
	static func tileLabel(letter: Letter, row: Int, column: Int) -> String {
		let position = String(
			format: String(localized: "Row %lld, column %lld"),
			row + 1,
			column + 1
		)

		guard !letter.letter.isEmpty else {
			return "\(position), \(String(localized: "blank"))"
		}

		return "\(position), \(letter.letter), \(String(localized: letter.state.accessibilityDescription))"
	}

	static func rowLabel(row: [Letter], rowIndex: Int, currentRow: Int) -> String {
		let prefix: String
		if rowIndex == currentRow {
			prefix = String(format: String(localized: "Row %lld, current guess"), rowIndex + 1)
		} else {
			prefix = String(format: String(localized: "Row %lld"), rowIndex + 1)
		}

		let hasContent = row.contains { !$0.letter.isEmpty }
		guard hasContent else {
			return "\(prefix), \(String(localized: "empty"))"
		}

		let values = row.map { letter in
			if letter.letter.isEmpty {
				return String(localized: "blank")
			}
			if letter.state == .notUsed {
				return letter.letter
			}
			return "\(letter.letter) \(String(localized: letter.state.accessibilityDescription).lowercased())"
		}

		return ([prefix] + values).joined(separator: ", ")
	}

	static func boardLabel(board: [[Letter]], currentRow: Int, isGameOver: Bool) -> String {
		if isGameOver {
			return String(localized: "Game board, game over")
		}

		return String(
			format: String(localized: "Game board, row %lld of %lld"),
			min(currentRow + 1, board.count),
			board.count
		)
	}

	static func boardValue(numberOfLetters: Int, rowCount: Int) -> String {
		String(
			format: String(localized: "%lld-letter word, %lld rows"),
			numberOfLetters,
			rowCount
		)
	}

	static func keyboardKeyLabel(key: KeyBoardLetter) -> String {
		String(format: String(localized: "Letter %@"), key.letter)
	}

	static func keyboardKeyValue(key: KeyBoardLetter) -> String {
		if key.state == .notUsed {
			return String(localized: "unused")
		}

		return String(localized: key.state.accessibilityDescription).lowercased()
	}

	static func keyboardKeyHint(key: KeyBoardLetter) -> String {
		String(format: String(localized: "Inserts %@"), key.letter)
	}

	static func gameRecordSummary(_ record: GameRecord, timeUsed: String?) -> String {
		var parts = [
			record.word,
			record.state == .won ? String(localized: "Won") : String(localized: "Lost"),
			record.mode.localizedName,
			record.language.localizedName,
			String(format: String(localized: "%lld letters"), record.numberOfLetters),
			String(format: String(localized: "%lld guesses"), record.numberOfGuesses)
		]

		if let timeUsed, !timeUsed.isEmpty {
			parts.append(String(format: String(localized: "Time used: %@"), timeUsed))
		}

		return parts.joined(separator: ", ")
	}

	static func winRateChartSummary(wins: Int, losses: Int, winRate: Double) -> String {
		String(
			format: String(localized: "Win rate chart. %lld wins, %lld losses, %.0f percent win rate."),
			wins,
			losses,
			winRate * 100
		)
	}

	static func guessesChartSummary(counts: [Int]) -> String {
		guard let best = counts.enumerated().max(by: { $0.element < $1.element }), best.element > 0 else {
			return String(localized: "Guesses chart. No won games in this selection.")
		}

		return String(
			format: String(localized: "Guesses chart. Most wins were in %lld guesses with %lld games."),
			best.offset + 1,
			best.element
		)
	}

	static func streakChartSummary(title: String, language: LanguageSelection, streaks: [(index: Int, currentStreak: Int, longestStreak: Int)]) -> String {
		let details = streaks.map {
			String(
				format: String(localized: "%lld letters, current streak %lld, longest streak %lld"),
				$0.index,
				$0.currentStreak,
				$0.longestStreak
			)
		}.joined(separator: "; ")

		return "\(title), \(language.localizedName). \(details)"
	}
}
