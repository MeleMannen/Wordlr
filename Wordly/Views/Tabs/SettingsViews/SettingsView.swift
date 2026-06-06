//
//  SettingsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 19/12/2024.
//

import SwiftUI
import GoogleMobileAds
import SwiftData
import StoreKit

struct SettingsView: View {
	@Environment(\.modelContext) private var context
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Environment(AdManager.self) private var adManager
	@Environment(StoreManager.self) private var storeManager
	@AppStorage("appTheme") private var appTheme: AppTheme = .dark
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("usesTransparentLists") private var usesTransparentLists: Bool = true
	@AppStorage("defaultLanguage") private var defaultLanguage: LanguageSelection = .norwegian
	@AppStorage("defaultNumberOfLetters") private var defaultNumberOfLetters: Int = 5
	
	@AppStorage("defaultStatLanguage") private var defaultStatLanguage: LanguageSelection = .all
	@AppStorage("defaultStatNumberOfLetters") private var defaultStatNumberOfLetters: Int = 9
	@AppStorage("defaultStatGameMode") private var defaultStatGameMode: GameMode = .both
	@AppStorage("defaultStatHintsUsed") private var defaultStatHintsUsed: ShowsWhenHintsUsed = .both
	
	@AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
	@AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
	@State private var showingNotificationSettingsAlert: Bool = false
	@State private var showingSupportEmailUnavailableAlert: Bool = false
	@State private var proSectionMaxY: CGFloat = 300
	@State private var gradientVisibility: Double = 0
	
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
			URLQueryItem(name: "body", value: "\n\n\nApp version: \(appVersionText)\(storeManager.isAdRemovalPurchased ? "" : "\nUser: Pro")")
		]
		return components.url
	}
	
	var body: some View {
		NavigationStack {
			List {
				if !storeManager.isAdRemovalPurchased {
					Section {
						VStack(spacing: 16) {
							HStack(spacing: 12) {
								Image(systemName: "crown.fill")
									.font(.title2)
									.foregroundStyle(.white)
									.frame(width: 48, height: 48)
									.background(.green, in: Circle())
								
								Text("Upgrade to Pro")
									.font(.title2).bold()
									.foregroundStyle(.primary)
								
								Spacer()
							}
							
							Text(storeManager.adRemovalProduct?.description ?? String(localized: "Ad-free experience, free hints, and priority support"))
								.font(.subheadline)
								.foregroundStyle(.secondary)
								.frame(maxWidth: .infinity, alignment: .leading)
							
							Button(action: {
								Task {
									await storeManager.purchaseAdRemoval()
								}
							}, label: {
								Group {
									if storeManager.isPurchasing {
										ProgressView()
											.tint(.white)
									} else if let product = storeManager.adRemovalProduct {
										Text("Upgrade to Pro - \(product.displayPrice)")
											.conditionalShadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
									} else {
										Text("Upgrade to Pro")
											.conditionalShadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
									}
								}
								.font(.headline)
								.foregroundStyle(.white)
								.frame(maxWidth: .infinity)
								.padding(.vertical, 14)
								.background {
									if #available(iOS 26.0, *) {
										RoundedRectangle(cornerRadius: 15)
											.foregroundStyle(Color(uiColor: .systemGreen))
									} else {
										RoundedRectangle(cornerRadius: 15)
											.foregroundStyle(.green)
									}
								}
							})
							.buttonStyle(.plain)
							.modifier(UpgradeToProButtonModifier())
							.accessibilityHint("Purchases Pro to remove ads and unlock free hints.")
							.disabled(storeManager.isPurchasing || storeManager.adRemovalProduct == nil)
							
							Button("Restore Purchases") {
								Task {
									await storeManager.restorePurchases()
								}
							}
							.buttonStyle(.plain)
							.font(.subheadline.weight(.medium))
							.underline()
							.foregroundStyle(.secondary)
							.accessibilityHint("Restores previous Pro purchases.")
						}
						.padding(16)
						.background {
							let cr: CGFloat = {
								if #available(iOS 26.0, *) { return 26 } else { return 16 }
							}()
							RoundedRectangle(cornerRadius: cr)
								.fill(.green.opacity(0.1))
								.overlay(
									RoundedRectangle(cornerRadius: cr)
										.strokeBorder(.green.opacity(0.3), lineWidth: 1)
								)
						}
						.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
						.listRowBackground(Color.clear)
						.listRowSeparator(.hidden)
						.overlay {
							GeometryReader { proxy in
								Color.clear.onChange(of: proxy.frame(in: .named("settingsList")).maxY) { _, newValue in
									proSectionMaxY = newValue
								}
								.onAppear {
									proSectionMaxY = proxy.frame(in: .named("settingsList")).maxY
								}
							}
						}
					}
				}
				
				Section {
					Button(action: {
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
					}, label: {
						HStack {
							SettingsRowLabel(title: "App language", systemImage: "globe")
							
							Spacer(minLength: 0)
							
							Text("\(Locale.current.localizedString(forIdentifier: String(Locale.preferredLanguages.first?.prefix(2) ?? "en"))?.capitalized ?? "")")
								.fontWeight(.regular)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
					})
					.wordlrListSectionRowBackground(.first)
					
					Picker(selection: $appTheme) {
						Text("System")
							.tag(AppTheme.system)
						Text("Dark")
							.tag(AppTheme.dark)
						Text("Light")
							.tag(AppTheme.light)
						
					} label: {
						SettingsRowLabel(title: "App theme", systemImage: "circle.lefthalf.filled")
					}
					.wordlrListSectionRowBackground(.middle)
					.pickerStyle(.menu)
					.conditionalHaptic(.selection, trigger: appTheme)
					.onChange(of: appTheme) { oldValue, newValue in
						AnalyticsManager.shared.logDidChangeThemeEvent(newTheme: newValue, oldTheme: oldValue)
					}
					
					
					if self.colorScheme == .dark {
						Picker(selection: $userWantsNormalTheme) {
							Text("Standard")
								.tag(true)
							Text("Gold")
								.tag(false)
						} label: {
							SettingsRowLabel(title: "Daily Wordlr theme", systemImage: "paintpalette")
						}
						.wordlrListSectionRowBackground(.middle)
						.pickerStyle(.menu)
						.conditionalHaptic(.selection, trigger: userWantsNormalTheme)
						.onChange(of: userWantsNormalTheme) {
							AnalyticsManager.shared.logDidChangeDailyWordThemeEvent(newTheme: userWantsNormalTheme ? "Standard" : "Gold")
						}
					}

					if #available(iOS 26.0, *) {
						Toggle(isOn: $usesTransparentLists) {
							SettingsRowLabel(title: "Transparent lists", systemImage: "list.bullet.rectangle")
						}
						.wordlrListSectionRowBackground(.middle)
						.tint(.green)
						.conditionalHaptic(.selection, trigger: usesTransparentLists)
					}
					
					Toggle(isOn: $hapticsEnabled) {
						SettingsRowLabel(title: "Haptic feedback", systemImage: "iphone.radiowaves.left.and.right")
					}
					.wordlrListSectionRowBackground(.last)
					.tint(.green)
				} header: {
					Text("General")
				}
				.wordlrListSectionBackground()
				
				Section {
					Toggle(isOn: $notificationsEnabled) {
						SettingsRowLabel(title: "Daily Wordlr reminders", systemImage: "bell")
					}
					.wordlrListSectionRowBackground(notificationsEnabled ? .first : .single)
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
							SettingsRowLabel(title: "Edit daily Wordlr reminders", systemImage: "calendar.badge.clock")
						}
						.wordlrListSectionRowBackground(.last)
						
						
					}
				} header: {
					Text("Reminders")
				}
				.wordlrListSectionBackground()
				
				Section {
					Picker(selection: $defaultNumberOfLetters) {
						ForEach(1...8, id: \.self) { number in
							if number == 1 {
								Text("\(number) letter")
									.tag(number)
							} else {
								Text("\(number) letters")
									.tag(number)
							}
						}
					} label: {
						SettingsRowLabel(title: "Word length", systemImage: "textformat.size")
					}
					.wordlrListSectionRowBackground(.first)
					.pickerStyle(.menu)
					.conditionalHaptic(.selection, trigger: defaultNumberOfLetters)
					
					Picker(selection: $defaultLanguage) {
						ForEach(LanguageSelection.languages) { language in
							Text(language.localizedName)
								.tag(language)
						}
					} label: {
						SettingsRowLabel(title: "Language", systemImage: "globe")
					}
					.wordlrListSectionRowBackground(.last)
					.pickerStyle(.menu)
					.conditionalHaptic(.selection, trigger: defaultLanguage)
					
					
				} header: {
					Text("Game (default)")
				}
				.wordlrListSectionBackground()
				
				Section {
					Picker(selection: $defaultStatNumberOfLetters) {
						ForEach(1...9, id: \.self) { number in
							if number == 1 {
								Text("\(number) letter")
									.tag(number)
							} else if number != 9 {
								Text("\(number) letters")
									.tag(number)
							} else {
								Text("Any length")
									.tag(number)
							}
						}
					} label: {
						SettingsRowLabel(title: "Word length", systemImage: "textformat.size")
					}
					.wordlrListSectionRowBackground(.first)
					.pickerStyle(.menu)
					.conditionalHaptic(.selection, trigger: defaultStatNumberOfLetters)
					
					Picker(selection: $defaultStatLanguage) {
						ForEach(LanguageSelection.allCases) { language in
							if language == .all {
								Text("All")
									.tag(language)
							} else {
								Text(language.localizedName)
									.tag(language)
							}
						}
					} label: {
						SettingsRowLabel(title: "Language", systemImage: "globe")
					}
					.wordlrListSectionRowBackground(.middle)
					.pickerStyle(.menu)
					.conditionalHaptic(.selection, trigger: defaultStatLanguage)
					
					Picker(selection: $defaultStatGameMode) {
						ForEach(GameMode.allCases) { mode in
							if mode == .both {
								Text("Both")
									.tag(mode)
							} else {
								Text(mode.localizedName)
									.tag(mode)
							}
						}
					} label: {
						SettingsRowLabel(title: "Gamemode", systemImage: "gamecontroller")
					}
					.wordlrListSectionRowBackground(.middle)
					.pickerStyle(.menu)
					.conditionalHaptic(.selection, trigger: defaultStatGameMode)
					
					Picker(selection: $defaultStatHintsUsed) {
						ForEach(ShowsWhenHintsUsed.allCases) { mode in
							Text(mode.localizedName)
								.tag(mode)
						}
					} label: {
						SettingsRowLabel(title: "Show if hints used", systemImage: "lightbulb.max.fill")
					}
					.wordlrListSectionRowBackground(.last)
					.pickerStyle(.menu)
					.conditionalHaptic(.selection, trigger: defaultStatHintsUsed)
					
				} header: {
					Text("Stats and history (default)")
				}
				.wordlrListSectionBackground()
				
				
				Section {
					Button(action: {
						AnalyticsManager.shared.logDidTapRateAppEvent()
						if let url = URL(string: "https://apps.apple.com/app/id6740833142?action=write-review") {
							UIApplication.shared.open(url)
						}
					}, label: {
						HStack {
							SettingsRowLabel(title: "Want to rate my app?", systemImage: "star")
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
					})
					.wordlrListSectionRowBackground(.first)
					
					ShareLink(item: URL(string: "https://apps.apple.com/app/id6740833142")!) {
						HStack {
							SettingsRowLabel(title: "Share app", systemImage: "square.and.arrow.up")
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
					}
					.wordlrListSectionRowBackground(.middle)
					.contextMenu {
						Button {
							UIPasteboard.general.string = "https://apps.apple.com/app/id6740833142"
						} label: {
							Label("Copy link", systemImage: "doc.on.doc")
						}
					}
					
					Button(action: {
						openSupportEmail()
					}, label: {
						HStack {
							SettingsRowLabel(title: "Send feedback", systemImage: "envelope")
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
						.contextMenu {
							Button(action: {
								UIPasteboard.general.string = supportEmailAddress
							}) {
								Image(systemName: "doc.on.doc")
								Text("Copy email")
							}
						}
					})
					.wordlrListSectionRowBackground(.middle)
					
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
							SettingsRowLabel(title: "Privacy options", systemImage: "hand.raised")
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
						
					})
					.wordlrListSectionRowBackground(.middle)
					
#if targetEnvironment(simulator)
					Button(action: {
						adManager.presentAdInspector()
						print("Ad Inspector presented.")
					}, label: {
						HStack {
							SettingsRowLabel(title: "Ad Inspector", systemImage: "hammer")
							
							
							Spacer(minLength: 0)
							
							Image(systemName: "arrow.up.right")
								.font(.caption).bold()
								.foregroundStyle(.secondary)
						}
					})
					.wordlrListSectionRowBackground(.middle)
#endif
					
					HStack {
						SettingsRowLabel(title: "Version", systemImage: "info.circle")
						
						Spacer(minLength: 0)
						
						Text(appVersionText)
							.fontWeight(.regular)
							.foregroundStyle(.secondary)
							.contextMenu {
								Button(action: {
									UIPasteboard.general.string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
								}) {
									Text("Copy version")
									Image(systemName: "doc.on.doc")
								}
							}
					}
					.wordlrListSectionRowBackground(.last)
					
				} header: {
					Text("About")
				}
				.wordlrListSectionBackground()
			}
			.fontWeight(.medium)
			.animation(.easeInOut(duration: 0.4), value: storeManager.isAdRemovalPurchased)
			.coordinateSpace(name: "settingsList")
			.scrollContentBackground(.hidden)
			.background {
				if colorScheme == .dark {
					if #available(iOS 26.0, *) {
						GeometryReader { geometry in
								let isPhone = UIDevice.current.userInterfaceIdiom == .phone
								let isLandscape = geometry.size.width > geometry.size.height
								let iPadAndMacOpacity = !storeManager.isAdRemovalPurchased ? max(0, min(1, proSectionMaxY / 300)) : 0
								let gradientOpacity = isPhone ? 0.42 : 0.34 * iPadAndMacOpacity
								let endRadius = isPhone ? 420 : min(max(geometry.size.width * 0.85, 520), isLandscape ? 680 : 900)
								RadialGradient(
									colors: [
										.green.opacity(gradientOpacity),
										.green.opacity(gradientOpacity * 0.43),
										.clear
									],
									center: .top,
									startRadius: 0,
									endRadius: endRadius
							)
							.opacity(isPhone ? 1 : gradientVisibility)
							.ignoresSafeArea()
						}
					} else if !storeManager.isAdRemovalPurchased {
						GeometryReader { geometry in
							let isPhone = UIDevice.current.userInterfaceIdiom == .phone
								let isLandscape = geometry.size.width > geometry.size.height
								let endRadius = isPhone ? 420 : min(max(geometry.size.width * 0.85, 520), isLandscape ? 680 : 900)
								let gradientOpacity = 0.34 * max(0, min(1, proSectionMaxY / 300))
								RadialGradient(
									colors: [
										.green.opacity(gradientOpacity),
										.green.opacity(gradientOpacity * 0.43),
										.clear
									],
									center: .top,
									startRadius: 0,
									endRadius: endRadius
							)
							.opacity(gradientVisibility)
							.ignoresSafeArea()
						}
					}
				}
			}
			.navigationTitle("Settings")
			.safeAreaPadding(.bottom, adManager.isBannerAdLoaded && !storeManager.isAdRemovalPurchased ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
			.tint(.secondary)
			.onAppear {
				AnalyticsManager.shared.logScreenViewed(screenName: "SettingsView")
				showInitialGradientIfNeeded()
			}
			.alert("No mail app available", isPresented: $showingSupportEmailUnavailableAlert) {
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

	private func showInitialGradientIfNeeded() {
		if reduceMotion {
			gradientVisibility = 1
		} else {
			withAnimation(.easeInOut(duration: 0.8)) {
				gradientVisibility = 1
			}
		}
	}
}

private struct SettingsRowLabel: View {
	private let iconWidth: CGFloat = 24
	private let rowMinHeight: CGFloat = 34
	
	let title: LocalizedStringKey
	let systemImage: String
	
	var body: some View {
		Label {
			Text(title)
				.alignmentGuide(.listRowSeparatorLeading) { dimensions in
					dimensions[.leading]
				}
		} icon: {
			Image(systemName: systemImage)
				.font(.body.weight(.medium))
				.frame(width: iconWidth, alignment: .center)
		}
		.foregroundStyle(.primary)
		.frame(minHeight: rowMinHeight, alignment: .center)
	}
}

private struct UpgradeToProButtonModifier: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			content
				.glassEffect(.regular.tint(.green).interactive(), in: .rect(cornerRadius: 14))
		} else {
			content
		}
	}
}



struct BannerViewContainer: UIViewRepresentable {
	typealias UIViewType = BannerView
	let adSize: AdSize
	let adManager: AdManager
	
	init(_ adSize: AdSize, adManager: AdManager) {
		self.adSize = adSize
		self.adManager = adManager
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
		adManager.bannerView = banner
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
			Task { @MainActor in
				self.parent.adManager.cancelBannerRetry()
				try? await Task.sleep(nanoseconds: 100_000_000)
				withAnimation(.easeInOut(duration: 0.6)) {
					self.parent.adManager.isBannerAdLoaded = true
				}
			}
			bannerView.alpha = 0
			UIView.animate(withDuration: 0.6, delay: 0.1, animations: {
				bannerView.alpha = 1
			})
		}
		
		func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
			Task { @MainActor in
				withAnimation(.easeInOut(duration: 0.4)) {
					self.parent.adManager.isBannerAdLoaded = false
				}
				self.parent.adManager.scheduleBannerRetry()
			}
			bannerView.alpha = 1
			UIView.animate(withDuration: 0.4, animations: {
				bannerView.alpha = 0
			})
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
