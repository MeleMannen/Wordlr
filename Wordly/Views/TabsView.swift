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
	@State var adManager: AdManager = AdManager()
	@State var tintColor: Color = .green
	
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
//											try? Tips.resetDatastore()
					try? Tips.configure([.datastoreLocation(.applicationDefault)])
				}
				.tint(.primary)
				
				
				StatsView()
					.tag(TabSelection.stats)
					.tabItem {
						if #available(iOS 18.0, *) {
							Label("Stats", systemImage: "chart.bar.yaxis")
						} else {
							Label("Stats", systemImage: "chart.bar.xaxis")
						}
					}
					.tint(.primary)
				
				HistoryView()
					.tag(TabSelection.history)
					.tabItem {
						if #available(iOS 18.0, *) {
							Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
						} else {
							Label("History", systemImage: "clock")
						}
					}
					.tint(.primary)
				
				SettingsView()
					.tag(TabSelection.settings)
					.tabItem {
						Label("Settings", systemImage: "gear")
					}
					.environment(adManager)
					.tint(.primary)
				
			}
			.tint(self.tintColor)
			.onChange(of: self.scenePhase) { _, newPhase in
				if newPhase == .active, self.userWantsAds {
					print("App became active, reloading banner ad")
				}
			}
			.safeAreaInset(edge: .bottom) { bottomAd(for: geometry) }
			.preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
			.onAppear {
				if !self.hasTurnedOnAds {
					self.userWantsAds = true
					self.hasTurnedOnAds = true
				}
				if #available(iOS 26.0, *) {
					self.tintColor = .green
				} else {
					self.tintColor = .primary
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
				await adManager.prepareAds()
			}
		}
	}
	
	@ViewBuilder
	private func bottomAd(for geometry: GeometryProxy) -> some View {
		if self.userWantsAds &&
			(self.selection != .home ||
			 (self.selection == .home && adManager.shouldShowAds &&
			  (adManager.currentSelectView == .selectView ||
			   adManager.currentSelectView == .searchView ||
			   adManager.currentSelectView == .filterOptionsView ||
			   adManager.currentSelectView == .infoView))) &&
			adManager.canRequestAds &&
			adManager.isAdsReady {
			
			if #available(iOS 26.0, *), UIDevice.current.userInterfaceIdiom == .phone {
				let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width - (geometry.size.width / 11))
				BannerViewContainer(adSize)
					.frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
					.padding(.bottom, 54)
//					.id(bannerReloadID)
			} else if #available(iOS 18.0, *),
					  UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
				let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
				BannerViewContainer(adSize)
					.frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
//					.id(bannerReloadID)
			} else {
				let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
				BannerViewContainer(adSize)
					.frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
					.padding(.bottom, 49)
//					.id(bannerReloadID)
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
	var isAdsReady = false
	
	var canRequestAds: Bool {
		return ConsentInformation.shared.canRequestAds
	}
	
	var shouldShowPrivacyOptionsButton: Bool {
		ConsentInformation.shared.privacyOptionsRequirementStatus == .required
	}
	
	func prepareAds() async {
		isAdsReady = false
		do {
			try await gatherConsent()
			
			guard canRequestAds else {
				print("Ads cannot be requested yet.")
				return
			}
			
			let status = await requestTrackingAuthorizationIfNeeded()
			print("ATT status: \(status.rawValue)")
			
			startGoogleMobileAdsSDK()
			
			isAdsReady = isMobileAdsStartCalled
			
		} catch {
			print("Consent flow error: \(error)")
		}
	}
	
	func gatherConsent() async throws {
		let parameters = RequestParameters()
		
		let debugSettings = DebugSettings()
		parameters.debugSettings = debugSettings
		
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { error in
				if let error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume()
				}
			}
		}
		
		try await ConsentForm.loadAndPresentIfRequired(from: nil)
	}
	
	func requestTrackingAuthorizationIfNeeded() async -> ATTrackingManager.AuthorizationStatus {
		guard #available(iOS 14, *) else {
			return .authorized
		}
		
		let currentStatus = ATTrackingManager.trackingAuthorizationStatus
		guard currentStatus == .notDetermined else { return currentStatus }
		return await withCheckedContinuation { continuation in
		     ATTrackingManager.requestTrackingAuthorization { status in
		         continuation.resume(returning: status)
		     }
		}
	}
	
	func startGoogleMobileAdsSDK() {
		print("this happens now!")
		guard canRequestAds, !isMobileAdsStartCalled else {
			return
		}
		
#if targetEnvironment(simulator)
		let testDeviceIdentifiers = ["AC276EF4-3093-42DF-8DE1-84C495BF8585"]
		MobileAds.shared.requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers
#endif
		
		MobileAds.shared.start()
		isMobileAdsStartCalled = true
	}
	
	func presentPrivacyOptionsForm() async throws {
		try await ConsentForm.presentPrivacyOptionsForm(from: nil)
	}
	
	func presentAdInspector(from viewController: UIViewController? = nil) {
		guard isMobileAdsStartCalled else {
			print("Google Mobile Ads SDK not started yet")
			return
		}
		
		MobileAds.shared.presentAdInspector(from: viewController) { error in
			if let error {
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

