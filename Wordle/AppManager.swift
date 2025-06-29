//
//  AppManager.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI
import AVFoundation
import SwiftData
import GoogleMobileAds

final class AppManager: NSObject, ObservableObject, FullScreenContentDelegate {
    @AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
    @AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
    
    
    @Published var streaks: [StreakEntity] = []
    @Published var gameRecords: [GameRecordEntity] = []
    @Published var modelContext: ModelContext?
    @Published var streakManager: StreakManager?
    @Published var gameRecordManager: GameRecordManager?
    
    
    @Published var selectedLanguage: LanguageSelection = .norwegian
    @Published var language: LanguageSelection = .norwegian
    @Published var gameMode: GameMode = .normal
    @Published var selectedGameMode: GameMode = .normal
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
    @Published var isShaking: Bool = false
    @Published var submitOpacity: Double = 0.5
    @Published var shouldAnimateStreak: Bool = false
    @Published var startDate: Date = Date()
    @Published var hintsUsed: Int = 0
    @Published var hasSharedResult: Bool = false
    
    
    @Published var isShowingFilterOptions: Bool = false
    @Published var isFilteringSearchWord: Bool = true
    @Published var isFilteringStartWith: Bool = false
    @Published var startsWithFilter: String = ""
    @Published var isFilteringEndsWith: Bool = false
    @Published var endsWithFilter: String = ""
    @Published var isFilteringExcludeLetters: Bool = false
    @Published var selectedExcludedLetters: [String] = []
    let englishLetters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    let norwegianLetters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Æ", "Ø", "Å"]
    
    private var audioPlayer: AVPlayer?
    private var rewardedAd: RewardedAd?
    
