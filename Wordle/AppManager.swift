//
//  AppManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI

final class AppManager: ObservableObject {
    @AppStorage("dailyWord: 1") private var dailyWord1: Date?
    @AppStorage("dailyWord: 2") private var dailyWord2: Date?
    @AppStorage("dailyWord: 3") private var dailyWord3: Date?
    @AppStorage("dailyWord: 4") private var dailyWord4: Date?
    @AppStorage("dailyWord: 5") private var dailyWord5: Date?
    @AppStorage("dailyWord: 6") private var dailyWord6: Date?
    @AppStorage("dailyWord: 7") private var dailyWord7: Date?
    @AppStorage("dailyWord: 8") private var dailyWord8: Date?
    
    @Published var selectedLanguage: LanguageSelection = .norwegian
    @Published var gameMode: GameMode = .normal
    @Published var numberOfLetters: Int = 5
    @Published var word: String = ""
    @Published var words: Words?
    @Published var board: [[Letter]] = []
    @Published var keyboard: [[KeyBoardLetter]] = []
    @Published var currentRow = 0
    @Published var currentIndex = 0
    @Published var isGameOver: Bool = false
    @Published var message: String = ""
    @Published var didTapSubmitButton: Bool = false
    @Published var didTapBackButton: Bool = false
    @Published var didTapResetButton: Bool = false
    @Published var didTapNewGameButton: Bool = false
    @Published var didTapPlaySomethingElseButton: Bool = false
    @Published var didTapPlayDailyWordButton: Bool = false
    @Published var didTapFakePlayDailyWordButton: Bool = false
    @Published var didTapPlayNormalButton: Bool = false
    @Published var isShowingAlreadyPlayedAlert: Bool = false
    @Published var alertItem: AlertItem?
    @Published var activeAlert: ActiveAlert = .none
    @Published var isShowingCurrentDefinition: Bool = false
    @Published var searchedWord: String = ""
    @Published var isAnimating: Bool = false
    @Published var dailyWords: Words?
    
    
    func getWords() {
        if let words = WordleDataManager.shared.loadWordsFromJSONFile(selectedLanguage: selectedLanguage) {
            self.words = words
            self.resetBoard()
            
        }
        
        if let dailyWords = WordleDataManager.shared.loadDailyWordsFromJSONFile(selectedLanguage: selectedLanguage) {
            self.dailyWords = dailyWords
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
        if self.numberOfLetters > 5 {
            for _ in 0...self.numberOfLetters {
                self.board.append(listOfEmtpyStrings)
            }
        } else {
            for _ in 0...5 {
                self.board.append(listOfEmtpyStrings)
            }
        }
    }
    
    func updatePlayedDailyWord() {
        switch self.numberOfLetters {
            case 1:
                dailyWord1 = Date()
            case 2:
                dailyWord2 = Date()
            case 3:
                dailyWord3 = Date()
            case 4:
                dailyWord4 = Date()
            case 5:
                dailyWord5 = Date()
            case 6:
                dailyWord6 = Date()
            case 7:
                dailyWord7 = Date()
            case 8:
                dailyWord8 = Date()
                
            default:
                print("This should never happen: \(self.numberOfLetters)")
        }
    }
    
    func checkIfDailyWordIsPlayed() -> Bool {
        switch self.numberOfLetters {
            case 1:
                return checkDaysSinceDateIsLessThan1(dailyWord1)
            case 2:
                return checkDaysSinceDateIsLessThan1(dailyWord2)
            case 3:
                return checkDaysSinceDateIsLessThan1(dailyWord3)
            case 4:
                return checkDaysSinceDateIsLessThan1(dailyWord4)
            case 5:
                return checkDaysSinceDateIsLessThan1(dailyWord5)
            case 6:
                return checkDaysSinceDateIsLessThan1(dailyWord6)
            case 7:
                return checkDaysSinceDateIsLessThan1(dailyWord7)
            case 8:
                return checkDaysSinceDateIsLessThan1(dailyWord8)
                
            default:
                print("This should never happen: \(self.numberOfLetters)")
        }
        return false
    }
    
    func checkDaysSinceDateIsLessThan1(_ date: Date?) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        if let date {
            let daysSinceStart = calendar.dateComponents([.day], from: date, to: currentDate).day!
            if daysSinceStart < 1 {
                return true
            }
        }
        return false
    }
    
    
    func getRandomWord() {
        if gameMode == .normal {
            self.word = self.words?.wordGroups["\(numberOfLetters)"]?.randomElement() ?? ""
//            self.word = "VENNE"
            print("Ordet er \(self.word)")
        } else {
            self.word = self.getDailyWord()
            print("Ordet er \(self.word)")
            
        }
        
//        if let words = self.words?.wordGroups["\(numberOfLetters)"] {
//            print("trust!")
//            self.shuffeledWords = words.shuffled()
//            for word in shuffeledWords {
//                if word == shuffeledWords.last {
//                    print("\"\(word)\"")
//                } else {
//                    print("\"\(word)\",")
//                }
//                
//            }
//        }
        
        
        
        
        
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
    
    func getDefinition(for word: String, completion: @escaping ([ProcessedWord]) -> Void) {
        var processedWords: [ProcessedWord] = []
        WordleDataManager.shared.fetchArticleIDs(for: word) { articleIDs in
            guard let articleIDs = articleIDs else {
                DispatchQueue.main.async {
                    completion(processedWords)
                }
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for articleID in articleIDs {
                dispatchGroup.enter()
                WordleDataManager.shared.fetchArticleDetails(articleID: articleID) { fetchedProcessedWord in
                    if let fetchedProcessedWord {
                        DispatchQueue.main.async {
                            processedWords.append(fetchedProcessedWord)
                        }
                    }
                    dispatchGroup.leave()
                }
                
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(processedWords)
                
            }
        }
    }
    
    func fixKeyboard() {
        var newKeyboard: [[KeyBoardLetter]] = []
        var keyBoardCharacters: [[String]] = []
        if self.selectedLanguage == .english {
            keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], ["A", "S", "D", "F", "G", "H", "J", "K", "L"], ["Z", "X", "C", "V", "B", "N", "M"]]
        } else {
            keyBoardCharacters = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Å"], ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ø", "Æ"], ["Z", "X", "C", "V", "B", "N", "M"]]
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
    
    
    
