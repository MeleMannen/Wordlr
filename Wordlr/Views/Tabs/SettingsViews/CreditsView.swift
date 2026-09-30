import SwiftUI
import WebKit

struct CreditsView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(AdManager.self) private var adManager
	@State private var selectedLink: URL?

	private let dictionaryCredits: [(title: LocalizedStringKey, description: LocalizedStringKey, links: [(label: LocalizedStringKey, url: URL)])] = [
		(
			"WiktAPI.dev",
			"Definitions from Wiktionary, provided by WiktAPI.dev using data processed by kaikki.org.",
			[
				("WiktAPI.dev", URL(string: "https://wiktapi.dev")!),
				("Wiktionary", URL(string: "https://en.wiktionary.org/wiki/Wiktionary:Copyrights")!),
				("kaikki.org", URL(string: "https://kaikki.org")!),
				("CC BY-SA 4.0", URL(string: "https://creativecommons.org/licenses/by-sa/4.0/")!)
			]
		),
		(
			"Ordbøkene.no",
			"Definitions from Bokmålsordboka and Nynorskordboka, published by Språkrådet and the University of Bergen.",
			[
				("Ordbøkene.no", URL(string: "https://ordbokene.no")!),
				("Citation guidance", URL(string: "https://ordbokene.no/nob/help/cite")!),
				("Open data", URL(string: "https://ordbokene.no/eng/about/open-data")!)
			]
		),
		(
			"FreeDictionaryAPI.com",
			"Definitions from Wiktionary, provided by FreeDictionaryAPI.com.",
			[
				("FreeDictionaryAPI.com", URL(string: "https://freedictionaryapi.com")!),
				("Wiktionary", URL(string: "https://en.wiktionary.org")!),
				("CC BY-SA 4.0", URL(string: "https://creativecommons.org/licenses/by-sa/4.0/")!)
			]
		),
		(
			"DictionaryAPI.dev",
			"Definitions provided by DictionaryAPI.dev.",
			[("DictionaryAPI.dev", URL(string: "https://dictionaryapi.dev")!)]
		),

		(
			"Det Norske Akademis ordbok (NAOB)",
			"Definitions from Det Norske Akademis ordbok (NAOB).",
			[("About NAOB", URL(string: "https://naob.no/om")!)]
		)
	]

	var body: some View {
		List {
			Section {
				ForEach(Array(dictionaryCredits.enumerated()), id: \.offset) { index, credit in
					creditRow(credit)
						.wordlrListSectionRowBackground(.single)
						.listRowSeparator(.hidden)
				}
			} header: {
				Text("Dictionary sources")
			}
		}
		.listStyle(.insetGrouped)
		.listRowSpacing(12)
		.fontWeight(.medium)
		.scrollContentBackground(.hidden)
		.darkGradientBackground(colorScheme: colorScheme)
		.environment(\.openURL, OpenURLAction { url in
			if #available(iOS 26.0, *) {
				selectedLink = url
				return .handled
			}
			return .systemAction
		})
		.navigationDestination(item: $selectedLink) { url in
			if #available(iOS 26.0, *) {
				WebView(url: url)
					.navigationTitle(url.host() ?? "")
					.navigationBarTitleDisplayMode(.inline)
					.ignoresSafeArea(.all, edges: .bottom)
			}
		}
		.navigationTitle("Credits")
		.navigationBarTitleDisplayMode(.inline)
		.safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
	}

	private func creditRow(_ credit: (title: LocalizedStringKey, description: LocalizedStringKey, links: [(label: LocalizedStringKey, url: URL)])) -> some View {
		VStack(alignment: .leading, spacing: 9) {
			VStack(alignment: .leading, spacing: 5) {
				Text(credit.title)
					.font(.headline)
				Text(credit.description)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}

			VStack(alignment: .leading, spacing: 0) {
				creditLinks(credit.links)
			}
		}
		.padding(.vertical, 5)
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	@ViewBuilder
	private func creditLinks(_ links: [(label: LocalizedStringKey, url: URL)]) -> some View {
		ForEach(Array(links.enumerated()), id: \.offset) { index, link in
			Link(destination: link.url) {
				HStack(spacing: 8) {
					Text(link.label)
						.font(.footnote.weight(.semibold))
						.fixedSize(horizontal: false, vertical: true)
					Spacer(minLength: 8)
					Image(systemName: "arrow.up.right")
						.font(.caption.weight(.semibold))
						.accessibilityHidden(true)
				}
				.frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
				.contentShape(Rectangle())
				.overlay(alignment: .bottom) {
					if index < links.count - 1 {
						Rectangle()
							.fill(Color.primary.opacity(0.12))
							.frame(height: 1)
					}
				}
			}
			.buttonStyle(.plain)
			.tint(.green)
			.accessibilityLabel(link.label)
		}
	}
}
