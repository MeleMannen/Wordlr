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

@main
struct WordleApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
	@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
	@State private var showingOnboardingSheet: Bool = false
	
	init() {
		FirebaseApp.configure()
		Analytics.setAnalyticsCollectionEnabled(false)
	}
	
	
	var body: some Scene {
		WindowGroup {
			ZStack {
				if !self.hasSeenOnboarding {
					OnboardingView(isPresented: self.$showingOnboardingSheet, hasSeenOnboarding: self.$hasSeenOnboarding)
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


