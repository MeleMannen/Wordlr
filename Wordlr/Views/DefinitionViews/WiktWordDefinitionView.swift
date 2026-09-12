import SwiftUI

struct WiktWordDefinitionView: View {
    let definition: WiktDefinition
    @Environment(AdManager.self) private var adManager

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(Array(definition.definitions.enumerated()), id: \.offset) { _, entry in
                    entryCard(entry)
                }
            }
            .padding(15)
        }
        .safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 100 : 75) : 0)
        .textSelection(.enabled)
    }

    private func entryCard(_ entry: WiktDefinition.Entry) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(definition.word)
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(partOfSpeech(entry.pos))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text("EXPLANATION AND USAGE")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            ForEach(Array(entry.senses.enumerated()), id: \.offset) { index, sense in
                if index > 0 { Divider() }
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .font(.body.monospacedDigit().bold())
                        .foregroundStyle(.secondary)
                    senseContent(sense)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 25)
        .padding(.bottom, 64)
        .frame(maxWidth: .infinity, alignment: .leading)
        .wordlrSurface(cornerRadius: 20)
        .overlay(alignment: .bottomTrailing) {
            sourceLink
        }
    }

    @ViewBuilder
    private var sourceLink: some View {
        if let sourceURL = definition.sourceURL {
            if #available(iOS 26.0, *) {
                Link(sourceURL.host() ?? "wiktionary.org", destination: sourceURL)
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.trailing, 16)
                    .padding(.bottom, 14)
                    .onOpenURL(prefersInApp: true)
            } else {
                Link(sourceURL.host() ?? "wiktionary.org", destination: sourceURL)
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.trailing, 16)
                    .padding(.bottom, 14)
            }
        }
    }

    private func senseContent(_ sense: WiktDefinition.Sense) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let tags = sense.tags, !tags.isEmpty {
                Text(tags.map { NSLocalizedString($0, comment: "Dictionary usage label").replacingOccurrences(of: "-", with: " ") }.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(Array(sense.explanations.enumerated()), id: \.offset) { _, gloss in
                Text(gloss).fixedSize(horizontal: false, vertical: true)
            }
            if let examples = sense.examples, !examples.isEmpty {
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                            exampleContent(example)
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    Text("EXAMPLE").font(.subheadline.bold())
                }
            }
        }
    }

    private func exampleContent(_ example: WiktDefinition.Example) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let text = example.text, !text.isEmpty { Text(text).italic() }
            if let roman = example.roman, !roman.isEmpty { Text(roman).foregroundStyle(.secondary) }
            if let translation = example.translation ?? example.english, !translation.isEmpty {
                Text(translation).foregroundStyle(.secondary)
            }
            if let reference = example.ref, !reference.isEmpty {
                Text(reference).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func partOfSpeech(_ code: String) -> String {
        let names = ["noun": "Noun", "verb": "Verb", "adj": "Adjective", "adv": "Adverb",
                     "intj": "Interjection", "pron": "Pronoun", "prep": "Preposition",
                     "conj": "Conjunction", "det": "Determiner", "num": "Numeral",
                     "name": "Proper noun", "phrase": "Phrase", "proverb": "Proverb",
                     "article": "Article", "particle": "Particle", "suffix": "Suffix", "prefix": "Prefix"]
        return NSLocalizedString(names[code] ?? code, comment: "Dictionary part of speech")
    }
}
