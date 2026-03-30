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
final class AppManager: NSObject, ObservableObject, FullScreenContentDelegate {
	@AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
	@AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
	@AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
	
	var gameRecords: [GameRecordEntity] = []
	var modelContext: ModelContext?
	var gameRecordManager: GameRecordManager?
	
	
	@Published var selectedLanguage: LanguageSelection = .norwegian
	@Published var language: LanguageSelection = .norwegian
	@Published var gameMode: GameMode = .normal
	@Published var selectedGameMode: GameMode = .normal
	@Published var numberOfLetters: Int = 5
	@Published var word: String = ""
	@Published var words: Words?
	@Published var dailyWords: Words?
	@Published var board: [[Letter]] = []
	@Published var keyboard: [[KeyBoardLetter]] = []
	@Published var currentRow = 0
	@Published var currentIndex = 0
	@Published var isGameOver: Bool = false
	var message: String = ""
	@Published var isAnimating: Bool = false
	@Published var isShaking: Bool = false
	@Published var submitOpacity: Double = 0.5
	@Published var shouldShowAdButton: Bool = false
	@Published var hasLoadedAd: Bool = false
	var startDate: Date = Date()
	var endDate: Date = Date()
	@Published var hasSharedResult: Bool = false
	@Published var didWinGame: GameEndState = .lost
	@Published var searchedWord: String = ""
	@Published var isSearching: Bool = false
	
	@Published var isFilteringSearchWord: Bool = true
	@Published var isFilteringStartWith: Bool = false
	@Published var startsWithFilter: String = ""
	@Published var isFilteringEndsWith: Bool = false
	@Published var endsWithFilter: String = ""
	@Published var isFilteringExcludeLetters: Bool = false
	@Published var isFilteringIncludedLetters: Bool = false
	@Published var selectedExcludedLetters: [String] = []
	@Published var selectedIncludedLetters: [String] = []
	@Published var dailyWordHasBeenPlayed: Bool = false
	
	private let valid5LetterNames: [String] = ["SIMEN", "LUKAS", "JONAS", "HELLE", "MARTE", "ROHIN", "HILDE", "TROND", "JOMAR", "DAHLE", "SYVER", "BØRGE", "ØLARS", "HSFKJ"]
	private let valid6LetterNames: [String] = ["MARTIN", "MARIUS", "TOBIAS", "DANIEL", "HENRIK", "KRISTIN"]
	private let valid8LetterNames: [String] = ["JOHANNES", "LEONARDO", "TORBJØRN"]
	
