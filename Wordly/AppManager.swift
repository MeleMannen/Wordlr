//
//  AppManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@MainActor
@Observable
final class AppManager: NSObject, FullScreenContentDelegate {

	private var defaultLanguage: LanguageSelection {
		get {
			UserDefaults.standard.string(forKey: "defaultLanguage").flatMap(LanguageSelection.init(rawValue:)) ?? .norwegian
		}
		set {
			UserDefaults.standard.set(newValue.rawValue, forKey: "defaultLanguage")
		}
	}
	
	private var defaultNumberOfLetters: Int {
		get {
			UserDefaults.standard.object(forKey: "defaultNumberOfLetters") as? Int ?? 5
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "defaultNumberOfLetters")
		}
	}
	
	private var userWantsThePhraseNameBack: Bool {
		get {
			UserDefaults.standard.bool(forKey: "userWantsThePhraseNameBack")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "userWantsThePhraseNameBack")
		}
	}
	
	var gameRecords: [GameRecordEntity] = []
	@ObservationIgnored var modelContext: ModelContext?
	@ObservationIgnored var gameRecordManager: GameRecordManager?
	
	var selectedLanguage: LanguageSelection = .norwegian
	var language: LanguageSelection = .norwegian
	var gameMode: GameMode = .normal
	var selectedGameMode: GameMode = .normal
	var isExpertModeEnabled: Bool = false
	private var gameExpertModeEnabled: Bool = false
	private var loadedWordsLanguage: LanguageSelection?
	var numberOfLetters: Int = 5
	var word: String = ""
	var words: Words?
	var dailyWords: Words?
	var board: [[Letter]] = []
	var keyboard: [[KeyBoardLetter]] = []
	var currentRow = 0
	var currentIndex = 0
	var isGameOver: Bool = false
	var shouldShowCelebrationGradient: Bool = false
	var message: String = ""
	var isAnimating: Bool = false
	var isShaking: Bool = false
	private var pendingKeyboardUpdate: [[KeyBoardLetter]]?
	private var pendingGameCompletion: (() -> Void)?
	var submitOpacity: Double = 0.5
	var shouldShowAdButton: Bool = false
	var hasLoadedAd: Bool = false
	var startDate: Date = Date()
	var endDate: Date = Date()
	var hasSharedResult: Bool = false
	var didWinGame: GameEndState = .lost
	var shouldPromptForNotificationsAfterFirstWin: Bool = false
	var shouldPromptForProAfterGameCompletion: Bool = false
	var searchedWord: String = ""
	var isSearching: Bool = false
	
	var isFilteringSearchWord: Bool = true
	var isFilteringStartWith: Bool = false
	var startsWithFilter: String = ""
	var isFilteringEndsWith: Bool = false
	var endsWithFilter: String = ""
	var isFilteringExcludeLetters: Bool = false
	var isFilteringIncludedLetters: Bool = false
	var selectedExcludedLetters: [String] = []
	var selectedIncludedLetters: [String] = []
	var dailyWordHasBeenPlayed: Bool = false
	
	private let valid5LetterNames: [String] = ["SIMEN", "LUKAS", "JONAS", "HELLE", "MARTE", "ROHIN", "HILDE", "TROND", "JOMAR", "DAHLE", "SYVER", "BØRGE", "ØLARS", "HSFKJ"]
	private let valid6LetterNames: [String] = ["MARTIN", "MARIUS", "TOBIAS", "DANIEL", "HENRIK", "KRISTIN"]
	private let valid8LetterNames: [String] = ["JOHANNES", "LEONARDO", "TORBJØRN"]
	
	let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
	let shadowGradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
	
	@ObservationIgnored private var hintsUsed: Int = 0
	@ObservationIgnored private var submittedWordWaitingForReveal: String?
	var isResettingBoard: Bool = false
	
	@ObservationIgnored private var rewardedAd: RewardedAd?
	@ObservationIgnored private var isLoadingAd = false
	
	func getWords() {
		self.loadWords(resetBoardAfterLoading: true)
	}

	func ensureWordsLoadedForSearch() {
		if self.words == nil || self.loadedWordsLanguage != self.selectedLanguage {
			self.loadWords(resetBoardAfterLoading: false)
		}
	}

	private func loadWords(resetBoardAfterLoading: Bool) {
		if let words = WordleDataManager.shared.loadWordsFromJSONFile(selectedLanguage: selectedLanguage) {
			self.words = words
			self.dailyWords = words
			self.loadedWordsLanguage = selectedLanguage
			if resetBoardAfterLoading {
				self.resetBoard()
			}
		} else {
			self.words = Words(dailyWords: [:])
			self.dailyWords = self.words
			self.loadedWordsLanguage = selectedLanguage
			if resetBoardAfterLoading {
				self.resetBoard()
			}
		}
	}

	func prepareGameForSelectedOptions() {
		let expertModeChangedForNormalGame = self.selectedGameMode == .normal &&
			self.gameMode == .normal &&
			self.gameExpertModeEnabled != self.isExpertModeEnabled
		self.normalizeSelectedOptions()

		if self.word.isEmpty ||
			self.selectedLanguage != self.language ||
			self.gameMode != self.selectedGameMode ||
			expertModeChangedForNormalGame ||
			self.message == "" && self.isGameOver {
			self.getWords()
		} else if self.word.count != self.numberOfLetters || !self.hasExpectedBoardShape || !self.hasExpectedKeyboardShape {
			self.resetBoard()
		}
	}

	func repairGameIfNeeded() {
		self.normalizeSelectedOptions()
		if self.word.isEmpty || !self.hasExpectedBoardShape || !self.hasExpectedKeyboardShape {
			self.getWords()
		}
	}

	private var hasExpectedBoardShape: Bool {
		self.board.count == rowCount(for: self.numberOfLetters) &&
		self.board.allSatisfy { $0.count == self.numberOfLetters }
	}

	private var hasExpectedKeyboardShape: Bool {
		!self.keyboard.isEmpty &&
		self.keyboard.allSatisfy { !$0.isEmpty }
	}

	private func normalizeSelectedOptions() {
		if !(1...8).contains(self.numberOfLetters) {
			self.numberOfLetters = 5
		}
		if self.selectedLanguage == .all {
			self.selectedLanguage = .norwegian
		}
	}
	
	func fixStartBoard() {
		self.board = (0..<rowCount(for: self.numberOfLetters)).map { _ in
			(0..<self.numberOfLetters).map { _ in Letter() }
		}
	}
	
	
	func checkIfDailyWordIsAlreadyPlayed() -> Bool {
		var cetCalendar = Calendar(identifier: .gregorian)
		cetCalendar.timeZone = TimeZone(identifier: "CET")!
		let currentDate = Date()
		for gameRecord in self.gameRecords {
			if gameRecord.gameRecord.mode == .dailyWord && gameRecord.gameRecord.language == self.selectedLanguage && gameRecord.gameRecord.numberOfLetters == self.numberOfLetters {
				if cetCalendar.isDate(gameRecord.gameRecord.date, inSameDayAs: currentDate) {
					return true
				}
			}
		}
		return false
	}
	
	
	
	func getCurrentDateInUTCTimeSince1970() -> TimeInterval {
		let utcDate = Date().toUTC()
		return utcDate.timeIntervalSince1970
		
	}
	
	func hasGameStarted() -> Bool {
		return self.currentRow > 0 && !self.isGameOver
	}
	
	
	func getRandomWord() {
		if self.selectedGameMode == .normal {
			self.word = self.getRandomNormalModeWord()
		} else {
			self.word = self.getDailyWord()
		}
		print("Ordet er \(self.word)")
		self.dailyWordHasBeenPlayed = self.checkIfDailyWordIsAlreadyPlayed()
		AnalyticsManager.shared.logGameStartedEvent(word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, gameMode: self.selectedGameMode)
	}
	
	
	func getDailyWord() -> String {
		let calendar = Calendar.current
		let startDate = DateComponents(calendar: calendar, year: 2025, month: 2, day: 15).date!
		let currentDate = Date()
		let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: currentDate).day!
		
		let dailyWords = self.dailyAnswerWords()
		if !dailyWords.isEmpty {
			let count = dailyWords.count
			let dailyWordIndex = daysSinceStart % count
			return dailyWords[dailyWordIndex]
		} else {
			return "PIANO"
		}
	}
	
	func searchableWords() -> [String] {
		let blockedWords = Set(self.blockedWords.map(comparisonKey))
		return self.uniqueWords(self.searchableWordPoolForCurrentMode())
			.filter { !blockedWords.contains(self.comparisonKey($0)) }
			.sorted(using: String.Comparator(options: .caseInsensitive, locale: self.searchSortLocale, order: .forward))
	}
	
	private func getRandomNormalModeWord() -> String {
		let availableWords = self.normalModeAnswerWords()
		if let randomWord = availableWords.randomElement() {
			return randomWord
		}
		
		return self.dailyAnswerWords().randomElement() ?? "PIANO"
	}

	private var dailyWordsForCurrentLength: [String] {
		self.words?.dailyWords["\(self.numberOfLetters)"] ?? []
	}

	private var expertWordsForCurrentLength: [String] {
		self.words?.expertWords["\(self.numberOfLetters)"] ?? []
	}

	private var blockedWords: [String] {
		self.words?.blockedWords ?? []
	}

	private var phraseNamesForCurrentLength: [String] {
		guard self.userWantsThePhraseNameBack else {
			return []
		}

		switch self.numberOfLetters {
			case 5:
				return self.valid5LetterNames
			case 6:
				return self.valid6LetterNames
			case 8:
				return self.valid8LetterNames
			default:
				return []
		}
	}

	private var searchSortLocale: Locale {
		switch self.selectedLanguage {
			case .french:
				return Locale(identifier: "fr")
			case .spanish:
				return Locale(identifier: "es")
			case .norwegian:
				return Locale(identifier: "nb")
			case .polish:
				return Locale(identifier: "pl")
			default:
				return Locale.current
		}
	}

	private func normalModeAnswerWords() -> [String] {
		let answerWords = self.isExpertModeEnabled
			? self.dailyWordsForCurrentLength + self.expertWordsForCurrentLength
			: self.dailyWordsForCurrentLength
		return self.answerCandidateWords(answerWords + self.phraseNamesForCurrentLength)
	}

	private func searchableWordPoolForCurrentMode() -> [String] {
		if self.selectedGameMode == .normal && self.isExpertModeEnabled {
			return self.dailyWordsForCurrentLength + self.expertWordsForCurrentLength
		}

		return self.dailyWordsForCurrentLength
	}

	private func dailyAnswerWords() -> [String] {
		self.answerCandidateWords(self.dailyWordsForCurrentLength)
	}

	private func answerCandidateWords(_ words: [String]) -> [String] {
		let blockedWords = Set(self.blockedWords.map(comparisonKey))
		return self.uniqueWords(words)
			.filter { !blockedWords.contains(self.comparisonKey($0)) }
	}

	private func uniqueWords(_ words: [String]) -> [String] {
		var seen: Set<String> = []
		var uniqueWords: [String] = []

		for word in words {
			let key = self.comparisonKey(word)
			if seen.insert(key).inserted {
				uniqueWords.append(word)
			}
		}

		return uniqueWords
	}
	
	func fixKeyboard() {
		var newKeyboard: [[KeyBoardLetter]] = []
		var keyBoardCharacters: [[String]] = []
		switch self.selectedLanguage {
			case .english:
				keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
			case .french:
				keyBoardCharacters = [["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"], ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"], ["W", "X", "C", "V", "B", "N"]]
			case .norwegian:
				keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Å"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ø", "Æ"], ["Z", "X", "C", "V", "B", "N", "M"]]
			case .spanish:
				keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ñ"], ["Z", "X", "C", "V", "B", "N", "M"]]
			case .polish:
				keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
			case .all:
				keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
		}
		
		for row in keyBoardCharacters {
			var keyBoardRow: [KeyBoardLetter] = []
			for letter in row {
				let keyBoardLetter = KeyBoardLetter(letter: letter)
				keyBoardRow.append(keyBoardLetter)
			}
			newKeyboard.append(keyBoardRow)
		}
		self.keyboard = newKeyboard
		
	}
	
	func getWordFromCurrentRow() -> String {
		var word = ""
		if self.board.isEmpty || self.currentRow >= self.board.count {
			return word
		}
		for letter in self.board[self.currentRow] {
			word += letter.letter
		}
		
		return word
	}
	
	private func comparisonKey(_ value: String) -> String {
		guard self.selectedLanguage == .french else {
			return value.uppercased()
		}
		return value
			.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
			.uppercased()
	}

	private func lettersMatch(_ lhs: String, _ rhs: String) -> Bool {
		self.comparisonKey(lhs) == self.comparisonKey(rhs)
	}

	private func wordsMatch(_ lhs: String, _ rhs: String) -> Bool {
		self.comparisonKey(lhs) == self.comparisonKey(rhs)
	}

	private func containsWord(_ word: String, in words: [String]?) -> Bool {
		guard let words else {
			return false
		}
		guard self.selectedLanguage == .french else {
			return words.contains(word)
		}

		let normalizedWord = self.comparisonKey(word)
		return words.contains { self.comparisonKey($0) == normalizedWord }
	}

	private func wordContainsComparableLetter(_ letter: String) -> Bool {
		self.word.contains { self.lettersMatch(String($0), letter) }
	}

	private func canAccessCurrentBoardCell(at index: Int? = nil) -> Bool {
		guard self.board.indices.contains(self.currentRow) else {
			return false
		}
		let columnIndex = index ?? self.currentIndex
		return self.board[self.currentRow].indices.contains(columnIndex)
	}
	
	func insertLetterAtCurrentPosition(_ letter: String) {
		guard !self.isAnimating,
			  !self.isGameOver,
			  self.currentIndex < self.numberOfLetters,
			  self.canAccessCurrentBoardCell() else {
			return
		}
		
		self.board[self.currentRow][self.currentIndex].letter = letter
		self.currentIndex += 1
	}
	
	func deleteLetterAtCurrentPosition() {
		guard !self.isAnimating,
			  self.currentIndex > 0 else {
			return
		}
		
		let previousIndex = self.currentIndex - 1
		guard self.canAccessCurrentBoardCell(at: previousIndex) else {
			return
		}
		
		self.currentIndex = previousIndex
		self.board[self.currentRow][previousIndex].letter = ""
	}
	
	func isReadyToSubmit() -> Bool {
		return self.board[self.currentRow].count == self.numberOfLetters
	}
	
	func findKeyPosition(letter: String) -> (row: Int, col: Int)? {
		for (rowIndex, row) in keyboard.enumerated() {
			if let colIndex = row.firstIndex(where: { self.lettersMatch($0.letter, letter) }) {
				return (row: rowIndex, col: colIndex)
			}
		}
		return nil
	}
	
	
	
	func highlightBoardLetters(completion: @escaping (Bool) -> Void) {
		guard self.board.indices.contains(self.currentRow) else {
			completion(false)
			return
		}
		
		var updatedBoard = self.board
		let answerLetters = Array(self.word)
		var remainingLetters = answerLetters.map { Optional(self.comparisonKey(String($0))) }
		for i in 0..<updatedBoard[self.currentRow].count {
			guard remainingLetters.indices.contains(i) else {
				completion(false)
				return
			}
			let letter = answerLetters[i]
			let guessedLetter = updatedBoard[self.currentRow][i].letter
			guard self.findKeyPosition(letter: guessedLetter) != nil else {
				completion(false)
				return
			}
			if self.lettersMatch(guessedLetter, String(letter)) {
				updatedBoard[self.currentRow][i].isCorrectPosition = true
				remainingLetters[i] = nil
			}
		}
		
		for i in 0..<updatedBoard[self.currentRow].count {
			guard answerLetters.indices.contains(i) else {
				completion(false)
				return
			}
			let letter = String(answerLetters[i])
			let guessedLetter = updatedBoard[self.currentRow][i].letter
			guard self.findKeyPosition(letter: guessedLetter) != nil else {
				completion(false)
				return
			}
			if self.lettersMatch(guessedLetter, letter) {
				continue
			} else if let matchIndex = remainingLetters.firstIndex(where: { $0 == self.comparisonKey(guessedLetter) }) {
				updatedBoard[self.currentRow][i].isCorrectLetter = true
				remainingLetters[matchIndex] = nil
			} else {
				updatedBoard[self.currentRow][i].isUsedButNotCorrect = true
			}
		}
		
		for i in updatedBoard[self.currentRow].indices {
			if updatedBoard[self.currentRow][i].isCorrectPosition {
				updatedBoard[self.currentRow][i].state = .correctPosition
			} else if updatedBoard[self.currentRow][i].isCorrectLetter {
				updatedBoard[self.currentRow][i].state = .correctLetter
			} else {
				updatedBoard[self.currentRow][i].state = .usedButNotCorrect
			}
		}
		
		self.board = updatedBoard
		
		completion(true)
	}
	
	func goThroughKeyboard(completion: @escaping (Bool) -> Void) {
		guard self.board.indices.contains(self.currentRow) else {
			completion(false)
			return
		}
		
		var updatedKeyboard = self.keyboard
		for i in self.board[self.currentRow].indices {
			guard let keyBoardPosition = self.findKeyPosition(letter: self.board[self.currentRow][i].letter) else {
				completion(false)
				return
			}
			let newState = self.board[self.currentRow][i].state
			let oldState = updatedKeyboard[keyBoardPosition.row][keyBoardPosition.col].state
			if keyboardStatePriority(newState) > keyboardStatePriority(oldState) {
				updatedKeyboard[keyBoardPosition.row][keyBoardPosition.col].state = newState
			}
		}

		self.pendingKeyboardUpdate = updatedKeyboard
		self.currentRow += 1
		self.currentIndex = 0
		completion(true)
	}
	
	func applyPendingKeyboardUpdate() {
		if let update = pendingKeyboardUpdate {
			pendingKeyboardUpdate = nil
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				if self.isGameOver {
					self.isAnimating = false
					for row in update.indices {
						for col in update[row].indices {
							if self.keyboard[row][col].state != update[row][col].state {
								self.keyboard[row][col].state = update[row][col].state
							}
						}
					}
				} else {
					withAnimation(.linear(duration: 0.1)) {
						for row in update.indices {
							for col in update[row].indices {
								if self.keyboard[row][col].state != update[row][col].state {
									self.keyboard[row][col].state = update[row][col].state
								}
							}
						}
						self.isAnimating = false
					}
				}
				if self.pendingGameCompletion != nil {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
						self.applyPendingGameCompletion()
					}
				}
			}
		}
	}

	func applyPendingGameCompletion() {
		if let gameCompletion = pendingGameCompletion {
			pendingGameCompletion = nil
			gameCompletion()
		}
	}

	private func keyboardStatePriority(_ state: LetterState) -> Int {
		switch state {
			case .correctPosition:
				return 3
			case .correctLetter:
				return 2
			case .usedButNotCorrect:
				return 1
			case .notUsed:
				return 0
		}
	}
	
	func useWord(word: String) {
		let playableWord = self.comparisonKey(word)
		for i in 0..<playableWord.count {
			self.board[self.currentRow][i].letter = String(playableWord[playableWord.index(playableWord.startIndex, offsetBy: i)])
		}
		self.currentIndex = playableWord.count
	}
	
	
	
	func getStreakEntity() -> DerivedStreakSummary? {
		let summary = GameRecordStreakCalculator.dailySummary(
			records: self.gameRecords,
			language: self.selectedLanguage,
			numberOfLetters: self.numberOfLetters
		)
		return summary.longestStreak > 0 || summary.currentStreak > 0 ? summary : nil
	}
	
	func getNormalStreakEntity() -> DerivedStreakSummary? {
		let summary = GameRecordStreakCalculator.normalSummary(
			records: self.gameRecords,
			language: self.selectedLanguage,
			numberOfLetters: self.numberOfLetters
		)
		return summary.longestStreak > 0 || summary.currentStreak > 0 ? summary : nil
	}
	
	func fixLanguageBasedOnLocale() {
		let pre = Locale.preferredLanguages[0]
		print("Preferred language: \(pre)")
		if pre == "no" || pre == "nb" || pre == "nn" || pre == "nb-NO" || pre == "nn-NO" {
			self.selectedLanguage = .norwegian
			self.language = .norwegian
			self.defaultLanguage = .norwegian
		} else if pre == "es" || pre == "es-ES" || pre == "es-MX" || pre == "es-AR" {
			self.selectedLanguage = .spanish
			self.language = .spanish
			self.defaultLanguage = .spanish
		} else if pre == "fr" || pre.hasPrefix("fr-") {
			self.selectedLanguage = .french
			self.language = .french
			self.defaultLanguage = .french
		} else if pre == "pl" || pre.hasPrefix("pl-") {
			self.selectedLanguage = .polish
			self.language = .polish
			self.defaultLanguage = .polish
		} else {
			self.selectedLanguage = .english
			self.language = .english
			self.defaultLanguage = .english
		}
	}
	
	
	
	func didTapSubmit() {
		if !self.isGameOver {
			let guessedWord = self.getWordFromCurrentRow()
			if wordIsValidForSubmitButton() {
				self.isAnimating = true
				self.shouldShowCelebrationGradient = false
				self.highlightBoardLetters() { success in
					if success {
						self.submittedWordWaitingForReveal = guessedWord
						self.finishSubmittedRowReveal()
					} else {
						self.submittedWordWaitingForReveal = nil
						self.isAnimating = false
					}
				}
				
			} else {
				if guessedWord.count == self.numberOfLetters {
					print("Det du gjettet var ikke et ord: \(guessedWord)")
				} else {
					print("Ikke nok bokstaver: \(guessedWord)")
				}
				
				self.isShaking = true
				withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.1, blendDuration: 0.1)) {
					self.isShaking = false
				}
			}
		}
	}
	
	func finishSubmittedRowReveal() {
		guard let guessedWord = self.submittedWordWaitingForReveal else {
			return
		}

		self.submittedWordWaitingForReveal = nil

		self.goThroughKeyboard() { success in
			guard success else {
				self.isAnimating = false
				return
			}

			let isWin = self.wordsMatch(self.word, guessedWord)
			let isLoss = !isWin && self.currentRow == self.board.count

			if isWin {
				print("Du vant!!")
				self.pendingGameCompletion = {
					self.completeGame(
						state: .won,
						message: String(format: NSLocalizedString("success_message", comment: "Success message with a word"), self.word)
					)
				}
			} else if isLoss {
				print("Du tapte: \(guessedWord), ordet var \(self.word)")
				self.pendingGameCompletion = {
					self.completeGame(
						state: .lost,
						message: String(format: NSLocalizedString("almost_message", comment: "Almost got the word message"), self.word)
					)
				}
			} else {
				print("Feil ord: \(guessedWord)")
			}
		}
	}
	
	private func completeGame(state: GameEndState, message: String) {
		self.didWinGame = state
		self.endDate = Date()
		self.message = message
		
		let completedStartDate = self.startDate
		let completedEndDate = self.endDate
		let completedGameMode = self.selectedGameMode
		let completedWord = self.word
		let completedLanguage = self.selectedLanguage
		let completedNumberOfLetters = self.numberOfLetters
		let completedNumberOfGuesses = self.currentRow
		let completedHintsUsed = self.hintsUsed
		let completedBoard = self.board
		
		self.isGameOver = true
		
		Task { @MainActor in
			try? await Task.sleep(nanoseconds: 1_000_000_000)
			
			self.addGameRecord(
				gameRecord: GameRecord(
					date: completedStartDate,
					state: state,
					mode: completedGameMode,
					word: completedWord,
					language: completedLanguage,
					numberOfLetters: completedNumberOfLetters,
					numberOfGuesses: completedNumberOfGuesses,
					maxRows: rowCount(for: completedNumberOfLetters),
					hintsUsed: completedHintsUsed,
					board: completedBoard,
					endDate: completedEndDate
				)
			)
			self.maybePromptForProAfterGameCompletion()
			
			if state == .won && completedGameMode == .dailyWord {
				self.maybePromptForNotificationsAfterFirstWin()
			}
			
			if completedGameMode == .dailyWord {
				self.fixReminderForDailyWord(language: completedLanguage, numberOfLetters: completedNumberOfLetters)
			}
			
			let currentStreak: Int
			if state == .lost {
				currentStreak = 0
			} else if completedGameMode == .dailyWord {
				currentStreak = GameRecordStreakCalculator.dailySummary(
					records: self.gameRecords,
					language: completedLanguage,
					numberOfLetters: completedNumberOfLetters
				).currentStreak
			} else {
				currentStreak = GameRecordStreakCalculator.normalSummary(
					records: self.gameRecords,
					language: completedLanguage,
					numberOfLetters: completedNumberOfLetters
				).currentStreak
			}
			
			AnalyticsManager.shared.logGameEndedEvent(
				word: completedWord,
				language: completedLanguage,
				numberOfLetters: completedNumberOfLetters,
				gameMode: completedGameMode,
				won: state == .won,
				attemptsNeeded: completedNumberOfGuesses,
				gameDurationSeconds: Int(completedEndDate.timeIntervalSince(completedStartDate)),
				currentStreak: currentStreak
			)
		}
	}
	
	func fixReminderForDailyWord() {
		self.fixReminderForDailyWord(language: self.selectedLanguage, numberOfLetters: self.numberOfLetters)
	}
	
	func fixReminderForDailyWord(language: LanguageSelection, numberOfLetters: Int) {
		guard let context = self.modelContext else {
			return
		}
		let reminders = NotificationManager.fetchReminders(context: context)
		for reminder in reminders {
			if reminder.language == language && reminder.numberOfLetters == numberOfLetters && reminder.isEnabled {
				NotificationManager.scheduleDailyWordReminder(reminder: reminder, context: context)
			}
		}
	}
	
	func wordIsValidForSubmitButton() -> Bool {
		if self.isGameOver {
			return true
		}
		
		if self.userWantsThePhraseNameBack && self.numberOfLetters == 5 && self.valid5LetterNames.contains(self.getWordFromCurrentRow()) {
			return true
		}
		let currentWord = self.getWordFromCurrentRow()
		if self.containsWord(currentWord, in: self.dailyWordsForCurrentLength) {
			return true
		}
		if self.containsWord(currentWord, in: self.expertWordsForCurrentLength) {
			return true
		}
		if self.containsWord(currentWord, in: self.blockedWords) {
			return true
		}
		return false
	}
	
	func getShareResult(row: Int, numberOfLetters: Int, date: Date, board: [[Letter]], timeUsedString: String = "") -> String {
		GameResultShareFormatter.shareText(
			row: row,
			numberOfLetters: numberOfLetters,
			maxRows: rowCount(for: numberOfLetters),
			date: date,
			board: board,
			timeUsedString: timeUsedString
		)
	}
	
	func getTimeUsedString(startDate: Date, endDate: Date) -> String {
		GameResultShareFormatter.timeUsedString(startDate: startDate, endDate: endDate)
	}
	
	
	func resetBoard(animated: Bool = false) {
		self.normalizeSelectedOptions()
		let shouldAnimateReset = animated && !self.board.isEmpty
		self.isResettingBoard = shouldAnimateReset
		var noAnimation = Transaction()
		noAnimation.disablesAnimations = true
		withTransaction(noAnimation) {
			self.board = []
			self.keyboard = []
			self.fixStartBoard()
			self.fixKeyboard()
		}
		self.getRandomWord()
		self.currentRow = 0
		self.currentIndex = 0
		self.hintsUsed = 0
		self.submittedWordWaitingForReveal = nil
		self.message = ""
		self.isGameOver = false
		self.shouldShowCelebrationGradient = false
		self.hasSharedResult = false
		self.didWinGame = .lost
		self.shouldPromptForNotificationsAfterFirstWin = false
		self.shouldPromptForProAfterGameCompletion = false
		self.language = self.selectedLanguage
		self.gameMode = self.selectedGameMode
		self.gameExpertModeEnabled = self.isExpertModeEnabled
		self.resetFilters()
		self.startDate = Date()
		
		if shouldAnimateReset {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
				self.isResettingBoard = false
			}
		} else {
			self.isResettingBoard = false
		}
	}
	
	func startNewGameFromGameOver() {
		self.selectedGameMode = .normal
		self.resetBoard(animated: true)
	}
	
	func restartCurrentGame() {
		if self.selectedGameMode == .normal && !self.isGameOver && (self.currentRow > 0 || self.currentIndex > 0) {
			self.endDate = Date()
			self.addGameRecord(
				gameRecord: GameRecord(
					date: self.startDate,
					state: .lost,
					mode: self.selectedGameMode,
					word: self.word,
					language: self.selectedLanguage,
					numberOfLetters: self.numberOfLetters,
					numberOfGuesses: self.currentRow,
					maxRows: rowCount(for: self.numberOfLetters),
					hintsUsed: self.hintsUsed,
					board: self.board,
					endDate: self.endDate
				)
			)
		}
		
		self.resetBoard(animated: true)
	}
	
	func resetFilters() {
		self.isFilteringSearchWord = true
		self.searchedWord = ""
		self.isFilteringStartWith = false
		self.startsWithFilter = ""
		self.isFilteringEndsWith = false
		self.endsWithFilter = ""
		self.isFilteringIncludedLetters = false
		self.isFilteringExcludeLetters = false
		if !selectedIncludedLetters.isEmpty {
			self.selectedIncludedLetters.removeAll()
		}
		if !selectedExcludedLetters.isEmpty {
			self.selectedExcludedLetters.removeAll()
		}
	}

	func applyGameInfoToFilters() {
		var included: Set<String> = []
		var excluded: Set<String> = []

		for row in self.keyboard {
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

		let wordLength = self.numberOfLetters
		var correctPositions = Array(repeating: "", count: wordLength)
		for row in self.board {
			for (index, letter) in row.enumerated() where letter.state == .correctPosition && index < wordLength {
				correctPositions[index] = letter.letter
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

		self.searchedWord = ""
		self.startsWithFilter = startsWith
		self.isFilteringStartWith = !startsWith.isEmpty
		self.endsWithFilter = endsWith
		self.isFilteringEndsWith = !endsWith.isEmpty
		self.selectedIncludedLetters = included.sorted()
		self.isFilteringIncludedLetters = !included.isEmpty
		self.selectedExcludedLetters = excluded.sorted()
		self.isFilteringExcludeLetters = !excluded.isEmpty
	}
	
	private func maybePromptForNotificationsAfterFirstWin() {
		let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
		guard !notificationsEnabled else { return }
		
		let winsKey = "notificationPromptWinCount"
		let nextPromptKey = "notificationPromptNextWinThreshold"
		let currentWins = UserDefaults.standard.integer(forKey: winsKey) + 1
		UserDefaults.standard.set(currentWins, forKey: winsKey)
		
		let nextPromptThreshold = UserDefaults.standard.object(forKey: nextPromptKey) as? Int ?? 1
		guard currentWins >= nextPromptThreshold else { return }
		
		self.shouldPromptForNotificationsAfterFirstWin = true
	}

	func maybePromptForProAfterGameCompletion() {
		let promptDismissedKey = "proPromptAfterGamesDismissed"
		guard !UserDefaults.standard.bool(forKey: promptDismissedKey) else { return }

		let completedGamesKey = "proPromptCompletedGamesCount"
		let promptThreshold = 15
		let completedGames = max(UserDefaults.standard.integer(forKey: completedGamesKey) + 1, self.gameRecords.count)
		UserDefaults.standard.set(completedGames, forKey: completedGamesKey)

		guard completedGames >= promptThreshold else { return }

		self.shouldPromptForProAfterGameCompletion = true
		UserDefaults.standard.set(true, forKey: promptDismissedKey)
	}
	
	func fetchGameRecords() {
		if let gameRecordManager = self.gameRecordManager {
			self.gameRecords = gameRecordManager.fetchGameRecords()
			print("Fetched game records: \(self.gameRecords)")
			for gameRecord in self.gameRecords {
				print("Game Record ID: \(gameRecord.id), Game Record: \(gameRecord.gameRecord)")
			}
		} else {
			print("GameRecordManager is not initialized")
		}
	}
	
	func addGameRecord(gameRecord: GameRecord) {
		var cetCalendar = Calendar(identifier: .gregorian)
		cetCalendar.timeZone = TimeZone(identifier: "CET")!
		if let gameRecordManager = self.gameRecordManager {
			for record in self.gameRecords {
				if cetCalendar.isDate(record.gameRecord.date, inSameDayAs: gameRecord.date) && record.gameRecord.mode == gameRecord.mode && record.gameRecord.language == gameRecord.language && record.gameRecord.numberOfLetters == gameRecord.numberOfLetters && record.gameRecord.word == gameRecord.word {
					print("Game record for this date, mode, language, and number of letters already exists. Not adding duplicate.")
					return
				}
			}
			gameRecordManager.addGameRecord(gameRecord: gameRecord)
			
			self.gameRecords = gameRecordManager.fetchGameRecords()
		}
	}
	
	func deleteGameRecord(_ gameRecordEntity: GameRecordEntity) {
		if let gameRecordManager = self.gameRecordManager {
			gameRecordManager.deleteGameRecords(gameRecordEntity)
			self.fetchGameRecords()
		}
	}
	
	func setDefaultValues() {
		self.selectedLanguage = self.defaultLanguage
		self.numberOfLetters = self.defaultNumberOfLetters
		self.normalizeSelectedOptions()
	}
	
	
	// MARK: - Hints
	func getHint() {
		var foundKey: Bool = false
		for (index, row) in self.keyboard.enumerated() {
			for (index2, key) in row.enumerated() {
				if key.state == .notUsed && self.wordContainsComparableLetter(key.letter) {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
						withAnimation(.easeIn(duration: 0.4)) {
							self.keyboard[index][index2].state = .correctLetter
						}
					}
					self.hintsUsed += 1
					print("Hint: \(key.letter)")
					foundKey = true
					break
				}
			}
			if foundKey {
				break
			}
		}
		if foundKey {
			return
		}
	}
	
	func isHintAvailable() -> Bool {
		if self.numberOfLetters == 1 {
			return false
		}
		var keysWithCorrectState: [KeyBoardLetter] = []
		for row in self.keyboard {
			for key in row {
				if key.state == .correctLetter || key.state == .correctPosition {
					keysWithCorrectState.append(key)
				}
			}
		}
		return keysWithCorrectState.count != self.numberOfLetters
	}
	
	
	
	
	
	// MARK: - ADS
	func loadAd() async {
		guard rewardedAd == nil, !isLoadingAd else { return }
		isLoadingAd = true
		defer { isLoadingAd = false }
		do {
			//			#warning("Replace the ad unit ID with your own ad unit ID when deploying to production.")
			
#if targetEnvironment(simulator) // DEBUG
			self.rewardedAd = try await RewardedAd.load(
				with: "ca-app-pub-3940256099942544/1712485313", request: Request())  // ca-app-pub-7619403750703078/7682260846
#else
			self.rewardedAd = try await RewardedAd.load(
				with: "ca-app-pub-7619403750703078/7682260846", request: Request()) // ca-app-pub-3940256099942544/1712485313
#endif
			AnalyticsManager.shared.logDidLoadRewardedAdEvent(word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, gameMode: self.gameMode)
			self.rewardedAd?.fullScreenContentDelegate = self
			await MainActor.run {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					withAnimation {
						self.shouldShowAdButton = true
					}
				}
			}
			print("Rewarded ad loaded.")
			NotificationCenter.default.post(name: .rewardedAdDidLoad, object: nil)
		} catch {
			print("Failed to load rewarded ad with error: \(error.localizedDescription)")
			await MainActor.run {
				withAnimation {
					self.shouldShowAdButton = false
				}
			}
		}
	}
	
	func showAd() {
		guard let rewardedAd = rewardedAd else {
			print("Ad wasn't ready.")
			return
		}
		AnalyticsManager.shared.logDidTapWatchRewardedAdEvent(word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, gameMode: self.gameMode)
		rewardedAd.present(from: nil) {
			let reward = rewardedAd.adReward
			print("Reward amount: \(reward.amount)")
			self.getHint()
			print("I got a Hint!!!!!!")
			
		}
	}
	
	func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
		print("\(#function) called")
	}
	
	func adDidRecordClick(_ ad: FullScreenPresentingAd) {
		print("\(#function) called")
	}
	
	func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
		print("\(#function) called")
		self.rewardedAd = nil
		self.hasLoadedAd = false
		self.shouldShowAdButton = false
		Task {
			await self.loadAd()
			self.hasLoadedAd = true
		}
	}
	
	func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
		print("\(#function) called")
	}
	
	func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
		print("\(#function) called")
	}
	
	func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
		print("\(#function) called")
		self.rewardedAd = nil
		self.hasLoadedAd = false
		Task {
			await self.loadAd()
			self.hasLoadedAd = true
		}
	}
	
}
