//
//  AdManager.swift
//  Wordlr
//
//  Created by Kristoffer Melen on 29/03/2026.
//

import Foundation
import GoogleMobileAds
import UserMessagingPlatform
import AppTrackingTransparency
import FirebaseAnalytics

@MainActor
@Observable
final class AdManager {
	var currentSelectView: CurrentSelectView = .selectView
	var shouldShowAds: Bool = true
	var isMobileAdsStartCalled = false
	var isAdsReady = false
	var hasResolvedTrackingAuthorization = false
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
		pathMonitor.start(queue: DispatchQueue(label: "Wordlr.AdManager.NetworkMonitor"))
	}
	
	func updateFirebaseAnalyticsConsent() {
		let purposeConsents = UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? ""
		let hasConsentForPurpose1 = purposeConsents.first == "1"
		let status = ConsentInformation.shared.consentStatus
		
		if status == .notRequired {
			Analytics.setConsent([
				.analyticsStorage: .granted
			])
			Analytics.setAnalyticsCollectionEnabled(true)
			print("Analytics enabled with explicit non-EU consent defaults")
		} else if hasConsentForPurpose1 {
			Analytics.setAnalyticsCollectionEnabled(true)
			print("Analytics enabled using UMP-managed consent state")
		} else {
			Analytics.setConsent([
				.analyticsStorage: .denied,
				.adStorage: .denied,
				.adUserData: .denied,
				.adPersonalization: .denied
			])
			Analytics.setAnalyticsCollectionEnabled(false)
			print("Analytics disabled")
		}
	}
	
	func prepareAds() async {
		guard !isPreparingAds else { return }
		guard hasResolvedTrackingAuthorization else {
			print("Waiting for ATT before starting UMP flow.")
			return
		}
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
//		debugSettings.geography = .other
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
			hasResolvedTrackingAuthorization = true
			return .authorized
		}
		
		let currentStatus = ATTrackingManager.trackingAuthorizationStatus
		guard currentStatus == .notDetermined else {
			hasResolvedTrackingAuthorization = true
			return currentStatus
		}
		return await withCheckedContinuation { continuation in
			ATTrackingManager.requestTrackingAuthorization { status in
				Task { @MainActor in
					self.hasResolvedTrackingAuthorization = true
					continuation.resume(returning: status)
				}
			}
		}
	}
	
	func startGoogleMobileAdsSDK() {
		guard canRequestAds, !isMobileAdsStartCalled else {
			return
		}
		
//#if targetEnvironment(simulator)
		let testDeviceIdentifiers = ["AC276EF4-3093-42DF-8DE1-84C495BF8585"]
		MobileAds.shared.requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers
//#endif
		
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