	let gradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
	let shadowGradient = LinearGradient(colors: [.orange, .yellow, .yellow, .yellow, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
	
	private var hintsUsed: Int = 0
	
	private var rewardedAd: RewardedAd?
	
	func getWords() {
		if let words = WordleDataManager.shared.loadWordsFromJSONFile(selectedLanguage: selectedLanguage) {
			self.words = words
			if self.numberOfLetters == 5 && self.userWantsThePhraseNameBack {
				self.words?.wordGroups["5"]?.append(contentsOf: self.valid5LetterNames)
			} else if self.numberOfLetters == 6 && self.userWantsThePhraseNameBack {
				self.words?.wordGroups["6"]?.append(contentsOf: self.valid6LetterNames)
			} else if self.numberOfLetters == 8 && self.userWantsThePhraseNameBack {
				self.words?.wordGroups["8"]?.append(contentsOf: self.valid8LetterNames)
			}
			
			if let dailyWords = WordleDataManager.shared.loadDailyWordsFromJSONFile(selectedLanguage: selectedLanguage) {
				self.dailyWords = dailyWords
			}
			self.resetBoard()
		}
	}
	
	func fixStartBoard() {
		self.board = []
		var listOfEmtpyStrings: [Letter] = []
		for _ in 1...self.numberOfLetters {
			let letter = Letter()
			listOfEmtpyStrings.append(letter)
		}
		for _ in 0..<rowCount(for: self.numberOfLetters) {
			self.board.append(listOfEmtpyStrings)
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
		
		if let count = dailyWords?.wordGroups["\(numberOfLetters)"]?.count {
			let dailyWordIndex = daysSinceStart % count
			return self.dailyWords?.wordGroups["\(numberOfLetters)"]?[dailyWordIndex] ?? "PIANO"
		} else {
			return "PIANO"
		}
	}
	
	func searchableWords() -> [String] {
		let wordsForLength = self.words?.wordGroups["\(self.numberOfLetters)"] ?? []
		let blockedWords = Set(self.words?.blockedWords ?? [])
		
		guard !blockedWords.isEmpty else {
			return wordsForLength
		}
		
		return wordsForLength.filter { !blockedWords.contains($0) }
	}
	
	private func getRandomNormalModeWord() -> String {
		let availableWords = self.searchableWords()
		if let randomWord = availableWords.randomElement() {
			return randomWord
		}
		
		return self.words?.wordGroups["\(numberOfLetters)"]?.randomElement() ?? "PIANO"
	}
	
	
	
	
	func getDefinition(for word: String, completion: @escaping ([ProcessedWord]) -> Void) {
		WordleDataManager.shared.fetchNorwegianDefinition(for: word) { result in
			DispatchQueue.main.async {
				switch result {
					case .success(let processedWords):
						completion(processedWords)
					case .notFound, .networkError:
						completion([])
				}
			}
		}
	}
	
	func fixKeyboard() {
		var newKeyboard: [[KeyBoardLetter]] = []
		var keyBoardCharacters: [[String]] = []
		if self.selectedLanguage == .english {
			keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
		} else if self.selectedLanguage == .norwegian {
			keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Å"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ø", "Æ"], ["Z", "X", "C", "V", "B", "N", "M"]]
		} else {
			keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ñ"], ["Z", "X", "C", "V", "B", "N", "M"]]
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
	
	func isReadyToSubmit() -> Bool {
		return self.board[self.currentRow].count == self.numberOfLetters
	}
	
	func findKeyPosition(letter: String) -> (row: Int, col: Int)? {
		for (rowIndex, row) in keyboard.enumerated() {
			if let colIndex = row.firstIndex(where: { $0.letter == letter }) {
				return (row: rowIndex, col: colIndex)
			}
		}
		return nil
	}
	
	
	
	func highlightBoardLetters(completion: @escaping (Bool) -> Void) {
		let dispatchGroup = DispatchGroup()
		var changableWord = self.word
		for i in 0..<self.board[self.currentRow].count {
			let letterIndex = self.word.index(self.word.startIndex, offsetBy: i)
			let letter = String(self.word[letterIndex])
			guard let keyBoardPosition = self.findKeyPosition(letter: self.board[self.currentRow][i].letter) else {
				completion(false)
				return
			}
			if self.board[self.currentRow][i].letter == letter {
				self.board[self.currentRow][i].isCorrectPosition = true
				self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isCorrectPosition = true
				if let index = changableWord.firstIndex(of: Character(letter)) {
					changableWord.remove(at: index)
					
				} else {
					changableWord = changableWord.replacingOccurrences(of: self.board[self.currentRow][i].letter, with: "")
				}
			}
		}
		
		for i in 0..<self.board[self.currentRow].count {
			let letterIndex = self.word.index(self.word.startIndex, offsetBy: i)
			let letter = String(self.word[letterIndex])
			guard let keyBoardPosition = self.findKeyPosition(letter: self.board[self.currentRow][i].letter) else {
				completion(false)
				return
			}
			if self.board[self.currentRow][i].letter == letter {
				print("Correct position: \(self.board[self.currentRow][i].letter), i: \(i), letterIndex: \(letterIndex.utf16Offset(in: self.word))")
				
			} else if changableWord.contains(self.board[self.currentRow][i].letter) {
				print("Correct letter but wrong position: \(self.board[self.currentRow][i].letter), i: \(i), letterIndex: \(letterIndex.utf16Offset(in: self.word))")
				self.board[self.currentRow][i].isCorrectLetter = true
				self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isCorrectLetter = true
				if let index = changableWord.firstIndex(of: Character(self.board[self.currentRow][i].letter)) {
					print("index1: \(index.utf16Offset(in: self.word)), letter: \(self.board[self.currentRow][i].letter)")
					print("changanbleWord66: \(changableWord), i: \(i), index: \(index)")
					let char = changableWord.remove(at: index)
					
					print("changanbleWord4: \(changableWord), i: \(i), index: \(index.utf16Offset(in: self.word)), char: \(char), letter: \(letter), letter2: \(self.board[self.currentRow][letterIndex.utf16Offset(in: self.word)].letter)")
					
				} else {
					changableWord = changableWord.replacingOccurrences(of: self.board[self.currentRow][i].letter, with: "")
				}
				
				
			} else {
				self.board[self.currentRow][i].isUsedButNotCorrect = true
				self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isUsedButNotCorrect = true
				
				if let index = changableWord.firstIndex(of: Character(self.board[self.currentRow][i].letter)) {
					print("index2: \(index.utf16Offset(in: self.word)), letter: \(self.board[self.currentRow][i].letter)")
					print("changanbleWord77: \(changableWord), i: \(i), index: \(index)")
					let char = changableWord.remove(at: index)
					
					print("changanbleWord8: \(changableWord), i: \(i), index: \(index), char: \(char), letter: \(letter), letter2: \(self.board[self.currentRow][i].letter)")
					
				} else {
					changableWord = changableWord.replacingOccurrences(of: self.board[self.currentRow][i].letter, with: "")
				}
			}
			
		}
		
		dispatchGroup.enter()
		self.goThroughBoard() { success in
			if success {
				print("goThroughBoard completed successfully.")
			} else {
				print("goThroughBoard failed.")
			}
			dispatchGroup.leave()
			
		}
		
		dispatchGroup.notify(queue: .main) {
			print("Both goThroughBoard and goThroughKeyboard are finished.")
			completion(true)
		}
	}
	
	
	func goThroughBoard(completion: @escaping (Bool) -> Void) {
		for i in 0...self.board[self.currentRow].count-1 {
			DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
				let letter = self.board[self.currentRow][i]
				print("letter: \(letter.letter)")
				if letter.isCorrectPosition {
					self.board[self.currentRow][i].state = .correctPosition
				} else if letter.isCorrectLetter {
					self.board[self.currentRow][i].state = .correctLetter
				} else {
					self.board[self.currentRow][i].state = .usedButNotCorrect
				}
				
				
				
				if i == self.board[self.currentRow].count-1 {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
						self.goThroughKeyboard() { success in
							if success {
								print("goThroughKeyboard completed successfully.")
							} else {
								print("goThroughKeyboard failed.")
							}
							self.isAnimating = false
							completion(true)
							
						}
						
					}
				}
			}
		}
	}
	
	func goThroughKeyboard(completion: @escaping (Bool) -> Void) {
		for i in 0...self.board[self.currentRow].count-1 {
			guard let keyBoardPosition = self.findKeyPosition(letter: self.board[self.currentRow][i].letter) else {
				return
			}
			DispatchQueue.main.async {
				if self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isCorrectPosition {
					self.keyboard[keyBoardPosition.row][keyBoardPosition.col].state = .correctPosition
				} else if self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isCorrectLetter {
					self.keyboard[keyBoardPosition.row][keyBoardPosition.col].state = .correctLetter
				} else {
					self.keyboard[keyBoardPosition.row][keyBoardPosition.col].state = .usedButNotCorrect
				}
				
				if i == self.board[self.currentRow].count-1 {
					self.currentRow += 1
					self.currentIndex = 0
					
				}
			}
			
			
		}
		completion(true)
	}
	
	func flipCard(rowIndex: Int, colIndex: Int) {
		withAnimation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
			.speed(1)
			.delay(0)) {
				self.board[rowIndex][colIndex].degreee = 360
			}
	}
	
