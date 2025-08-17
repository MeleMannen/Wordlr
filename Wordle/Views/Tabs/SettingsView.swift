//
//  SettingsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI
import GoogleMobileAds

struct SettingsView: View {
	@Environment(\.colorScheme) private var colorScheme
	@AppStorage("appTheme") private var appTheme: AppTheme = .dark
	@AppStorage("userWantsAds") var userWantsAds: Bool = true
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
	@AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
	
	@AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .all
	@AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
	@AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
	@AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
	
	var body: some View {
		GeometryReader { geometry in
			NavigationStack {
				List {
					Section {
						if #available(iOS 26.0, *) {
							Button(action: {
								if let url = URL(string: UIApplication.openSettingsURLString) {
									UIApplication.shared.open(url)
								}
							}, label: {
								HStack {
									Text("App Language:")
									
									Spacer()
									Text("\(Locale.current.localizedString(forIdentifier: String(Locale.preferredLanguages.first?.prefix(2) ?? "en"))?.capitalized ?? "English")")
										.fontWeight(.regular)
									
									Image(systemName: "chevron.right")
										.font(.caption).bold()
										.foregroundStyle(.primary)
								}
								.padding(.vertical, 4)
							})
							.padding(.vertical, 4)
						} else {
							Button(action: {
								if let url = URL(string: UIApplication.openSettingsURLString) {
									UIApplication.shared.open(url)
								}
							}, label: {
								HStack {
									Text("App Language:")
									
									Spacer()
									Text("\(Locale.current.localizedString(forIdentifier: String(Locale.preferredLanguages.first?.prefix(2) ?? "en"))?.capitalized ?? "English")")
										.fontWeight(.regular)
									
									Image(systemName: "chevron.right")
										.font(.caption).bold()
										.foregroundStyle(.primary)
								}
							})
						}
						
						
						Picker("App Theme:", selection: $appTheme) {
							Text("System")
								.tag(AppTheme.system)
							Text("Dark")
								.tag(AppTheme.dark)
							Text("Light")
								.tag(AppTheme.light)
							
						}
						.pickerStyle(.menu)
						.modifier(ConditionalGlassEffect())
						
						if self.colorScheme == .dark {
							Picker("Daily Word Theme:", selection: $userWantsNormalTheme) {
								Text("Standard")
									.tag(true)
								Text("Gold")
									.tag(false)
							}
							.pickerStyle(.menu)
							.modifier(ConditionalGlassEffect())
						}
						
					} header: {
						Text("General")
					}
					
					Section {
						Picker("Number of Letters:", selection: $defaultNumberOfLetters) {
							ForEach(1...8, id: \.self) { number in
								if number == 1 {
									Text("\(number) Letter")
										.tag(number)
								} else {
									Text("\(number) Letters")
										.tag(number)
								}
							}
							
						}
						.pickerStyle(.menu)
						.modifier(ConditionalGlassEffect())
						
						Picker("Language:", selection: $defaultLanguage) {
							ForEach(LanguageSelection.languages) { language in
								Text(language.localizedName.capitalized)
									.tag(language)
							}
							
						}
						.pickerStyle(.menu)
						.modifier(ConditionalGlassEffect())
						
					} header: {
						Text("Game (Default)")
					}
					
					Section {
						Picker("Number of Letters:", selection: $defaultStatNumberOfLetters) {
							ForEach(1...9, id: \.self) { number in
								if number == 1 {
									Text("\(number) Letter")
										.tag(number)
								} else if number != 9 {
									Text("\(number) Letters")
										.tag(number)
								} else {
									Text("All Letters")
										.tag(number)
								}
							}
							
						}
						.pickerStyle(.menu)
						.modifier(ConditionalGlassEffect())
						
						Picker("Language:", selection: $defaultStatLanguage) {
							ForEach(LanguageSelection.allCases) { language in
								if language == .all {
									Text("All")
										.tag(language)
								} else {
									Text(language.localizedName.capitalized)
										.tag(language)
								}
							}
							
						}
						.pickerStyle(.menu)
						.modifier(ConditionalGlassEffect())
						
						Picker("Gamemode:", selection: $defaultStatGameMode) {
							ForEach(GameMode.allCases) { mode in
								if mode == .both {
									Text("Both")
										.tag(mode)
								} else {
									Text(mode.localizedName.capitalized)
										.tag(mode)
								}
							}
						}
						.pickerStyle(.menu)
						.modifier(ConditionalGlassEffect())
						
						Picker("Show If Hints Used:", selection: $defaultStatHintsUsed) {
							ForEach(ShowsWhenHintsUsed.allCases) { mode in
								Text(mode.localizedName.capitalized)
									.tag(mode)
							}
						}
						.pickerStyle(.menu)
						.modifier(ConditionalGlassEffect())
						
					} header: {
						Text("Stats and History (Default)")
					}
					
					Section {
						if #available(iOS 26.0, *) {
							VStack {
								HStack {
									Text("Version:")
										.padding(.leading, 3)
										.padding(.vertical, 4)
									
									Spacer()
									
									Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"))")
										.fontWeight(.regular)
										.contextMenu {
											Button(action: {
												UIPasteboard.general.string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
											}) {
												Text("Copy")
												Image(systemName: "doc.on.doc")
											}
										}
								}
								.padding(.vertical, 4)
							}
						} else {
							VStack {
								HStack {
									Text("Version:")
										.padding(.leading, 3)
									
									Spacer()
									
									Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"))")
										.fontWeight(.regular)
										.contextMenu {
											Button(action: {
												UIPasteboard.general.string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
											}) {
												Text("Copy")
												Image(systemName: "doc.on.doc")
											}
										}
								}
							}
						}
					} header: {
						Text("About")
					}
				}
				.fontWeight(.medium)
				.navigationTitle("Settings")
				.safeAreaPadding(.bottom, self.userWantsAds ? 54 : 0)
			}
		}
	}
}



struct BannerViewContainer: UIViewRepresentable {
    typealias UIViewType = BannerView
    let adSize: AdSize
    
    init(_ adSize: AdSize) {
        self.adSize = adSize
    }
    
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = "ca-app-pub-7619403750703078/6852604335" // ca-app-pub-3940256099942544/2435281174
        banner.load(Request())
        banner.delegate = context.coordinator
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
    
    class BannerCoordinator: NSObject, BannerViewDelegate {
        let parent: BannerViewContainer
        
        init(_ parent: BannerViewContainer) {
            self.parent = parent
        }
        
        // MARK: - GADBannerViewDelegate methods
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("DID RECEIVE AD.")
            bannerView.alpha = 0
            UIView.animate(withDuration: 1, animations: {
                bannerView.alpha = 1
            })
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
