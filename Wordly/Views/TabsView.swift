//
//  TabsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 28/09/2025.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import UserMessagingPlatform
import AppTrackingTransparency
import TipKit

struct TabsView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) var modelContext
	@AppStorage("appTheme") private var appTheme: AppTheme = .dark
	@AppStorage("userWantsAds") var userWantsAds: Bool = true
	@AppStorage("hasTurnedOnAds") private var hasTurnedOnAds: Bool = false
	@AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
	@AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
	@State var selection: TabSelection = .home
	@State private var bannerReloadID = UUID()
	@State var adManager: AdManager = AdManager()
	
	var body: some View {
		GeometryReader { geometry in
			TabView(selection: $selection) {
				NavigationStack {
					SelectView(selection: self.$selection)
					
				}
				.tag(TabSelection.home)
				.tabItem {
					Label(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordly", systemImage: self.userWantsThePhraseNameBack ? "p.square.fill" : "w.square.fill")
				}
				.environment(adManager)
				.task {
					//						#warning("Resetting the datastore is only for testing purposes, remove this in production!")
					//						try? Tips.resetDatastore()
					try? Tips.configure([
						//							.displayFrequency(.monthly),
						.datastoreLocation(.applicationDefault)
					])
				}
				
				
				StatsView()
					.tag(TabSelection.stats)
					.tabItem {
						Label("Stats", systemImage: "chart.bar.yaxis")
					}
				
				HistoryView()
					.tag(TabSelection.history)
					.tabItem {
						Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
					}
				
				SettingsView()
					.tag(TabSelection.settings)
					.tabItem {
						Label("Settings", systemImage: "gear")
					}
					.environment(adManager)
				
			}
			.onChange(of: self.scenePhase) { _, newPhase in
				if newPhase == .active, self.userWantsAds {
					print("App became active, reloading banner ad")
					self.bannerReloadID = UUID()
				}
			}
			.safeAreaInset(edge: .bottom) {
				if self.userWantsAds && (self.selection != .home || (self.selection == .home && adManager.shouldShowAds && (adManager.currentSelectView == .selectView || adManager.currentSelectView == .searchView || adManager.currentSelectView == .filterOptionsView || adManager.currentSelectView == .infoView))) && adManager.canRequestAds {
					if #available(iOS 26.0, *), UIDevice.current.userInterfaceIdiom == .phone {
						let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width - (geometry.size.width / 11))
						BannerViewContainer(adSize)
							.frame(width: adSize.size.width < 0 ? 0 : adSize.size.width, height: adSize.size.height < 0 ? 0 : adSize.size.height)
							.padding(.bottom, 54)
							.id(bannerReloadID)
					} else if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
						let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
						BannerViewContainer(adSize)
							.frame(width: adSize.size.width < 0 ? 0 : adSize.size.width, height: adSize.size.height < 0 ? 0 : adSize.size.height)
							.id(bannerReloadID)
					} else {
						let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
						BannerViewContainer(adSize)
							.frame(width: adSize.size.width < 0 ? 0 : adSize.size.width, height: adSize.size.height < 0 ? 0 : adSize.size.height)
							.padding(.bottom, 49)
							.id(bannerReloadID)
					}
				}
			}
			.tint(.primary)
			.preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
			.onAppear {
				if !self.hasTurnedOnAds {
					self.userWantsAds = true
					self.hasTurnedOnAds = true
				}
			}
			.task(id: notificationsEnabled) {
				if notificationsEnabled {
					NotificationManager.requestPermission() { result in
						switch result {
						case .success(let granted):
							if granted {
								print("Notification permission granted.")
								UNUserNotificationCenter.current().delegate = NotificationsDelegate.shared
								let reminders = NotificationManager.fetchReminders(context: modelContext)
								for reminder in reminders {
									NotificationManager.scheduleDailyWordReminder(reminder: reminder)
								}
							} else {
								print("Notification permission denied.")
								UserDefaults.standard.set(false, forKey: "notificationsEnabled")
							}
						case .failure(let error):
							print("Error requesting notification permission: \(error)")
							UserDefaults.standard.set(false, forKey: "notificationsEnabled")
						}
					}
				}
			}
			.task {
				adManager.gatherConsent() { result in
					if let error = result {
						print("Error gathering consent: \(error)")
					} else {
						print("Consent gathered successfully.")
						ATTrackingManager.requestTrackingAuthorization { status in
							switch status {
								case .notDetermined, .restricted, .denied, .authorized:
									Task { @MainActor in
										if userWantsAds {
											adManager.startGoogleMobileAdsSDK()
										}
									}
								@unknown default:
									Task { @MainActor in
										if userWantsAds {
											adManager.startGoogleMobileAdsSDK()
										}
									}
							}
							
						}
					}
				}
			}
		}
	}
}

@MainActor
@Observable
final class AdManager {
	var currentSelectView: CurrentSelectView = .selectView
	var shouldShowAds: Bool = true
	var isMobileAdsStartCalled = false
	
	var canRequestAds: Bool {
		return ConsentInformation.shared.canRequestAds
	}
	
	/// Helper method to call the UMP SDK methods to request consent information and load/present a
	/// consent form if necessary.
	func gatherConsent(consentGatheringComplete: @escaping (Error?) -> Void) {
		// ConsentInformation.shared.reset()
		let parameters = RequestParameters()
		
		// For testing purposes, you can use UMPDebugGeography to simulate a location.
		let debugSettings = DebugSettings()
		// debugSettings.geography = DebugGeography.EEA
		parameters.debugSettings = debugSettings
		
		// Requesting an update to consent information should be called on every app launch.
		ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) {
			requestConsentError in
			guard requestConsentError == nil else {
				return consentGatheringComplete(requestConsentError)
			}
			
			Task { @MainActor in
				do {
					try await ConsentForm.loadAndPresentIfRequired(from: nil)
					consentGatheringComplete(nil)
				} catch {
					consentGatheringComplete(error)
				}
			}
		}
	}
	
	/// Helper method to call the UMP SDK method to present the privacy options form.
	@MainActor func presentPrivacyOptionsForm() async throws {
		try await ConsentForm.presentPrivacyOptionsForm(from: nil)
	}
	
	/// Method to initialize the Google Mobile Ads SDK. The SDK should only be initialized once.
	func startGoogleMobileAdsSDK() {
		guard canRequestAds, !isMobileAdsStartCalled else { return }
#if targetEnvironment(simulator) //DEBUG
								 //		#warning("Remove this before deploying to production.")
		let testDeviceIdentifiers = ["AC276EF4-3093-42DF-8DE1-84C495BF8585"]
		MobileAds.shared.requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers
#endif
		
		MobileAds.shared.start()
		isMobileAdsStartCalled = true
		
	}
	
	/// Method to present the Google AdMob Ad Inspector for debugging ads
	@MainActor
	func presentAdInspector(from viewController: UIViewController? = nil) {
		guard isMobileAdsStartCalled else {
			print("Google Mobile Ads SDK not started yet")
			return
		}
		
		MobileAds.shared.presentAdInspector(from: viewController) { error in
			if let error = error {
				print("Ad Inspector presentation failed: \(error.localizedDescription)")
			} else {
				print("Ad Inspector presented successfully")
			}
		}
	}
}

#Preview {
    TabsView()
}