    func getWords() {
        print("context: \(String(describing: self.modelContext))")
        if let words = WordleDataManager.shared.loadWordsFromJSONFile(selectedLanguage: selectedLanguage) {
            self.words = words
            
            if let dailyWords = WordleDataManager.shared.loadDailyWordsFromJSONFile(selectedLanguage: selectedLanguage) {
                self.dailyWords = dailyWords
                self.resetBoard()
                
            } else {
                self.resetBoard()
            }
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
    
    

    
    func checkIfDailyWordIsAlreadyPlayed() -> Bool {
        if let streakEntity = self.getStreakEntity() {
            return streakEntity.streak.hasPlayedDailyWord
        }
        return false
    }
    

    
    func getCurrentDateInUTCTimeSince1970() -> TimeInterval {
        let utcDate = Date().toUTC()
        return utcDate.timeIntervalSince1970
        
    }
    
    
    func getRandomWord() {
        if selectedGameMode == .normal {
            self.word = self.words?.wordGroups["\(numberOfLetters)"]?.randomElement() ?? ""
            print("Ordet er \(self.word)")
        } else {
            self.word = self.getDailyWord()
            print("Ordet2 er \(self.word)")
            
        }
        
        
        
        
        
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
    
    func getEnglishDefinition(for word: String, completion: @escaping ([EnglishDefinition]) -> Void) {
        WordleDataManager.shared.fetchEnglishDefinition(for: word) { definition in
            guard let definition = definition else {
                completion([])
                return
            }
            DispatchQueue.main.async {
                completion(definition)
            }
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
                    print("index1: \(index.utf16Offset(in: self.word)), letter: \(self.board[self.currentRow][i].letter)")
                    print("changanbleWord66: \(changableWord), i: \(i), index: \(index)")
                    let char = changableWord.remove(at: index)
                    
                    print("changanbleWord4: \(changableWord), i: \(i), index: \(index.utf16Offset(in: self.word)), char: \(char), letter: \(letter), letter2: \(self.board[self.currentRow][letterIndex.utf16Offset(in: self.word)].letter)")
                    
                } else {
                    changableWord = changableWord.replacingOccurrences(of: self.board[self.currentRow][i].letter, with: "")
//                    print("changanbleWord3: \(changableWord), i: \(i)")
                }
                
                
            } else {
                self.board[self.currentRow][i].isUsedButNotCorrect = true
                self.keyboard[keyBoardPosition.row][keyBoardPosition.col].isUsedButNotCorrect = true
//                print("wrong letter: \(self.board[self.currentRow][i].letter), i: \(i), letterIndex: \(letterIndex.utf16Offset(in: self.word)), letter: \(letter), changeableWord: \(changableWord)")
                
                if let index = changableWord.firstIndex(of: Character(self.board[self.currentRow][i].letter)) {
                    print("index2: \(index.utf16Offset(in: self.word)), letter: \(self.board[self.currentRow][i].letter)")
                    print("changanbleWord77: \(changableWord), i: \(i), index: \(index)")
                    let char = changableWord.remove(at: index)
                    
                    print("changanbleWord8: \(changableWord), i: \(i), index: \(index), char: \(char), letter: \(letter), letter2: \(self.board[self.currentRow][i].letter)")
                    
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
    
    func setStreak(state: GameEndState) {
        switch state {
            case .won:
                if let streakEntity = self.getStreakEntity(), let streakManager = self.streakManager {
                    switch streakEntity.streak {
                        case .none, .dead:
                            streakManager.updateStreak(streakEntity, with: .alive(startDate: self.startDate, lastWonDate: self.startDate))
                        case .alive(let startDate, _):
                            streakManager.updateStreak(streakEntity, with: .alive(startDate: startDate, lastWonDate: self.startDate))
                    }
                    print("Du vant, oppdaterer streak: \( streakEntity.streak)")
                    
                }
                
            case .lost:
                if let streakEntity = self.getStreakEntity(), let streakManager = self.streakManager {
                    switch streakEntity.streak {
                        case .none:
                            streakManager.updateStreak(streakEntity, with: .none)
                        case .dead(let startDate, _):
                            streakManager.updateStreak(streakEntity, with: .dead(startDeadDate: startDate, lastDiedAt: self.startDate))
                        case .alive:
                            streakManager.updateStreak(streakEntity, with: .dead(startDeadDate: self.startDate, lastDiedAt: self.startDate))
                    }
                    print("Du tapte, ingen streak: \( streakEntity.streak)")
                }
                
        }
    }
    
    
    func getStreakEntity() -> StreakEntity? {
        return self.streaks.first { $0.id == "streak: \(self.numberOfLetters), \(self.selectedLanguage.rawValue)" } ?? nil
    }
    
    
    
    func didTapSubmit() {
        if !self.isGameOver {
            let guessedWord = self.getWordFromCurrentRow()
            if wordIsValidForSubmitButton() {
                self.isAnimating = true
                let man = self.highlightBoardLetters()
                if man {
                    if self.word == guessedWord {
                        print("Du vant!!")
                        self.isGameOver = true
                        self.addGameRecord(gameRecord: GameRecord(state: .won, mode: self.selectedGameMode, word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, numberOfGuesses: self.currentRow+1, hintsUsed: self.hintsUsed, shareResultString: self.selectedGameMode == .dailyWord ? self.getShareResult(row: self.currentRow+1) : nil))
                        if self.selectedGameMode == .dailyWord {
                            print("updating daily word")
                            self.setStreak(state: .won)
                        }
                        self.message = String(format: NSLocalizedString("success_message", comment: "Success message with a word"), word)
                        return
                    } else {
                        if self.currentRow == self.board.count - 1 {
                            print("Du tapte: \(guessedWord), ordet var \(self.word)")
                            self.isGameOver = true
                            self.addGameRecord(gameRecord: GameRecord(state: .lost, mode: self.selectedGameMode, word: self.word, language: self.selectedLanguage, numberOfLetters: self.numberOfLetters, numberOfGuesses: self.currentRow+1, hintsUsed: self.hintsUsed, shareResultString: self.selectedGameMode == .dailyWord ? self.getShareResult(row: self.currentRow+1) : nil))
                            if self.selectedGameMode == .dailyWord {
                                print("updating daily word")
                                self.setStreak(state: .lost)
                            }
                            self.message = String(format: NSLocalizedString("almost_message", comment: "Almost got the word message"), word)
                        } else {
                            print("Feil ord: \(guessedWord)")
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
    
    func wordIsValidForSubmitButton() -> Bool {
        if self.isGameOver {
            return true
        }
        let wordIsValid = self.words?.wordGroups["\(self.numberOfLetters)"]?.contains(self.getWordFromCurrentRow()) ?? false
        if wordIsValid {
            return true
        }
        return false
        
    }
    
    func getShareResult(row: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        var numberOfRows = 6
        if self.numberOfLetters > 6 {
            numberOfRows = 8
        } else if self.numberOfLetters == 6 {
            numberOfRows = 7
        }
        
        var letterString = String(format: NSLocalizedString("share_letter", comment: "Letter"), self.numberOfLetters)
        if self.numberOfLetters > 1 {
            letterString = String(format: NSLocalizedString("share_letters", comment: "Letters"), self.numberOfLetters)
        }
        
        let rowString = String(format: NSLocalizedString("share_row", comment: "Row"))
            
        
        var shareText = "The Phrase \(dateFormatter.string(from: self.startDate)), \(letterString), \(row)/\(numberOfRows) \(rowString):\n"
        
        var shouldBreak: Bool = false
        for row in self.board {
            for letter in row {
                switch letter.state {
                    case .correctPosition:
                        shareText += "🟩"
                    case .correctLetter:
                        shareText += "🟨"
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
    
    
    
    func resetBoard() {
        self.board = []
        self.keyboard = []
        self.fixStartBoard()
        self.fixKeyboard()
        self.getRandomWord()
        self.currentRow = 0
        self.currentIndex = 0
        self.hintsUsed = 0
        self.isGameOver = false
        self.hasSharedResult = false
        self.language = self.selectedLanguage
        self.gameMode = self.selectedGameMode
        self.startDate = Date()
    }
    
    func resetFilters() {
        self.isFilteringSearchWord = true
        self.isFilteringStartWith = false
        self.startsWithFilter = ""
        self.isFilteringEndsWith = false
        self.endsWithFilter = ""
        self.isFilteringExcludeLetters = false
        if !selectedExcludedLetters.isEmpty {
            self.selectedExcludedLetters.removeAll()
        }
    }
    
    func playAudio(from source: String) {
        print("Playing audio from: \(source)")
        guard let url = URL(string: source) else {
            print("Invalid URL")
            return
        }
        
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
    }
    
    func fetchStreaks() {
        if let streakManager = self.streakManager {
            self.streaks = streakManager.fetchStreaks()
            print("Fetched streaks: \(self.streaks)")
            for streak in self.streaks {
                print("Streak ID: \(streak.id), Streak: \(streak.streak)")
            }
        } else {
            print("StreakManager is not initialized")
            
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
    
    
    func addStreaks() {
        for i in 1...8 {
            self.addStreak(id: "streak: \(i), norwegian", streak: .none)
            self.addStreak(id: "streak: \(i), english", streak: .none)
            
        }
    }
    
    func addStreak(id: String, streak: Streak) {
        if let streakManager = self.streakManager {
            streakManager.addStreak(id: id, streak: streak)
        }
    }
    
    func addGameRecord(gameRecord: GameRecord) {
        if let gameRecordManager = self.gameRecordManager {
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
                if key.state == .correctLetter || key.state == .correctPosition && self.word.contains(key.letter) {
                    keysWithCorrectState.append(key)
                }
            }
        }
//        print("Keys with correct state: \(keysWithCorrectState.count), number of letters: \(self.numberOfLetters)")
        return keysWithCorrectState.count != self.numberOfLetters
    }
        
    
    
    
    
    // MARK: - ADS
    func loadAd() async {
        do {
            // ca-app-pub-7619403750703078/7682260846
            self.rewardedAd = try await RewardedAd.load(
                with: "ca-app-pub-3940256099942544/1712485313", request: Request())
            self.rewardedAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd() {
        guard let rewardedAd = rewardedAd else {
            return print("Ad wasn't ready.")
        }
        
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
    
    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
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
