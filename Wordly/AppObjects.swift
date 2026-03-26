//
//  DataStucture.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData

func rowCount(for numberOfLetters: Int) -> Int {
    numberOfLetters > 6 ? 7 : 6
}

func legacyRowCount(for numberOfLetters: Int) -> Int {
    if numberOfLetters > 7 {
        return 9
    } else if numberOfLetters > 6 {
        return 8
    } else if numberOfLetters == 6 {
        return 7
    } else {
        return 6
    }
}

enum CurrentSelectView {
	case selectView
	case gameView
	case searchView
	case filterOptionsView
	case infoView
}


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
    var maxRows: Int?
    var hintsUsed: Int?
    var board: [[Letter]]?
    var endDate: Date?
    
    init(date: Date = Date(), state: GameEndState, mode: GameMode, word: String, language: LanguageSelection, numberOfLetters: Int, numberOfGuesses: Int, maxRows: Int? = nil, hintsUsed: Int = 0, board: [[Letter]]? = nil, endDate: Date? = nil) {
        self.id = UUID()
        self.date = date
        self.state = state
        self.mode = mode
        self.word = word
        self.language = language
        self.numberOfLetters = numberOfLetters
        self.numberOfGuesses = numberOfGuesses
        self.maxRows = maxRows
        self.hintsUsed = hintsUsed
        self.board = board
        self.endDate = endDate
    }
    
    var effectiveMaxRows: Int {
        self.maxRows ?? legacyRowCount(for: self.numberOfLetters)
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
            case .normal: return NSLocalizedString("game_mode_unlimited", comment: "Unlimited Mode")
            case .both: return NSLocalizedString("game_mode_both", comment: "Both Modes")
        }
    }
    
    static var modes: [GameMode] {
        return [.dailyWord, .normal]
    }
    
    
}

enum LanguageSelection: String, Codable, CaseIterable, Identifiable {
    case english
	case spanish
	case norwegian
    case all
    var id: Self { self }
    
    var localizedName: String {
        switch self {
            case .english: return NSLocalizedString("language_english", comment: "English Language")
			case .spanish: return NSLocalizedString("language_spanish", comment: "Spanish Language")
			case .norwegian: return NSLocalizedString("language_norwegian", comment: "Norwegian Language")
            case .all: return NSLocalizedString("language_all", comment: "All Languages")
        }
    }
	
	var fileName: String {
		switch self {
			case .english: return "englishWords"
			case .spanish: return "spanishWords"
			case .norwegian: return "norwegianWords"
			case .all: return "BadBadError"
		}
	}
	
	var dailyWordFileName: String {
		switch self {
			case .english: return "dailyEnglishWords"
			case .spanish: return "dailySpanishWords"
			case .norwegian: return "dailyNorwegianWords"
			case .all: return "BadBadDailyWordError"
		}
	}
	
	var alphabet: [String] {
		switch self {
			case .english: return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
			case .spanish: return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "Ñ", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
			case .norwegian: return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Æ", "Ø", "Å"]
			case .all: return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
		}
	}
    
    static var languages: [LanguageSelection] {
		return [.english, .spanish, .norwegian]
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
    var wordGroups: [String: [String]]
    var blockedWords: [String]

    init(wordGroups: [String: [String]], blockedWords: [String] = []) {
        self.wordGroups = wordGroups
        self.blockedWords = blockedWords
    }

    private enum CodingKeys: String, CodingKey {
        case wordGroups
        case blockedWords
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wordGroups = try container.decode([String: [String]].self, forKey: .wordGroups)
        self.blockedWords = try container.decodeIfPresent([String].self, forKey: .blockedWords) ?? []
    }
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
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case audio
        case sourceURL = "sourceUrl"
        case license
        case text
    }
}

struct EnglishFallbackDefinition: Codable {
    let word: String
    let entries: [EnglishFallbackEntry]
    let source: Source
}

struct EnglishFallbackEntry: Codable {
    let language: Language
    let partOfSpeech: String
    let pronunciations: [EnglishFallbackPronunciation]
    let forms: [Form]
    let senses: [EnglishFallbackSense]
    let synonyms: [String]
    let antonyms: [String]
}

struct EnglishFallbackPronunciation: Codable {
    let type: String
    let text: String
    let tags: [String]
}

struct EnglishFallbackSense: Codable {
    let definition: String
    let tags: [String]
    let examples: [String]
    let quotes: [Quote2]
    let synonyms: [String]
    let antonyms: [String]
    let subsenses: [EnglishFallbackSense]?
}


// MARK: - SpanishDefinition
struct SpanishDefinition: Codable, Identifiable {
	let id = UUID()
	let word: String
	let entries: [Entry2]
	let source: Source
	
	enum CodingKeys: String, CodingKey {
		case word
		case entries
		case source
	}
}