    func highlightBoardLetters() -> Bool {
        var changableWord = self.word
        for i in 0..<self.board[self.currentRow].count {
            let letterIndex = self.word.index(self.word.startIndex, offsetBy: i)
            let letter = String(self.word[letterIndex])
            guard let keyBoardPosition = self.findKeyPosition(letter: self.board[self.currentRow][i].letter) else {
                return false
            }
            if self.board[self.currentRow][i].letter == letter {
                self.board[self.currentRow][i].isCorrectPosition = true
                self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isCorrectPosition = true
                if let index = changableWord.firstIndex(of: Character(letter)) {
//                    print("changanbleWord55: \(changableWord), i: \(i), index: \(index)")
                    changableWord.remove(at: index)
//                    print("changanbleWord: \(changableWord), i: \(i), index: \(index)")
                    
                } else {
                    changableWord = changableWord.replacingOccurrences(of: self.board[self.currentRow][i].letter, with: "")
//                    print("changanbleWord2: \(changableWord), i: \(i)")
                }
            }
            
        }
        
        for i in 0..<self.board[self.currentRow].count {
            let letterIndex = self.word.index(self.word.startIndex, offsetBy: i)
            let letter = String(self.word[letterIndex])
            guard let keyBoardPosition = self.findKeyPosition(letter: self.board[self.currentRow][i].letter) else {
                return false
            }
            if self.board[self.currentRow][i].letter == letter {
                print("Correct position: \(self.board[self.currentRow][i].letter), i: \(i), letterIndex: \(letterIndex.utf16Offset(in: self.word))")
            
            } else if changableWord.contains(self.board[self.currentRow][i].letter) {
                print("Correct letter but wrong position: \(self.board[self.currentRow][i].letter), i: \(i), letterIndex: \(letterIndex.utf16Offset(in: self.word))")
                self.board[self.currentRow][i].isCorrectLetter = true
                self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isCorrectLetter = true
                if let index = changableWord.firstIndex(of: Character(self.board[self.currentRow][i].letter)) {
//                    print("changanbleWord66: \(changableWord), i: \(i), index: \(index)")
//                    let char = changableWord.remove(at: index)
                    
//                    print("changanbleWord4: \(changableWord), i: \(i), index: \(index.utf16Offset(in: self.word)), char: \(char), letter: \(letter), letter2: \(self.board[self.currentRow][letterIndex.utf16Offset(in: self.word)].letter)")
                    
                } else {
                    changableWord = changableWord.replacingOccurrences(of: self.board[self.currentRow][i].letter, with: "")
//                    print("changanbleWord3: \(changableWord), i: \(i)")
                }
                
                
            } else {
                self.board[self.currentRow][i].isUsedButNotCorrect = true
                self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isUsedButNotCorrect = true
//                print("wrong letter: \(self.board[self.currentRow][i].letter), i: \(i), letterIndex: \(letterIndex.utf16Offset(in: self.word)), letter: \(letter), changeableWord: \(changableWord)")
                
                if let index = changableWord.firstIndex(of: Character(self.board[self.currentRow][i].letter)) {
//                    print("changanbleWord77: \(changableWord), i: \(i), index: \(index)")
//                    let char = changableWord.remove(at: index)
                    
//                    print("changanbleWord8: \(changableWord), i: \(i), index: \(index), char: \(char), letter: \(letter), letter2: \(self.board[self.currentRow][i].letter)")
                    
                } else {
                    changableWord = changableWord.replacingOccurrences(of: self.board[self.currentRow][i].letter, with: "")
//                    print("changanbleWord9: \(changableWord), i: \(i)")
                }
            }
            
        }
        
        self.goThroughBoard()
        return true
    }
    
    
    func goThroughBoard() {
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
                        self.goThroughKeyboard()
                        self.isAnimating = false
                    }
                }
            }
            
            
            
        }
        
        
    }
    
    func goThroughKeyboard() {
        for i in 0...self.board[self.currentRow].count-1 {
            guard let keyBoardPosition = self.findKeyPosition(letter: self.board[self.currentRow][i].letter) else {
                return
            }
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
    
    func flipCard(rowIndex: Int, colIndex: Int) {
        withAnimation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
            .speed(1)
            .delay(0)) {
            board[rowIndex][colIndex].frontDegree = 360
        }
    }
    
    
    
    func didTapSubmit() {
        if !self.isGameOver {
            if self.isReadyToSubmit() {
                let guessedWord = self.getWordFromCurrentRow()
                if self.words?.wordGroups["\(self.numberOfLetters)"]?.contains(guessedWord) ?? false {
                    self.isAnimating = true
                    let man = self.highlightBoardLetters()
                    if man {
                        if self.word == guessedWord {
                            print("Du vant!!")
                            self.isGameOver = true
                            if self.gameMode == .dailyWord {
                                print("updating daily word")
                                self.updatePlayedDailyWord()
                            }
                            self.message = String(format: NSLocalizedString("success_message", comment: "Success message with a word"), word)
                            return
                        } else {
                            if self.currentRow == self.board.count - 1 {
                                print("Du tapte: \(guessedWord), ordet var \(self.word)")
                                self.isGameOver = true
                                self.message = String(format: NSLocalizedString("almost_message", comment: "Almost got the word message"), word)
                            } else {
                                
                                print("Feil ord: \(guessedWord)")
                            }
                            
                            
                            
                        }
                    }
                    
                    
                    
                    
                    
                    
                } else {
                    print("Det du gjettet var ikke et ord: \(guessedWord)")
                    
                }
                
                
                
            }
        }
        
    }
    
    
    
    func resetBoard() {
        self.board = []
        self.keyboard = []
        self.fixStartBoard()
        self.fixKeyboard()
        self.getRandomWord()
        self.currentRow = 0
        self.currentIndex = 0
        self.isGameOver = false
    }
    
    
}
