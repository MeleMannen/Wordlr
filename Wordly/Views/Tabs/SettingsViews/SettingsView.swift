//
//  SettingsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI
import GoogleMobileAds
import SwiftData

struct SettingsView: View {
	@Environment(\.modelContext) private var context
	@Environment(\.colorScheme) private var colorScheme
	@Environment(AdManager.self) private var adManager
	@AppStorage("appTheme") private var appTheme: AppTheme = .dark
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
	@AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
	
	@AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .all
	@AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
	@AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
	@AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
	
	@AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
	@State private var showingNotificationSettingsAlert: Bool = false
	@State private var showingSupportEmailUnavailableAlert: Bool = false
	
	@Query(sort: \DailyWordReminder.timeToFire) private var dailyWordReminders: [DailyWordReminder]
	
	private let supportEmailAddress = "kristoffer.fredrik@icloud.com"
	
	private var notificationTime: Date = {
		let calendar = Calendar.current
		return calendar.date(from: DateComponents(year: 2025, month: 9, day: 1, hour: 18, minute: 0)) ?? Date()
	}()
	
	private var appVersionText: String {
		"\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"))"
	}
	
	private var supportEmailURL: URL? {
		var components = URLComponents()
		components.scheme = "mailto"
		components.path = supportEmailAddress
		components.queryItems = [
			URLQueryItem(name: "subject", value: "Wordlr Feedback"),
			URLQueryItem(name: "body", value: "\n\n\nApp version: \(appVersionText)")
		]
		return components.url
	}
	
	private let aboutRowIconWidth: CGFloat = 28
	
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Button(action: {
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
					}, label: {
						HStack {
							Text("App Language")
								.foregroundStyle(.primary)
							
							Spacer(minLength: 0)
							
							Text("\(Locale.current.localizedString(forIdentifier: String(Locale.preferredLanguages.first?.prefix(2) ?? "en"))?.capitalized ?? "")")
								.fontWeight(.regular)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
					})
					.modifier(ConditionalPadding())
					
					Picker("App Theme", selection: $appTheme) {
						Text("System")
							.tag(AppTheme.system)
						Text("Dark")
							.tag(AppTheme.dark)
						Text("Light")
							.tag(AppTheme.light)
						
					}
					.modifier(ConditionalPadding())
					.pickerStyle(.menu)
					.sensoryFeedback(.selection, trigger: appTheme)
					.onChange(of: appTheme) { oldValue, newValue in
						AnalyticsManager.shared.logDidChangeThemeEvent(newTheme: newValue, oldTheme: oldValue)
					}
					
					
					if self.colorScheme == .dark {
						Picker("Daily Wordlr Theme", selection: $userWantsNormalTheme) {
							Text("Standard")
								.tag(true)
							Text("Gold")
								.tag(false)
						}
						.modifier(ConditionalPadding())
						.pickerStyle(.menu)
						.sensoryFeedback(.selection, trigger: userWantsNormalTheme)
						.onChange(of: userWantsNormalTheme) {
							AnalyticsManager.shared.logDidChangeDailyWordThemeEvent(newTheme: userWantsNormalTheme ? "Standard" : "Gold")
						}
					}
				} header: {
					Text("General")
				}
				
				Section {
					Toggle("Daily Wordlr Reminders", isOn: $notificationsEnabled)
						.modifier(ConditionalPadding())
						.tint(.green)
						.onChange(of: notificationsEnabled) { _, newValue in
							if newValue {
								NotificationManager.requestPermission() { result in
									switch result {
										case .success(let granted):
											if granted {
												print("Permission granted")
											} else {
												print("Permission denied")
												notificationsEnabled = false
											}
										case .failure(let error):
											print("Error requesting permission: \(error)")
											notificationsEnabled = false
											self.showingNotificationSettingsAlert = true
									}
									
								}
								UNUserNotificationCenter.current().delegate = NotificationsDelegate.shared
								if dailyWordReminders.isEmpty {
									let reminder = DailyWordReminder(language: self.defaultLanguage, numberOfLetters: self.defaultNumberOfLetters, timeToFire: self.notificationTime)
									context.insert(reminder)
									scheduleNotification(reminder: reminder)
									try? context.save()
									
								} else {
									for reminder in dailyWordReminders {
										if reminder.isEnabled {
											scheduleNotification(reminder: reminder)
										}
									}
								}
							} else {
								for reminder in dailyWordReminders {
									if reminder.isEnabled {
										NotificationManager.cancelDailyWordReminder(reminder: reminder)
									}
								}
							}
						}
						.alert("To enable notifications, please go to Settings and allow notifications for this app.", isPresented: $showingNotificationSettingsAlert) {
							Button("OK", role: .cancel) { }
							Button("Settings") {
								if let appSettings = URL(string: UIApplication.openSettingsURLString) {
									UIApplication.shared.open(appSettings)
								}
							}
							
						}
					
					if notificationsEnabled {
						NavigationLink {
							NotificationView()
						} label: {
							Text("Edit Daily Wordlr Reminders")
								.foregroundStyle(.primary)
								.modifier(ConditionalPadding())
						}
						
						
					}
				} header: {
					Text("Reminders")
				}
				
				Section {
					Picker("Number of Letters", selection: $defaultNumberOfLetters) {
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
					.modifier(ConditionalPadding())
					.pickerStyle(.menu)
					.sensoryFeedback(.selection, trigger: defaultNumberOfLetters)
					
					Picker("Language", selection: $defaultLanguage) {
						ForEach(LanguageSelection.languages) { language in
							Text(language.localizedName.capitalized)
								.tag(language)
						}
						
					}
					.modifier(ConditionalPadding())
					.pickerStyle(.menu)
					.sensoryFeedback(.selection, trigger: defaultLanguage)
					
					
				} header: {
					Text("Game (Default)")
				}
				
				Section {
					Picker("Number of Letters", selection: $defaultStatNumberOfLetters) {
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
					.modifier(ConditionalPadding())
					.pickerStyle(.menu)
					.sensoryFeedback(.selection, trigger: defaultStatNumberOfLetters)
					
					Picker("Language", selection: $defaultStatLanguage) {
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
					.modifier(ConditionalPadding())
					.pickerStyle(.menu)
					.sensoryFeedback(.selection, trigger: defaultStatLanguage)
					
					Picker("Gamemode", selection: $defaultStatGameMode) {
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
					.modifier(ConditionalPadding())
					.pickerStyle(.menu)
					.sensoryFeedback(.selection, trigger: defaultStatGameMode)
					Picker("Show If Hints Used", selection: $defaultStatHintsUsed) {
						ForEach(ShowsWhenHintsUsed.allCases) { mode in
							Text(mode.localizedName.capitalized)
								.tag(mode)
						}
					}
					.modifier(ConditionalPadding())
					.pickerStyle(.menu)
					.sensoryFeedback(.selection, trigger: defaultStatHintsUsed)
					
				} header: {
					Text("Stats and History (Default)")
				}
				
				
				Section {
					Button(action: {
						AnalyticsManager.shared.logDidTapRateAppEvent()
						if let url = URL(string: "https://apps.apple.com/app/id6740833142?action=write-review") {
							UIApplication.shared.open(url)
						}
					}, label: {
						HStack {
							Image(systemName: "star")
								.font(.title2)
								.foregroundStyle(.primary)
								.frame(width: aboutRowIconWidth, alignment: .center)
							
							Text("Want To Rate My App?")
								.foregroundStyle(.primary)
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
					})
					
					Button(action: {
						openSupportEmail()
					}, label: {
						HStack {
							Image(systemName: "envelope")
								.font(.title2)
								.foregroundStyle(.primary)
								.frame(width: aboutRowIconWidth, alignment: .center)
							
							Text("Send Feedback")
								.foregroundStyle(.primary)
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
						.contextMenu {
							Button(action: {
								UIPasteboard.general.string = supportEmailAddress
							}) {
								Text("Copy email address")
								
								Image(systemName: "doc.on.doc")
							}
						}
					})
					
					Button(action: {
						Task {
							do {
								try await adManager.presentPrivacyOptionsForm()
							} catch {
								print("Error presenting consent form: \(error)")
							}
						}
					}, label: {
						HStack {
							Image(systemName: "hand.raised")
								.font(.title2)
								.foregroundStyle(.primary)
								.frame(width: aboutRowIconWidth, alignment: .center)
							
							Text("Privacy Options")
								.foregroundStyle(.primary)
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
						
					})
					
#if targetEnvironment(simulator)
					Button(action: {
						adManager.presentAdInspector()
						print("Ad Inspector presented.")
					}, label: {
						HStack {
							Image(systemName: "hammer")
								.font(.title2)
								.foregroundStyle(.primary)
								.frame(width: aboutRowIconWidth, alignment: .center)
							
							Text("Ad Inspector")
								.foregroundStyle(.primary)
							
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
					})
#endif
					
					VStack {
						HStack {
							Image(systemName: "info.circle")
								.font(.title2)
								.foregroundStyle(.primary)
								.frame(width: aboutRowIconWidth, alignment: .center)
							Text("Version")
							
							Spacer(minLength: 0)
							
							Text(appVersionText)
								.fontWeight(.regular)
								.foregroundStyle(.secondary)
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
					
				} header: {
					Text("About")
				}
			}
			.fontWeight(.medium)
			.navigationTitle("Settings")
			.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
			.tint(.secondary)
			.onAppear {
				AnalyticsManager.shared.logScreenViewed(screenName: "SettingsView")
			}
			.alert("No Mail App Available", isPresented: $showingSupportEmailUnavailableAlert) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("The support email address has been copied to the clipboard.")
			}
		}
	}
	
	private func openSupportEmail() {
		guard let url = supportEmailURL, UIApplication.shared.canOpenURL(url) else {
			copySupportEmailAndShowAlert()
			return
		}
		
		UIApplication.shared.open(url) { didOpen in
			if !didOpen {
				DispatchQueue.main.async {
					copySupportEmailAndShowAlert()
				}
			}
		}
	}
	
	private func copySupportEmailAndShowAlert() {
		UIPasteboard.general.string = supportEmailAddress
		showingSupportEmailUnavailableAlert = true
	}
	
	private func scheduleNotification(reminder: DailyWordReminder) {
		if notificationsEnabled {
			NotificationManager.scheduleDailyWordReminder(reminder: reminder, context: context)
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
		//		#warning("Replace the ad unit ID with your own ad unit ID when deploying to production.")
#if targetEnvironment(simulator)
		banner.adUnitID = "ca-app-pub-3940256099942544/2435281174" // ca-app-pub-7619403750703078/6852604335
#else
		banner.adUnitID = "ca-app-pub-7619403750703078/6852604335" // ca-app-pub-3940256099942544/2435281174
#endif
		
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
			//			print("FAILED TO RECEIVE AD: \(error.localizedDescription), error code: \(error._code), error: \(error)")
			let errorDomain = error._domain
			let errorCode = error._code
			let errorMessage = error.localizedDescription
			let responseInfo = (error as NSError).userInfo[GADErrorUserInfoKeyResponseInfo] as? ResponseInfo
			let underlyingError = (error as NSError).userInfo[NSUnderlyingErrorKey] as? Error
			if let responseInfo = responseInfo {
				print("Received error with domain: \(errorDomain), code: \(errorCode), "
					  + "message: \(errorMessage), responseInfo: \(responseInfo), "
					  + "underlyingError: \(underlyingError?.localizedDescription ?? "nil")")
			}
		}
		
		func bannerViewDidRecordClick(_ bannerView: BannerView) {
			print("Banner ad clicked.")
		}
		
		func bannerViewDidDismissScreen(_ bannerView: BannerView) {
			print("Banner ad dismissed.")
		}
		
		func bannerViewDidRecordImpression(_ bannerView: BannerView) {
			print("Banner ad impression recorded.")
		}
		
		func bannerViewWillDismissScreen(_ bannerView: BannerView) {
			print("Banner ad will dismiss screen.")
		}
		
		func bannerViewWillPresentScreen(_ bannerView: BannerView) {
			print("Banner ad will present screen.")
		}
	}
}

#Preview {
	SettingsView()
}
