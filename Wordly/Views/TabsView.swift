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
    @Environment(\.modelContext) var modelContext
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State var selection: TabSelection = .home
    @State var tintColor: Color = .green
    @State private var isResolvingStartupPrivacyFlow = false
	@State private var adManager: AdManager = AdManager()

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selection) {
                NavigationStack {
                    SelectView(selection: self.$selection)

                }
                .tag(TabSelection.home)
                .tabItem {
                    Label(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr", systemImage: self.userWantsThePhraseNameBack ? "p.square.fill" : "w.square.fill")
                }
                .environment(adManager)
                .task {
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
                    Task {
                        await resolveTrackingAndPrepareAdsIfNeeded()
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
            .task {
                adManager.startMonitoringConnectivity()
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
        
        if canRequestAds && isAdsReady {
            if #available(iOS 26.0, *), UIDevice.current.userInterfaceIdiom == .phone {
                let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width - (geometry.size.width / 11))
                BannerViewContainer(adSize, adManager: adManager)
                    .frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
                    .frame(height: adManager.isBannerAdLoaded ? nil : 0)
                    .clipped()
                    .padding(.bottom, adManager.isBannerAdLoaded ? (adManager.isKeyboardVisible ? 6 : 55) : 0)
            } else if #available(iOS 18.0, *),
                      UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
                let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
                BannerViewContainer(adSize, adManager: adManager)
                    .frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
                    .frame(height: adManager.isBannerAdLoaded ? nil : 0)
                    .clipped()
            } else {
                let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
                BannerViewContainer(adSize, adManager: adManager)
                    .frame(width: max(0, adSize.size.width), height: max(0, adSize.size.height))
                    .frame(height: adManager.isBannerAdLoaded ? nil : 0)
                    .clipped()
                    .padding(.bottom, adManager.isBannerAdLoaded ? (adManager.isKeyboardVisible ? 0 : 49) : 0)
            }
        }
    }

	private func resolveTrackingAndPrepareAdsIfNeeded() async {
		guard scenePhase == .active, !isResolvingStartupPrivacyFlow, hasSeenOnboarding else { return }
		
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