// MARK: - Entry
struct Entry2: Codable, Identifiable {
	let id = UUID()
	let language: Language
	let partOfSpeech: String
	let pronunciations: [Pronunciation2]
	let forms: [Form]
	let senses: [Sense]
	let synonyms, antonyms: [String]
	
	enum CodingKeys: String, CodingKey {
		case language
		case partOfSpeech
		case pronunciations
		case forms
		case senses
		case synonyms
		case antonyms
	}
}

// MARK: - Form
struct Form: Codable {
	let word: String
	let tags: [String]
}

// MARK: - Language
struct Language: Codable {
	let code, name: String
}

// MARK: - Pronunciation
struct Pronunciation2: Codable {
	let type, text: String
	let tags: [String]
}

// MARK: - Sense
struct Sense: Codable {
	let definition: String
	let tags, examples: [String]
	let quotes: [Quote2]
	let synonyms, antonyms: [String]
}

// MARK: - Quote
struct Quote2: Codable {
	let text, reference: String
}

// MARK: - Source
struct Source: Codable {
	let url: String
	let license: License2
}

// MARK: - License
struct License2: Codable {
	let name, url: String
}




final class WordleDataManager {
    static let shared = WordleDataManager()
   
}

extension WordleDataManager {
    func loadWordsFromJSONFile(selectedLanguage: LanguageSelection) -> Words? {
		guard let filePath = Bundle.main.path(forResource: selectedLanguage.fileName, ofType: "json") else {
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
        guard let filePath = Bundle.main.path(forResource: selectedLanguage.dailyWordFileName, ofType: "json") else {
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
    
    func fetchArticleIDs(for word: String, completion: @escaping (DefinitionFetchResult<[Int]>) -> Void) {
        let urlString = "https://ord.uib.no/api/articles?w=\(word)&dict=bm&scope=ei"
        print("urlString: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.notFound)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.networkError)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let jsonDict = jsonObject as? NSDictionary {
                    print(jsonDict)
                }
                let result = try JSONDecoder().decode(ArticleSearchResult.self, from: data)
                if result.articles.bm.isEmpty {
                    completion(.notFound)
                } else {
                    completion(.success(result.articles.bm))
                }
            } catch {
                print("Error decoding article IDs: \(error)")
                completion(.notFound)
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
    
    func fetchArticleDetails(articleID: Int, completion: @escaping (DefinitionFetchResult<ProcessedWord>) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://ord.uib.no/bm/article/\(articleID).json")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 20)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.configuration.timeoutIntervalForResource = 120
        session.configuration.timeoutIntervalForRequest = 120
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                completion(.networkError)
                print(error)
                print("noooo")
                return
            }
//            let httpResponse = response as? HTTPURLResponse
//            print("Response: \(String(describing: httpResponse))")
            
            guard let data = data else {
                completion(.networkError)
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
                
                completion(.success(prosessedWords))
                print("yay!! Successfully parsed the json data!")
                
                
            } catch {
                completion(.notFound)
                print("error: \(error)")
                print("noooooooooooooooooooooo!!")
            }
            
            
            
        })
        
        dataTask.resume()
    }
    
    func fetchEnglishDefinition(for word: String, completion: @escaping (DefinitionFetchResult<[EnglishDefinition]>) -> Void) {
        let fallbackWords = [word, word.lowercased(), word.capitalized]
        let requests: [(urlString: String, usesFallbackSchema: Bool)] = [
            ("https://api.dictionaryapi.dev/api/v2/entries/en/\(word)", false),
            ("https://freedictionaryapi.com/api/v1/entries/en/\(fallbackWords[1])", true),
            ("https://freedictionaryapi.com/api/v1/entries/en/\(fallbackWords[2])", true)
        ]
        
        self.fetchEnglishDefinition(from: requests, index: 0, hadReachableResponse: false, completion: completion)
    }
    
    private func fetchEnglishDefinition(from requests: [(urlString: String, usesFallbackSchema: Bool)], index: Int, hadReachableResponse: Bool, completion: @escaping (DefinitionFetchResult<[EnglishDefinition]>) -> Void) {
        guard index < requests.count else {
            completion(hadReachableResponse ? .notFound : .networkError)
            return
        }
        
        let request = requests[index]
        let urlString = request.urlString
        print("urlString: \(urlString)")
        guard let url = URL(string: urlString) else {
            self.fetchEnglishDefinition(from: requests, index: index + 1, hadReachableResponse: hadReachableResponse, completion: completion)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                self.fetchEnglishDefinition(from: requests, index: index + 1, hadReachableResponse: hadReachableResponse, completion: completion)
                return
            }
            
            print("data: \(data)")
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                print("jsonObject: \(jsonObject)")
                if let jsonDict = jsonObject as? [NSDictionary] {
                    print("jsonDict: \(jsonDict)")
                }
                
                let result: [EnglishDefinition]
                if request.usesFallbackSchema {
                    let fallbackDefinition = try JSONDecoder().decode(EnglishFallbackDefinition.self, from: data)
                    result = self.convertEnglishFallbackDefinition(fallbackDefinition)
                } else {
                    result = try JSONDecoder().decode([EnglishDefinition].self, from: data)
                }
                
                dump(result)
                
                if !self.hasUsableEnglishDefinition(result) {
                    self.fetchEnglishDefinition(from: requests, index: index + 1, hadReachableResponse: true, completion: completion)
                } else {
                    completion(.success(result))
                }
            } catch {
                print("Error decoding English Definition: \(error)")
                self.fetchEnglishDefinition(from: requests, index: index + 1, hadReachableResponse: true, completion: completion)
            }
        }.resume()
    }
    
    private func convertEnglishFallbackDefinition(_ definition: EnglishFallbackDefinition) -> [EnglishDefinition] {
        definition.entries.map { entry in
            let phonetics = entry.pronunciations.map { pronunciation in
                Phonetic(
                    audio: "",
                    sourceURL: nil,
                    license: nil,
                    text: pronunciation.text
                )
            }
            .reduce(into: [Phonetic]()) { result, phonetic in
                if !result.contains(where: { $0.text == phonetic.text && $0.audio == phonetic.audio }) {
                    result.append(phonetic)
                }
            }
            
            return EnglishDefinition(
                word: definition.word,
                phonetic: phonetics.first?.text,
                phonetics: phonetics,
                meanings: [
                    Meaning(
                        partOfSpeech: entry.partOfSpeech,
                        definitions: self.convertEnglishFallbackSenses(entry.senses),
                        synonyms: entry.synonyms,
                        antonyms: entry.antonyms
                    )
                ],
                license: License(name: definition.source.license.name, url: definition.source.license.url),
                sourceUrls: [definition.source.url]
            )
        }
    }
    
    private func convertEnglishFallbackSenses(_ senses: [EnglishFallbackSense]) -> [Definition] {
        senses.flatMap { sense in
            var definitions: [Definition] = [
                Definition(
                    definition: sense.definition,
                    synonyms: sense.synonyms,
                    antonyms: sense.antonyms,
                    example: sense.examples.isEmpty ? nil : sense.examples.joined(separator: "; ")
                )
            ]
            
            if let subsenses = sense.subsenses, !subsenses.isEmpty {
                definitions.append(contentsOf: self.convertEnglishFallbackSenses(subsenses))
            }
            
            return definitions
        }
    }
    
    private func hasUsableEnglishDefinition(_ definitions: [EnglishDefinition]) -> Bool {
        definitions.contains { definition in
            definition.meanings.contains { meaning in
                !meaning.definitions.isEmpty
            }
        }
    }
	
	
    func fetchNorwegianDefinition(for word: String, completion: @escaping (DefinitionFetchResult<[ProcessedWord]>) -> Void) {
        var processedWords: [ProcessedWord] = []
        self.fetchArticleIDs(for: word) { articleIDsResult in
            switch articleIDsResult {
                case .networkError:
                    DispatchQueue.main.async {
                        completion(.networkError)
                    }
                case .notFound:
                    DispatchQueue.main.async {
                        completion(.notFound)
                    }
                case .success(let articleIDs):
                    let dispatchGroup = DispatchGroup()
                    var hadNetworkError = false
                    
                    for articleID in articleIDs {
                        dispatchGroup.enter()
                        self.fetchArticleDetails(articleID: articleID) { result in
                            switch result {
                                case .success(let processedWord):
                                    DispatchQueue.main.async {
                                        processedWords.append(processedWord)
                                    }
                                case .networkError:
                                    hadNetworkError = true
                                case .notFound:
                                    break
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        if !processedWords.isEmpty {
                            completion(.success(processedWords))
                        } else if hadNetworkError {
                            completion(.networkError)
                        } else {
                            completion(.notFound)
                        }
                    }
            }
        }
    }
	
	func fetchSpanishDefinition(for word: String, completion: @escaping (DefinitionFetchResult<SpanishDefinition>) -> Void) {
		let urlString = "https://freedictionaryapi.com/api/v1/entries/es/\(word.lowercased())"
		print("urlString: \(urlString)")
		guard let url = URL(string: urlString) else {
			completion(.notFound)
			return
		}
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard let data = data, error == nil else {
				completion(.networkError)
				return
			}
			print("data: \(data)")
			do {
				let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
				print("jsonObject: \(jsonObject)")
				if let jsonDict = jsonObject as? [NSDictionary] {
					print("jsonDict: \(jsonDict)")
				}
				let result = try JSONDecoder().decode(SpanishDefinition.self, from: data)
				dump(result)
                if result.entries.isEmpty {
                    completion(.notFound)
                } else {
                    completion(.success(result))
                }
			} catch {
				print("Error decoding Spanish Definition: \(error)")
				completion(.notFound)
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
