//
//  WordleApp.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI

@main
struct WordleApp: App {
    @ObservedObject var appManager = AppManager()
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @State var selection: TabSelection = .home
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
    }
    
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection) {
                SelectView()
                    .tag(TabSelection.home)
                    .tabItem {
                        Label("The Phrase", systemImage: "character.square")
                    }
                    .preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
                    .environmentObject(appManager)
                
                SettingsView()
                    .tag(TabSelection.home)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
                    .environmentObject(appManager)
            }
            
            
            
        }
    }
}
