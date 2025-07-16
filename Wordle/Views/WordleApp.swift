//
//  WordleApp.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct WordleApp: App {
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("userWantsAds") var userWantAds: Bool = false
    @State var selection: TabSelection = .home
    
    init() {
        if userWantAds {
            MobileAds.shared.start()
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection) {
                SelectView()
                    .tag(TabSelection.home)
                    .tabItem {
                        Label("The Phrase", systemImage: "p.square.fill")
                    }
                    .environmentObject(AppManager())
                
                StatsView(tabSelection: $selection)
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
                
            }
            .tint(.primary)
            .preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
            
        }
        .modelContainer(for: [StreakEntity.self, NormalStreakEntity.self, GameRecordEntity.self, GameRecord.self])
    }
}
