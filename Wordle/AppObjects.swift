//
//  DataStucture.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData


enum AppTheme: String {
    case system, dark, light
}

enum TabSelection {
    case home
    case stats
    case history
    case settings
}

@Model
final class GameRecordEntity: Identifiable {
    var id: UUID
    var gameRecord: GameRecord
    
    init(gameRecord: GameRecord) {
        self.id = UUID()
        self.gameRecord = gameRecord
    }
}

@Model
class GameRecord: Identifiable {
    var id: UUID
    var date: Date
    var state: GameEndState
    var mode: GameMode
    var word: String
    var language: LanguageSelection
    var numberOfLetters: Int
    var numberOfGuesses: Int
    var hintsUsed: Int?
    var board: [[Letter]]?
    var endDate: Date?
    
    init(date: Date = Date(), state: GameEndState, mode: GameMode, word: String, language: LanguageSelection, numberOfLetters: Int, numberOfGuesses: Int, hintsUsed: Int = 0, board: [[Letter]]? = nil, endDate: Date? = nil) {
        self.id = UUID()
        self.date = date
        self.state = state
        self.mode = mode
        self.word = word
        self.language = language
        self.numberOfLetters = numberOfLetters
        self.numberOfGuesses = numberOfGuesses
        self.hintsUsed = hintsUsed
        self.board = board
        self.endDate = endDate
    }
    
}


@Model
final class StreakEntity {
    var id: String
    var streak: Streak
    var longestStreak: Int
    
    init(id: String, streak: Streak) {
        self.id = id
        self.streak = streak
        self.longestStreak = streak.currentStreak
    }
}

enum Streak: Codable {
    case none
    case dead(startDeadDate: Date, lastDiedAt: Date)
    case alive(startDate: Date, lastWonDate: Date)
    
    var currentStreak: Int {
        switch self {
            case .none, .dead: return 0
            case .alive(let startDate, let lastWonDate):
                var cetCalendar = Calendar(identifier: .gregorian)
                cetCalendar.timeZone = TimeZone(identifier: "CET")!
                
                let lastWonDate = cetCalendar.startOfDay(for: lastWonDate)
                let startDate = cetCalendar.startOfDay(for: startDate)
                let daysSinceStart = cetCalendar.dateComponents([.day], from: startDate, to: lastWonDate).day ?? 0
                return daysSinceStart
        }
    }
    
    var isAlive: Bool {
        switch self {
            case .none, .dead: return false
            case .alive(_, let lastWonDate):
                var cetCalendar = Calendar(identifier: .gregorian)
                cetCalendar.timeZone = TimeZone(identifier: "CET")!
                
                let today = cetCalendar.startOfDay(for: Date())
                let lastWonDate = cetCalendar.startOfDay(for: lastWonDate)
                let daysSinceLastWon = cetCalendar.dateComponents([.day], from: lastWonDate, to: today).day ?? 0
                return daysSinceLastWon <= 1
        }
    }
    
    var hasPlayedDailyWord: Bool {
        switch self {
            case .none: return false
            case .dead(let startDeadDate, _):
                var cetCalendar = Calendar(identifier: .gregorian)
                cetCalendar.timeZone = TimeZone(identifier: "CET")!
                
                let currentDate = Date()
                return cetCalendar.isDate(startDeadDate, inSameDayAs: currentDate)
            case .alive(_, let lastWonDate):
                var cetCalendar = Calendar(identifier: .gregorian)
                cetCalendar.timeZone = TimeZone(identifier: "CET")!
                
                let currentDate = Date()
                return cetCalendar.isDate(lastWonDate, inSameDayAs: currentDate)
        }
    }
}

@Model
final class NormalStreakEntity {
    var id: String
    var streak: NormalStreak
    var longestStreak: Int
    
    init(id: String, streak: NormalStreak) {
        self.id = id
        self.streak = streak
        self.longestStreak = streak.currentStreak
    }
}

enum NormalStreak: Codable {
    case none
    case dead
    case alive(currentStreak: Int)
    
    var currentStreak: Int {
        switch self {
            case .none, .dead: return 0
            case .alive(let currentStreak):
                return currentStreak
        }
    }
    
