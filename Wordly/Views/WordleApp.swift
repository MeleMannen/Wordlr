//
//  WordleApp.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics
import TelemetryDeck
import PostHog

@main
struct WordleApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showingOnboardingSheet: Bool = false

    init() {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(false)

		TelemetryDeck.initialize(config: .init(appID: "2CB2FADD-4FFE-4E4E-A41A-701488B32556"))
		
		let postHogConfig = PostHogConfig(projectToken: "phc_chCgS3rwJ0RaoaDMl61jK881N1oHxvRWpS6ok5aQJmX", host: "https://eu.i.posthog.com")
		postHogConfig.captureScreenViews = false
		postHogConfig.debug = true
		postHogConfig.reuseAnonymousId = true
		PostHogSDK.shared.setup(postHogConfig)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasSeenOnboarding {
                    OnboardingView(isPresented: $showingOnboardingSheet, hasSeenOnboarding: $hasSeenOnboarding)
                } else {
                    TabsView()
                }
            }
            .tint(.primary)
            .preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
        }
        .modelContainer(for: [GameRecordEntity.self, GameRecord.self, DailyWordReminder.self])
    }
}
