//
//  WordleApp.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData
//import CoreData
import GoogleMobileAds

@main
struct WordleApp: App {
    @ObservedObject var appManager = AppManager()
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    
    @State var selection: TabSelection = .home
    
    init() {
        MobileAds.shared.start()
    }
    
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection) {
                SelectView()
                    .tag(TabSelection.home)
                    .tabItem {
                        Label("The Phrase", systemImage: "character.square")
                    }
                    .environmentObject(appManager)                    
                
                StatsView()
                    .tag(TabSelection.stats)
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.yaxis")
                    }
                    .environmentObject(appManager)
                
                HistoryView()
                    .tag(TabSelection.history)
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    }
                    .environmentObject(appManager)
                
                SettingsView()
                    .tag(TabSelection.settings)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .environmentObject(appManager)
                
            }
            .tint(.primary)
            
            .preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
            
            
            
        }
        .modelContainer(for: [StreakEntity.self, NormalStreakEntity.self, GameRecordEntity.self, GameRecord.self])
        
        
    }
}