    var isAlive: Bool {
        switch self {
            case .none, .dead: return false
            case .alive:
                return true
        }
    }
}

enum ShowsWhenHintsUsed: String, CaseIterable, Identifiable {
    case neverUsed
    case onlyWhenUsed
    case both
    var id: Self { self }
    
    var localizedName: String {
        switch self {
            case .neverUsed: return NSLocalizedString("hints_used_neverUsed", comment: "Never Used")
            case .onlyWhenUsed: return NSLocalizedString("hints_used_onlyWhenUsed", comment: "Only When Used")
            case .both: return NSLocalizedString("hints_used_both", comment: "Both")
        }
    }
    
}

enum GameEndState: Codable {
    case won
    case lost
}

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case dailyWord
    case normal
    case both
    var id: Self { self }
    
    var localizedName: String {
        switch self {
            case .dailyWord: return NSLocalizedString("game_mode_daily_word", comment: "Daily Word Mode")
            case .normal: return NSLocalizedString("game_mode_normal", comment: "Normal Mode")
            case .both: return NSLocalizedString("game_mode_both", comment: "Both Modes")
        }
    }
    
    static var modes: [GameMode] {
        return [.dailyWord, .normal]
    }
    
    
}

enum LanguageSelection: String, Codable, CaseIterable, Identifiable {
    case norwegian
    case english
    case both
    var id: Self { self }
    
    var localizedName: String {
        switch self {
            case .norwegian: return NSLocalizedString("language_norwegian", comment: "Norwegian Language")
            case .english: return NSLocalizedString("language_english", comment: "English Language")
            case .both: return NSLocalizedString("language_both", comment: "Both Languages")
        }
    }
    
    static var languages: [LanguageSelection] {
        return [.norwegian, .english]
    }
    
}

struct AlertItem: Identifiable {
    var id = UUID()
    var title: Text
    var message: Text?
    var primaryButton: Alert.Button?
    var secondaryButton: Alert.Button?
    var dismissButton: Alert.Button?
}

struct Shorted: Codable {
    let concepts: [String: ShortedContent]
}

struct ShortedContent: Codable {
    let class2: String?
    let expansion: String
    
    enum CodingKeys: String, CodingKey {
        case class2 = "class"
        case expansion
        
    }
}

struct Words: Decodable {
    let wordGroups: [String: [String]]
}

enum LetterState: Codable {
    case correctPosition
    case correctLetter
    case usedButNotCorrect
    case notUsed
}

struct Letter: Hashable, Codable, Identifiable {
    var id = UUID()
    var letter: String = ""
    var isCorrectPosition: Bool = false
    var isCorrectLetter: Bool = false
    var isUsedButNotCorrect: Bool = false
    var degreee: Double = 0
    var scale: Double = 1.0
    var state: LetterState = .notUsed
    
    init(letter: String = "", isCorrectPosition: Bool = false, isCorrectLetter: Bool = false, isUsedButNotCorrect: Bool = false, degreee: Double = 0, scale: Double = 1.0, state: LetterState = .notUsed) {
        self.letter = letter
        self.isCorrectPosition = isCorrectPosition
        self.isCorrectLetter = isCorrectLetter
        self.isUsedButNotCorrect = isUsedButNotCorrect
        self.degreee = degreee
        self.scale = scale
        self.state = state
    }
}

struct KeyBoardLetter: Hashable, Identifiable {
    let id = UUID()
    var letter: String = ""
    var isCorrectPosition: Bool = false
    var isCorrectLetter: Bool = false
    var isUsedButNotCorrect: Bool = false
    var state: LetterState = .notUsed
    var didTapButton: Bool = false
}




struct ArticleSearchResult: Codable {
    let articles: Articles
}

struct Articles: Codable {
    let bm: [Int]
}

struct Article: Codable {
    let articleID: Int?
    let submitted: String?
    let suggest: [String]?
    let lemmas: [Lemma]?
    let body: Body?
    let author: String?
    let editState: String?
//    let referers: [Referer]?
    let status: Int?
    let toIndex: [String]?
    let updated: String?
    