	func animateTappedLetter(rowIndex: Int, colIndex: Int) {
		self.board[rowIndex][colIndex].scale = 1.1
		withAnimation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
			.speed(1)
			.delay(0)) {
				self.board[rowIndex][colIndex].scale = 1.0
				
			}
		
	}
	
	func animateRemovingLetter(rowIndex: Int, colIndex: Int) {
		self.board[rowIndex][colIndex].scale = 0.87
		withAnimation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
			.speed(1)
			.delay(0)) {
				self.board[rowIndex][colIndex].scale = 1.0
				
			}
		
	}
	
	func useWord(word: String) {
		for i in 0..<word.count {
			self.board[self.currentRow][i].letter = String(word[word.index(word.startIndex, offsetBy: i)])
		}
		self.currentIndex = word.count
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
				self.highlightBoardLetters() { success in
					if success {
						if self.word == guessedWord {
							print("Du vant!!")
							withAnimation {
								self.isGameOver = true
							}
							self.didWinGame = .won
							self.endDate = Date()
							self.addGameRecord(gameRecord: GameRecord(date: self.startDate, state: .won, mode: self.selectedGameMode, word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, numberOfGuesses: self.currentRow, maxRows: rowCount(for: self.numberOfLetters), hintsUsed: self.hintsUsed, board: self.board, endDate: self.endDate))
							if self.selectedGameMode == .dailyWord {
								self.fixReminderForDailyWord()
								AnalyticsManager.shared.logGameEndedEvent(word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, gameMode: self.selectedGameMode, won: true, attemptsNeeded: self.currentRow, gameDurationSeconds: Int(self.endDate.timeIntervalSince(self.startDate)), currentStreak: self.getStreakEntity()?.currentStreak ?? 0)
							} else {
								AnalyticsManager.shared.logGameEndedEvent(word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, gameMode: self.selectedGameMode, won: true, attemptsNeeded: self.currentRow, gameDurationSeconds: Int(self.endDate.timeIntervalSince(self.startDate)), currentStreak: self.getNormalStreakEntity()?.currentStreak ?? 0)
							}
							self.message = String(format: NSLocalizedString("success_message", comment: "Success message with a word"), self.word)
							
							return
						} else {
							if self.currentRow == self.board.count {
								print("Du tapte: \(guessedWord), ordet var \(self.word)")
								withAnimation {
									self.isGameOver = true
								}
								self.didWinGame = .lost
								self.endDate = Date()
								self.addGameRecord(gameRecord: GameRecord(date: self.startDate, state: .lost, mode: self.selectedGameMode, word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, numberOfGuesses: self.currentRow, maxRows: rowCount(for: self.numberOfLetters), hintsUsed: self.hintsUsed, board: self.board, endDate: self.endDate))
								if self.selectedGameMode == .dailyWord {
									self.fixReminderForDailyWord()
								}
								self.message = String(format: NSLocalizedString("almost_message", comment: "Almost got the word message"), self.word)
								AnalyticsManager.shared.logGameEndedEvent(word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, gameMode: self.selectedGameMode, won: false, attemptsNeeded: self.currentRow, gameDurationSeconds: Int(self.endDate.timeIntervalSince(self.startDate)), currentStreak: 0)
								
							} else {
								print("Feil ord: \(guessedWord)")
							}
						}
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
	
	func fixReminderForDailyWord() {
		guard let context = self.modelContext else {
			return
		}
		let reminders = NotificationManager.fetchReminders(context: context)
		for reminder in reminders {
			if reminder.language == self.selectedLanguage && reminder.numberOfLetters == self.numberOfLetters && reminder.isEnabled {
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
		let wordIsValid = self.words?.wordGroups["\(self.numberOfLetters)"]?.contains(self.getWordFromCurrentRow()) ?? false
		if wordIsValid {
			return true
		}
		return false
	}
	
	func getShareResult(row: Int, numberOfLetters: Int, date: Date, board: [[Letter]], timeUsedString: String = "") -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none
		dateFormatter.timeZone = TimeZone(identifier: "CET")
		
		let numberOfRows = rowCount(for: numberOfLetters)
		
		var letterString = String(format: NSLocalizedString("share_letter", comment: "Letter"), numberOfLetters)
		if numberOfLetters > 1 {
			letterString = String(format: NSLocalizedString("share_letters", comment: "Letters"), numberOfLetters)
		}
		
		let rowString = String(format: NSLocalizedString("share_row", comment: "Row"))
		let usedString = String(format: NSLocalizedString("share_used", comment: "Used"))
		
		
		var shareText = "Wordly \(dateFormatter.string(from: date)), \(letterString), \(row)/\(numberOfRows) \(rowString)\(timeUsedString != "" ? ", \(timeUsedString) \(usedString)" : ""):\n"
		
		var shouldBreak: Bool = false
		for row in board {
			for letter in row {
				switch letter.state {
					case .correctPosition:
						shareText += "🟩"
					case .correctLetter:
						shareText += "🟧"
					case .usedButNotCorrect:
						shareText += "⬜️"
					default:
						shouldBreak = true
						break
				}
			}
			if shouldBreak {
				break
			}
			shareText += "\n"
			
		}
		return shareText
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
	
	
	func resetBoard() {
		self.board = []
		self.keyboard = []
		self.fixStartBoard()
		self.fixKeyboard()
		self.getRandomWord()
		self.currentRow = 0
		self.currentIndex = 0
		self.hintsUsed = 0
		self.message = ""
		withAnimation {
			self.isGameOver = false
		}
		self.hasSharedResult = false
		self.didWinGame = .lost
		self.language = self.selectedLanguage
		self.gameMode = self.selectedGameMode
		self.resetFilters()
		self.startDate = Date()
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
	}
	
	
	// MARK: - Hints
	func getHint() {
		var foundKey: Bool = false
		for (index, row) in self.keyboard.enumerated() {
			for (index2, key) in row.enumerated() {
				if key.state == .notUsed && self.word.contains(key.letter) {
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
	}
	
}
