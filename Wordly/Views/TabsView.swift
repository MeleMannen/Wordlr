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
import FirebaseAnalytics
import Network

struct TabsView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) var modelContext
	@AppStorage("appTheme") private var appTheme: AppTheme = .dark
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
					.environment(adManager)
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
					.environment(adManager)
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
				if newPhase == .active {
					print("App became active, reloading banner ad")
					Task {
						await adManager.prepareAdsIfNeeded()
					}
				}
			}
			.safeAreaInset(edge: .bottom) { bottomAd(for: geometry) }
			.preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
			.onAppear {
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
				adManager.startMonitoringConnectivity()
			}
			.task {
				await adManager.prepareAds()
			}
		}
	}
	
	@ViewBuilder
	private func bottomAd(for geometry: GeometryProxy) -> some View {
		let _ = print("Checking ad display conditions: selection: \(self.selection), shouldShowAds: \(adManager.shouldShowAds), currentSelectView: \(adManager.currentSelectView), canRequestAds: \(adManager.canRequestAds), isAdsReady: \(adManager.isAdsReady)")
		if (self.selection != .home ||
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
					.padding(.bottom, 55)
				let _ = print("iOS 26 or later on iPhone, ad width: \(adSize.size.width), geometry width: \(geometry.size.width)")
				
			} else if #available(iOS 18.0, *),
					  UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
				let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
				BannerViewContainer(adSize)
					.frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
			} else {
				let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
				BannerViewContainer(adSize)
					.frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
					.padding(.bottom, 49)
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
	private var isPreparingAds = false
	private let pathMonitor = NWPathMonitor()
	private var hasStartedPathMonitor = false
	
	var canRequestAds: Bool {
		return ConsentInformation.shared.canRequestAds
	}
	
	var shouldShowPrivacyOptionsButton: Bool {
		ConsentInformation.shared.privacyOptionsRequirementStatus == .required
	}
	
	func startMonitoringConnectivity() {
		guard !hasStartedPathMonitor else { return }
		hasStartedPathMonitor = true
		pathMonitor.pathUpdateHandler = { [weak self] path in
			guard path.status == .satisfied else { return }
			Task { @MainActor in
				await self?.prepareAdsIfNeeded()
			}
		}
		pathMonitor.start(queue: DispatchQueue(label: "Wordly.AdManager.NetworkMonitor"))
	}
	
	func updateFirebaseAnalyticsConsent() {
		let purposeConsents = UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? ""
		let hasConsentForPurpose1 = purposeConsents.first == "1"
		let status = ConsentInformation.shared.consentStatus
		
		if status == .notRequired || hasConsentForPurpose1 {
			Analytics.setAnalyticsCollectionEnabled(true)
			print("Analytics enabled")
		} else {
			Analytics.setAnalyticsCollectionEnabled(false)
			print("Analytics disabled")
		}
	}
	
	func prepareAds() async {
		guard !isPreparingAds else { return }
		isPreparingAds = true
		isAdsReady = false
		defer {
			isPreparingAds = false
		}
		do {
			try await gatherConsent()
			
			updateFirebaseAnalyticsConsent()
			
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
	
	func prepareAdsIfNeeded() async {
		guard !isAdsReady else { return }
		await prepareAds()
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
				print("Done with consent")
			}
		}
		
		try await ConsentForm.loadAndPresentIfRequired(from: nil)
		print("Done with consent2")
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
		updateFirebaseAnalyticsConsent()
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
	
	deinit {
		pathMonitor.cancel()
	}
}

#Preview {
	TabsView()
}