    enum CodingKeys: String, CodingKey {
        case articleID = "article_id"
        case submitted
        case suggest
        case lemmas
        case body
        case author
        case editState = "edit_state"
//        case referers
        case status
        case toIndex = "to_index"
        case updated
    }
}

struct Lemma: Codable {
    let finalLexeme: String?
    let initialLexeme: String?
    let addedNorm: Int?
    let hgno: Int?
    let id: Int?
    let inflectionClass: String?
    let lemma: String?
    let paradigmInfo: [ParadigmInfo]?
    let splitInf: Bool?
    
    enum CodingKeys: String, CodingKey {
        case finalLexeme = "final_lexeme"
        case initialLexeme = "initial_lexeme"
        case addedNorm
        case hgno
        case id
        case inflectionClass = "inflection_class"
        case lemma
        case paradigmInfo = "paradigm_info"
        case splitInf = "split_inf"
    }
}

struct ParadigmInfo: Codable {
    let from: String?
    let inflection: [Inflection]?
    let inflectionGroup: String?
    let paradigmID: Int?
    let standardisation: String?
    let tags: [String]?
    let to: String?
    
    enum CodingKeys: String, CodingKey {
        case from
        case inflection
        case inflectionGroup = "inflection_group"
        case paradigmID = "paradigm_id"
        case standardisation
        case tags
        case to
    }
}

struct Inflection: Codable {
    let tags: [String]?
    let wordForm: String?
    
    enum CodingKeys: String, CodingKey {
        case tags
        case wordForm = "word_form"
    }
}

struct Body: Codable {
    let etymology: [Etymology]?
    let definitions: [DefinitionWrapper]?
    let pronunciation: [Pronunciation]?
}

struct Pronunciation: Codable {
    let content: String?
//    let items: [PronunciationItem]?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case content
//        case items
        case type = "type_"
    }
    
}

struct Etymology: Codable {
    let type: String?
    let content: String?
    let items: [EtymologyItem]?
    
    enum CodingKeys: String, CodingKey {
        case type = "type_"
        case content
        case items
    }
}

struct EtymologyItem: Codable {
    let type: String?
    let articleID: Int?
    let lemmas: [LemmaReference]?
    let definitionID: Int?
    let definitionOrder: Int?
    let id: String?
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "type_"
        case articleID = "article_id"
        case lemmas
        case definitionID = "definition_id"
        case definitionOrder = "definition_order"
        case id
        case text
    }
}

struct DefinitionWrapper: Codable {
    let type: String?
    let elements: [DefinitionElement]?
    let id: Int?
    let subDefinition: Bool?
    
    enum CodingKeys: String, CodingKey {
        case type = "type_"
        case elements
        case id
        case subDefinition = "sub_definition"
    }
}

struct DefinitionElement: Codable {
    let type: String?
    let elements: [DefinitionElement]?
    let content: String?
    let quote: Quote?
    let items: [DefinitionItem]?
    
    enum CodingKeys: String, CodingKey {
        case type = "type_"
        case elements
        case content
        case quote
        case items
    }
}


struct DefinitionItem: Codable {
    let type: String?
    let articleID: Int?
    let lemmas: [LemmaReference]?
    let definitionID: Int?
    let definitionOrder: Int?
    let id: String?
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "type_"
        case articleID = "article_id"
        case lemmas
        case definitionID = "definition_id"
        case definitionOrder = "definition_order"
        case id
        case text
    }
}

struct LemmaReference: Codable {
    let hgno: Int?
    let id: Int?
    let lemma: String?
}

struct Quote: Codable {
    let content: String?
    let items: [QuoteItem]?
}

struct QuoteItem: Codable {
    let type: String?
    let articleID: Int?
    let lemmas: [LemmaReference]?
    let definitionID: Int?
    let definitionOrder: Int?
    let id: String?
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "type_"
        case articleID = "article_id"
        case lemmas
        case definitionID = "definition_id"
        case definitionOrder = "definition_order"
        case id
        case text
    }
}

