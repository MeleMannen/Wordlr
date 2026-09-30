import SwiftUI

struct LocalizedWordDefinitionView: View {
    let word: String
    let language: LanguageSelection
    @Environment(\.colorScheme) private var colorScheme
    @State private var resolvedDefinition: DefinitionRepository.ResolvedDefinition?
    @State private var usesFallback = false
    @State private var definitionLanguage = "en"
    @State private var pickerLanguage = "en"
    @State private var availableDefinitions: [DefinitionRepository.ResolvedDefinition] = []
    @State private var isCheckingLanguages = false
    @State private var isChangingDefinition = false

    private var wordLanguage: String? { language.dictionaryCode }

    var body: some View {
        VStack(spacing: 0) {
            if usesFallback {
                fallback
            } else if let resolvedDefinition {
                definitionContent(resolvedDefinition)
                    .id("\(word)-\(resolvedDefinition.languageCode)")
                    .overlay {
                        if isChangingDefinition { ProgressView() }
                    }
            } else {
                DefinitionLoadingView()
                    .darkGradientBackground(colorScheme: colorScheme)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Definition")
        .task { await load() }
        .toolbar {
            if resolvedDefinition != nil, !usesFallback {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker(selection: $pickerLanguage) {
                        ForEach(availableDefinitions, id: \.languageCode) { result in
                            Text(languageName(result.languageCode))
                                .tag(result.languageCode)
                        }
                    } label: {
                        Text(languageName(definitionLanguage))
                    }
                    .pickerStyle(.menu)
                    .accessibilityHint("Choose the definition language")
                    .simultaneousGesture(TapGesture().onEnded {
                        Task { await checkOtherDefinitionLanguages() }
                    })
                    .onChange(of: pickerLanguage) { _, newLanguage in
                        guard let result = availableDefinitions.first(where: { $0.languageCode == newLanguage }) else { return }
                        Task { await select(result) }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func definitionContent(_ result: DefinitionRepository.ResolvedDefinition) -> some View {
        switch result.content {
        case .wikt(let definition):
            WiktWordDefinitionView(definition: definition)
                .refreshable { await load() }
                .darkGradientBackground(colorScheme: colorScheme)
        case .norwegian(let definitions):
            NorwegianWordDefinitionView(word: word, initialDefinitions: definitions)
        }
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
        guard let wordLanguage else {
            usesFallback = true
            return
        }
        do {
            let appLanguage = WordleDataManager.explanationLanguage(for: Locale.preferredLanguages.first ?? "en")
            let result = try await DefinitionRepository.shared.resolvedDefinition(
                word: word,
                wordLanguage: wordLanguage,
                appLanguage: appLanguage
            )
            try Task.checkCancellation()
            resolvedDefinition = result
            definitionLanguage = result?.languageCode ?? appLanguage
            pickerLanguage = definitionLanguage
            availableDefinitions = result.map { [$0] } ?? []
            usesFallback = result == nil
            if result != nil {
                AnalyticsManager.shared.logDidViewWordDefinitionEvent(
                    word: word, language: language, numberOfLetters: word.count, viewSuccess: true
                )
            }
            if result != nil {
                await checkOtherDefinitionLanguages()
            }
        } catch {
            // The provider handles service failures; only cancellation reaches here.
        }
    }

    @MainActor
    private func checkOtherDefinitionLanguages() async {
        guard let wordLanguage, !isCheckingLanguages else { return }
        isCheckingLanguages = true
        let appLanguage = WordleDataManager.explanationLanguage(for: Locale.preferredLanguages.first ?? "en")
        availableDefinitions = await DefinitionRepository.shared.availableDefinitionLanguages(
            word: word,
            wordLanguage: wordLanguage,
            appLanguage: appLanguage
        )
        isCheckingLanguages = false
    }

    @MainActor
    private func select(_ result: DefinitionRepository.ResolvedDefinition) async {
        guard let wordLanguage, result.languageCode != definitionLanguage else { return }
        isChangingDefinition = true
        resolvedDefinition = result
        definitionLanguage = result.languageCode
        pickerLanguage = result.languageCode
        await DefinitionRepository.shared.remember(definitionLanguage: result.languageCode, forWordLanguage: wordLanguage)
        isChangingDefinition = false
    }

    private func languageName(_ code: String) -> String {
        if ["no", "nb", "nn"].contains(code) {
            return LanguageSelection.norwegian.localizedName
        }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? code.uppercased()
    }
}
