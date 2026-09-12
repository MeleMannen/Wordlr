//
//  TabsView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 28/09/2025.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import TipKit
import Network
import AppTrackingTransparency
import UserNotifications

struct TabsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.modelContext) var modelContext
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("proAdsEnabled") private var proAdsEnabled: Bool = false
    @AppStorage("usesTransparentLists") private var usesTransparentLists: Bool = true
    @State var selection: TabSelection = .home
    @State private var isResolvingStartupPrivacyFlow = false
	@ObservedObject private var appState = AppState.shared
	@State private var adManager: AdManager = AdManager()
	@State private var storeManager: StoreManager = StoreManager()

    private var tintColor: Color {
        if #available(iOS 26.0, *), usesTransparentLists && !reduceTransparency {
            return .green
        }
        return colorScheme == .dark ? .white : .black
    }

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selection) {
                NavigationStack {
                    SelectView(selection: self.$selection)

                }
				.accessibilityLabel(self.userWantsThePhraseNameBack ? "The Phrase tab" : "Wordlr tab")
				.accessibilityInputLabels([self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr", "Home", "Game"])
                .tag(TabSelection.home)
                .tabItem {
                    Label(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr", systemImage: self.userWantsThePhraseNameBack ? "p.square.fill" : "w.square.fill")
						.accessibilityLabel(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr")
						.accessibilityInputLabels([self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr", "Home", "Game"])
                }
                .task {
                    try? Tips.configure([.datastoreLocation(.applicationDefault)])
                }
                .tint(.primary)

                StatsView()
					.accessibilityLabel("Statistics tab")
					.accessibilityInputLabels(["Stats", "Statistics"])
                    .tag(TabSelection.stats)
                    .tabItem {
                        if #available(iOS 18.0, *) {
                            Label("Statistics", systemImage: "chart.bar.yaxis")
								.accessibilityInputLabels(["Stats", "Statistics"])
                        } else {
                            Label("Statistics", systemImage: "chart.bar.xaxis")
								.accessibilityInputLabels(["Stats", "Statistics"])
                        }
                    }
                    .tint(.primary)

                HistoryView()
					.accessibilityLabel("History tab")
					.accessibilityInputLabels(["History", "Historikk", "Previous games"])
                    .tag(TabSelection.history)
                    .tabItem {
                        if #available(iOS 18.0, *) {
                            Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
								.accessibilityInputLabels(["History", "Historikk", "Previous games"])
                        } else {
                            Label("History", systemImage: "clock")
								.accessibilityInputLabels(["History", "Historikk", "Previous games"])
                        }
                    }
                    .tint(.primary)

                SettingsView()
					.accessibilityLabel("Settings tab")
					.accessibilityInputLabels(["Settings", "Innstillinger"])
                    .tag(TabSelection.settings)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
							.accessibilityInputLabels(["Settings", "Innstillinger"])
                    }
                    .tint(.primary)

            }
            .environment(adManager)
            .environment(storeManager)
            .tint(self.tintColor)
            .onChange(of: self.scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        await resolveTrackingAndPrepareAdsIfNeeded()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) { bottomAd(for: geometry) }
            .preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
            .onChange(of: storeManager.isAdRemovalPurchased) { _, purchased in
                if purchased && !shouldDisplayAds {
                    withAnimation {
                        adManager.isBannerAdLoaded = false
                    }
                }
            }
            .onChange(of: proAdsEnabled) { _, _ in
                if shouldDisplayAds {
                    adManager.startMonitoringConnectivity()
                    Task {
                        await resolveTrackingAndPrepareAdsIfNeeded()
                    }
                } else {
                    withAnimation {
                        adManager.isBannerAdLoaded = false
                    }
                }
            }
            .onChange(of: appState.navigateToSettingsTrigger) { _, shouldNavigate in
                if shouldNavigate {
                    appState.navigateToSettingsTrigger = false
                    self.selection = .settings
                }
            }
            .task {
                if shouldDisplayAds {
                    adManager.startMonitoringConnectivity()
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await resolveTrackingAndPrepareAdsIfNeeded()
            }
            .onChange(of: hasSeenOnboarding) { _, newValue in
                if newValue {
                    Task {
                        try? await Task.sleep(nanoseconds: 600_000_000)
                        await resolveTrackingAndPrepareAdsIfNeeded()
                    }
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillShowNotification) {
                    adManager.isKeyboardVisible = true
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillHideNotification) {
                    adManager.isKeyboardVisible = false
                }
            }
        }
    }

    @ViewBuilder
    private func bottomAd(for geometry: GeometryProxy) -> some View {
        let canRequestAds = adManager.canRequestAds
        let isAdsReady = adManager.isAdsReady

        if canRequestAds && isAdsReady && shouldDisplayAds {
            if #available(iOS 26.0, *), UIDevice.current.userInterfaceIdiom == .phone {
                let adSize = inlineAdaptiveBanner(width: geometry.size.width - (geometry.size.width / 11), maxHeight: 50)
                BannerViewContainer(adSize, adManager: adManager)
                    .frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
                    .padding(.bottom, adManager.isKeyboardVisible ? 6 : 55)
                    .frame(height: adManager.isBannerAdLoaded ? nil : 0, alignment: .bottom)
                    .clipped()
                    .allowsHitTesting(adManager.isBannerAdLoaded)
            } else if #available(iOS 18.0, *),
                      UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
                let adSize = inlineAdaptiveBanner(width: geometry.size.width, maxHeight: 90)
                BannerViewContainer(adSize, adManager: adManager)
                    .frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
                    .frame(height: adManager.isBannerAdLoaded ? nil : 0, alignment: .bottom)
                    .clipped()
                    .allowsHitTesting(adManager.isBannerAdLoaded)
            } else {
                let adSize = inlineAdaptiveBanner(width: geometry.size.width, maxHeight: 50)
                BannerViewContainer(adSize, adManager: adManager)
                    .frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
                    .padding(.bottom, adManager.isKeyboardVisible ? 0 : 49)
                    .frame(height: adManager.isBannerAdLoaded ? nil : 0, alignment: .bottom)
                    .clipped()
                    .allowsHitTesting(adManager.isBannerAdLoaded)
            }
        }
    }

    private var shouldDisplayAds: Bool {
        !storeManager.isAdRemovalPurchased || proAdsEnabled
    }

	private func resolveTrackingAndPrepareAdsIfNeeded() async {
		guard scenePhase == .active, !isResolvingStartupPrivacyFlow, hasSeenOnboarding, shouldDisplayAds else { return }
		
		isResolvingStartupPrivacyFlow = true
		defer {
			isResolvingStartupPrivacyFlow = false
		}
		
		if !adManager.hasResolvedTrackingAuthorization {
			let authorizationStatus = await adManager.requestTrackingAuthorizationIfNeeded()
			print("ATT status: \(authorizationStatus.rawValue)")
			
			guard scenePhase == .active else { return }
		}
		
		await adManager.prepareAdsIfNeeded()

		if notificationsEnabled {
			NotificationManager.requestPermission() { result in
				switch result {
					case .success(let granted):
						if granted {
							print("Notification permission granted.")
							UNUserNotificationCenter.current().delegate = NotificationsDelegate.shared
							let reminders = NotificationManager.fetchReminders(context: modelContext)
							for reminder in reminders {
								NotificationManager.scheduleDailyWordReminder(reminder: reminder, context: modelContext)
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
}

#Preview {
    TabsView()
}