struct ProcessedWord: Identifiable {
    let id = UUID()
    let words: [String]?
    let wordClass: String?
    let gender: String?
    let pronunciation: String?
    let etymology: [String]?
    let definitions: [ProcessedDefinition]?
}

struct ProcessedDefinition: Identifiable {
    let id = UUID()
    let explanations: [String]
    let examples: [ProcessedExample]
    let quotes: [String]
    let nestedDefinitions: [ProcessedDefinition]
    let wordClass: String?
    let gender: String?
}

struct ProcessedExample: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let explanation: String
}



// MARK: - English Definition
struct EnglishDefinition: Codable, Identifiable {
    let id = UUID()
    let word: String
    let phonetic: String?
    let phonetics: [Phonetic]
    let meanings: [Meaning]
    let license: License
    let sourceUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case word
        case phonetic
        case phonetics
        case meanings
        case license
        case sourceUrls = "sourceUrls"
    }
}

struct License: Codable {
    let name: String
    let url: String
}

struct Meaning: Codable, Identifiable {
    let id = UUID()
    let partOfSpeech: String
    let definitions: [Definition]
    let synonyms: [String]
    let antonyms: [String]
    
    enum CodingKeys: String, CodingKey {
        case partOfSpeech
        case definitions
        case synonyms
        case antonyms
    }
}
struct Definition: Codable, Identifiable {
    let id = UUID()
    let definition: String
    let synonyms: [String]
    let antonyms: [String]
    let example: String?
    
    enum CodingKeys: String, CodingKey {
        case definition
        case synonyms
        case antonyms
        case example
    }
}
struct Phonetic: Codable, Identifiable {
    let id = UUID()
    let audio: String
    let sourceURL: String?
    let license: License?
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case audio
        case sourceURL = "sourceUrl"
        case license
        case text
    }
}


final class WordleDataManager {
    static let shared = WordleDataManager()
   
}

