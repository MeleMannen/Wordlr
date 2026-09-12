import SwiftUI

struct LocalizedWordDefinitionView: View {
    let word: String
    let language: LanguageSelection
    @Environment(\.colorScheme) private var colorScheme
    @State private var definition: WiktDefinition?
    @State private var usesFallback = false

    var body: some View {
        VStack(spacing: 0) {
            if usesFallback {
                fallback
            } else if let definition {
                WiktWordDefinitionView(definition: definition)
                    .refreshable { await load() }
                
                    .darkGradientBackground(colorScheme: colorScheme)
            } else {
                DefinitionLoadingView()
                    .darkGradientBackground(colorScheme: colorScheme)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(word)
        .task { await load() }
    }

    @ViewBuilder
    private var fallback: some View {
        switch language {
        case .english:
            EnglishWordDefinitionView(word: word)
        case .spanish:
            SpanishWordDefinitionView(word: word)
        case .french, .polish:
            FreeDictionaryWordDefinitionView(word: word, language: language)
        case .norwegian:
            NorwegianWordDefinitionView(word: word)
        case .all:
            ContentUnavailableView("No definition found", systemImage: "book.closed")
        }
    }

    @MainActor
    private func load() async {
        do {
            let result = try await WordleDataManager.shared.fetchWiktAPI(
                word: word,
                wordLanguage: language.dictionaryCode,
                preferredLanguage: Locale.preferredLanguages.first ?? "en"
            )
            try Task.checkCancellation()
            definition = result
            usesFallback = result == nil
            if result != nil {
                AnalyticsManager.shared.logDidViewWordDefinitionEvent(
                    word: word, language: language, numberOfLetters: word.count, viewSuccess: true
                )
            }
        } catch {
            // The provider handles service failures; only cancellation reaches here.
        }
    }
}
