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