extension WordleDataManager {
    func loadWordsFromJSONFile(selectedLanguage: LanguageSelection) -> Words? {
        guard let filePath = Bundle.main.path(forResource: selectedLanguage == .norwegian ? "norwegianWords" : "englishWords", ofType: "json") else {
            print("File not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let decoder = JSONDecoder()
            let words = try decoder.decode(Words.self, from: data)
            return words
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    func loadDailyWordsFromJSONFile(selectedLanguage: LanguageSelection) -> Words? {
        guard let filePath = Bundle.main.path(forResource: selectedLanguage == .norwegian ? "dailyNorwegianWords" : "dailyEnglishWords", ofType: "json") else {
            print("File not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let decoder = JSONDecoder()
            let words = try decoder.decode(Words.self, from: data)
            return words
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    func loadShortedFromJSONFile() -> Shorted? {
        guard let filePath = Bundle.main.path(forResource: "shortedNorwegainWords", ofType: "json") else {
            print("File not found2")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let decoder = JSONDecoder()
            let words = try decoder.decode(Shorted.self, from: data)
            return words
        } catch {
            print("Error decoding JSON2: \(error)")
            return nil
        }
    }
    
    func fetchArticleIDs(for word: String, completion: @escaping ([Int]?) -> Void) {
        let urlString = "https://ord.uib.no/api/articles?w=\(word)&dict=bm&scope=ei"
        print("urlString: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let jsonDict = jsonObject as? NSDictionary {
                    print(jsonDict)
                }
                let result = try JSONDecoder().decode(ArticleSearchResult.self, from: data)
                completion(result.articles.bm)
            } catch {
                print("Error decoding article IDs: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    
    func processDefinitions(article: Article) -> [ProcessedDefinition] {
        var processedDefinitions: [ProcessedDefinition] = []
        
        if let defWrappers = article.body?.definitions {
            for defWrapper in defWrappers {
                if let elements = defWrapper.elements {
                    let processedDef = processDefinitionElements(
                        elements,
                        lemmas: article.lemmas
                    )
                    processedDefinitions.append(processedDef)
                }
            }
        }
        
        return processedDefinitions
    }
    
    func processDefinitionElements(
        _ elements: [DefinitionElement],
        lemmas: [Lemma]?
    ) -> ProcessedDefinition {
        var explanations: [String] = []
        let examples: [ProcessedExample] = []
        var quotes: [String] = []
        var nestedDefinitions: [ProcessedDefinition] = []
        
        let wordClass: String?
        let gender: String?
        if let inflectionTags = lemmas?.first?.paradigmInfo?.first?.tags {
            gender = determineGender(from: inflectionTags)
            wordClass = determineWordClass(from: inflectionTags)
        } else {
            gender = nil
            wordClass = nil
        }
        
        for element in elements {
            if let subElements = element.elements {
                let nestedDef = processDefinitionElements(subElements, lemmas: lemmas)
                nestedDefinitions.append(nestedDef)
            }
            
            if let quote = element.quote, let content = quote.content, let items = quote.items {
                let replacedQuote = replaceQuotePlaceholders(in: content, with: items)
                quotes.append(replacedQuote)
            }
            
            if let items = element.items, let content = element.content {
                let replacedContent = replacePlaceholders(in: content, with: items)
                explanations.append(replacedContent)
            } else if let content = element.content {
                explanations.append(content)
            }
        }
        
        return ProcessedDefinition(
            explanations: explanations,
            examples: examples,
            quotes: quotes,
            nestedDefinitions: nestedDefinitions,
            wordClass: wordClass,
            gender: gender
        )
    }
    
    func determineGender(from tags: [String]) -> String? {
        if tags.contains("Dem") { return "demonstrativ" }
        if tags.contains("Quant") { return "kvator" }
        if tags.contains("Poss") { return "possessiv" }
        if tags.contains("Masc") { return "hankjønn" }
        if tags.contains("Femi") { return "hunkjønn" }
        if tags.contains("Neuter") { return "intetkjønn" }
        return nil
    }
    
    func determineWordClass(from tags: [String]) -> String? {
        if tags.contains("NOUN") { return "SUBSTANTIV" }
        if tags.contains("ADJ") { return "ADJEKTIV" }
        if tags.contains("ADV") { return "ADVERB" }
        if tags.contains("VERB") { return "VERB" }
        if tags.contains("PRON") { return "PRONOMEN" }
        if tags.contains("DET") { return "DETERMINATIV" }
        if tags.contains("INTJ") { return "INTERJEKSJON" }
        if tags.contains("CCONJ") { return "KONJUNKSJON" }
        if tags.contains("ADP") { return "PREPOSISJON" }
        if tags.contains("SCONJ") { return "SUBJUNKSJON" }
        return nil
    }
    
    func processDefinitions2(article: Article) -> [String] {
        var allDefinitions: [String] = []
        
        if let defWrappers = article.body?.definitions {
            for defWrapper in defWrappers {
                if let elements = defWrapper.elements {
                    for element in elements {
                        if let processedContent = processDefinitionElement(element) {
                            allDefinitions.append(processedContent)
                        }
                    }
                }
            }
        }
        
        return allDefinitions
    }
    
    func processDefinitionElement(_ element: DefinitionElement?) -> String? {
        guard let element = element else { return nil }
        
        var processedContents: [String] = []
        
        if let content = element.content, content.contains("$"), let items = element.items {
            let replacedContent = replacePlaceholders(in: content, with: items)
            processedContents.append(replacedContent)
        }
        
        if let subElements = element.elements {
            for subElement in subElements {
                if let content = subElement.content, content.contains("$"), let items = subElement.items {
                    let replacedContent = replacePlaceholders(in: content, with: items)
                    processedContents.append(replacedContent)
                } else if let content = subElement.content {
                    // Legg til innhold uten `$` hvis det finnes
                    processedContents.append(content)
                }
            }
        }
        
        return processedContents.isEmpty ? element.content : processedContents.joined(separator: ", ")
    }
    
    func replacePlaceholders(in content: String, with items: [DefinitionItem]) -> String {
        var modifiedContent = content
        if let shortedWords: Shorted = loadShortedFromJSONFile() {
            for item in items {
                if let id = item.id {
                    let idString = String(id)
                    var string = ""
                    if let shortedWord = shortedWords.concepts[idString] {
                        string = shortedWord.expansion
                    } else {
                        for word in shortedWords.concepts {
                            if word.key == idString {
                                string = word.value.expansion
                            }
                        }
                    }
                    print("string: \(string)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                } else if item.type == "usage" {
                    var string = ""
                    if let text = item.text {
                        string = text
                    }
                    print("string: \(string)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                } else if let lemmas = item.lemmas, let lemma = lemmas.first?.lemma {
                    print("lemma: \(lemma)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: lemma, options: [], range: modifiedContent.range(of: "$"))
                }
            }
        } else {
            for item in items {
                if item.type == "relation", let id = item.id {
                    let idString = String(id)
                    var string = ""
                    if idString == "el" {
                        string = "eller"
                    } else if idString == "o_l" {
                        string = "eller lignende"
                    } else if idString == "besl" {
                        string = "beslektet"
                    }
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                } else if let lemmas = item.lemmas, let lemma = lemmas.first?.lemma {
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: lemma, options: [], range: modifiedContent.range(of: "$"))
                }
            }
        }
        
        return modifiedContent
    }
    
    func replaceEtymologyPlaceholders(in content: String, with items: [EtymologyItem]) -> String {
        var modifiedContent = content
        if let shortedWords: Shorted = loadShortedFromJSONFile() {
            for item in items {
                if let id = item.id {
                    let idString = String(id)
                    var string = ""
                    if let shortedWord = shortedWords.concepts[idString] {
                        string = shortedWord.expansion
                    } else {
                        for word in shortedWords.concepts {
                            if word.key == idString {
                                string = word.value.expansion
                            }
                        }
                    }
                    print("string: \(string)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                    
                } else if item.type == "usage" {
                    var string = ""
                    if let text = item.text {
                        string = text
                    }
                    print("string: \(string)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                }  else if let lemmas = item.lemmas, let lemma = lemmas.first?.lemma {
                    print("lemma: \(lemma)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: lemma, options: [], range: modifiedContent.range(of: "$"))
                }
            }
        } else {
            for item in items {
                if let id = item.id {
                    let idString = String(id)
                    var string = ""
                    if idString == "el" {
                        string = "eller"
                    } else if idString == "o_l" {
                        string = "eller lignende"
                    } else if idString == "besl" {
                        string = "beslektet"
                    }
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                    
                } else if item.type == "usage" {
                    var string = ""
                    if let text = item.text {
                        string = text
                    }
                    print("string: \(string)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                }  else if let lemmas = item.lemmas, let lemma = lemmas.first?.lemma {
                    print("lemma: \(lemma)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: lemma, options: [], range: modifiedContent.range(of: "$"))
                }
            }
        }
        
        return modifiedContent
    }
    
    
    func replaceQuotePlaceholders(in content: String, with items: [QuoteItem]) -> String {
        var modifiedContent = content
        if let shortedWords: Shorted = loadShortedFromJSONFile() {
            for item in items {
                 if item.type == "usage" {
                    var string = ""
                    if let text = item.text {
                        string = text
                    }
                    print("string: \(string)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                 } else if let text = item.text {
                     let idString = String(text)
                     var string = ""
                     if let shortedWord = shortedWords.concepts[idString] {
                         string = shortedWord.expansion
                     } else {
                         for word in shortedWords.concepts {
                             if word.key == idString {
                                 string = word.value.expansion
                             }
                         }
                     }
                     print("string: \(string)")
                     modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                     
                 } else if let lemmas = item.lemmas, let lemma = lemmas.first?.lemma {
                    print("lemma: \(lemma)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: lemma, options: [], range: modifiedContent.range(of: "$"))
                }
            }
        } else {
            for item in items {
                if item.type == "relation", let text = item.text {
                    let idString = String(text)
                    var string = ""
                    if idString == "el" {
                        string = "eller"
                    } else if idString == "o_l" {
                        string = "eller lignende"
                    } else if idString == "besl" {
                        string = "beslektet"
                    }
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                    
                } else if item.type == "usage" {
                    var string = ""
                    if let text = item.text {
                        string = text
                    }
                    print("string: \(string)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: string, options: [], range: modifiedContent.range(of: "$"))
                }  else if let lemmas = item.lemmas, let lemma = lemmas.first?.lemma {
                    print("lemma: \(lemma)")
                    modifiedContent = modifiedContent.replacingOccurrences(of: "$", with: lemma, options: [], range: modifiedContent.range(of: "$"))
                }
            }
        }
        
        return modifiedContent
    }
    
    func getPronunciation(article: Article) -> String? {
        if let pronunciation = article.body?.pronunciation, pronunciation.count > 0 {
            return pronunciation[0].content
        }
        return nil
    }
    
    func getEtymology(article: Article) -> [String]? {
        if let etymologys = article.body?.etymology, etymologys.count > 0 {
            var fixedStrings: [String] = []
            for etymology in etymologys {
                if let content = etymology.content, let items = etymology.items {
                    fixedStrings.append(self.replaceEtymologyPlaceholders(in: content, with: items))
                }
            }
            
            return fixedStrings
        }
        return nil
    }
    
    func getWords(lemmas: [Lemma]) -> [String]? {
        var words: [String] = []
        for lemma in lemmas {
            if let word = lemma.lemma {
                words.append(word)
            }
        }
        if words.count == 0 {
            return nil
        }
        return words
    }
    
    func fetchArticleDetails(articleID: Int, completion: @escaping (ProcessedWord?) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://ord.uib.no/bm/article/\(articleID).json")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 20)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.configuration.timeoutIntervalForResource = 120
        session.configuration.timeoutIntervalForRequest = 120
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                completion(nil)
                print(error)
                print("noooo")
                return
            }
//            let httpResponse = response as? HTTPURLResponse
//            print("Response: \(String(describing: httpResponse))")
            
            guard let data = data else {
                completion(nil)
                print("noooooooooooo")
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let jsonDict = jsonObject as? NSDictionary {
                    print(jsonDict)
                }
                let article = try JSONDecoder().decode(Article.self, from: data)
                dump(article)
                print("article: \(article)")
                
                let definitions = self.processDefinitions2(article: article)
                print(definitions)
                let processedDefinitions = self.processDefinitions(article: article)
                print(processedDefinitions)
                var gender: String?
                var wordClass: String?
                var words: [String]?
                let pronunciation = self.getPronunciation(article: article)
                let etymology = self.getEtymology(article: article)
                
                if let lemmas = article.lemmas, let inflectionTags = lemmas.first?.paradigmInfo?.first?.tags {
                    gender = self.determineGender(from: inflectionTags)
                    wordClass = self.determineWordClass(from: inflectionTags)
                    
                } else {
                    gender = nil
                    wordClass = nil
                    
                }
                
                if let lemmas = article.lemmas, !lemmas.isEmpty {
                    words = self.getWords(lemmas: lemmas)
                    
                } else {
                    words = nil
                    
                }
                
                
                let prosessedWords: ProcessedWord = ProcessedWord(words: words,
                                                                  wordClass: wordClass,
                                                                  gender: gender,
                                                                  pronunciation: pronunciation,
                                                                  etymology: etymology,
                                                                  definitions: processedDefinitions)
                
                completion(prosessedWords)
                print("yay!! Successfully parsed the json data!")
                
                
            } catch {
                completion(nil)
                print("error: \(error)")
                print("noooooooooooooooooooooo!!")
            }
            
            
            
        })
        
        dataTask.resume()
    }
    
    func fetchEnglishDefinition(for word: String, completion: @escaping ([EnglishDefinition]?) -> Void) {
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
        print("urlString: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            print("data: \(data)")
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                print("jsonObject: \(jsonObject)")
                if let jsonDict = jsonObject as? [NSDictionary] {
                    print("jsonDict: \(jsonDict)")
                }
                let result = try JSONDecoder().decode([EnglishDefinition].self, from: data)
                dump(result)
                completion(result)
            } catch {
                print("Error decoding English Definition: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    
}


extension Date {
    func toUTC() -> Date {
        let timezoneOffset = TimeInterval(TimeZone.current.secondsFromGMT(for: self))
        return self.addingTimeInterval(-timezoneOffset)
    }
}

