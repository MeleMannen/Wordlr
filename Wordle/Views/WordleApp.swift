//
//  WordleApp.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData
import CoreData

@main
struct WordleApp: App {
    @ObservedObject var appManager = AppManager()
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    
    @State var selection: TabSelection = .home
    
    
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
                        Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .environmentObject(appManager)
                
                HistoryView()
                    .tag(TabSelection.stats)
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
        .modelContainer(for: [StreakEntity.self, GameRecordEntity.self, GameRecord.self])
        
        
    }
}
