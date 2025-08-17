//
//  WordleApp.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency

@main
struct WordleApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    @AppStorage("userWantsAds") var userWantsAds: Bool = true
    @State var selection: TabSelection = .home
    @State private var bannerReloadID = UUID()
//    @State var selectViewIsActive: Bool = true
	@State var adManager: AdManager = AdManager()
    
    init() {
        if userWantsAds {
            MobileAds.shared.start()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                TabView(selection: $selection) {
                    NavigationStack {
                        SelectView()
                    }
                    .tag(TabSelection.home)
                    .tabItem {
                        Label("The Phrase", systemImage: "p.square.fill")
                    }
					.environment(adManager)
                    
                    StatsView()
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
                .onChange(of: self.scenePhase) { _, newPhase in
                    if newPhase == .active, self.userWantsAds {
                        print("App became active, reloading banner ad")
                        self.bannerReloadID = UUID()
                    }
                }
                .safeAreaInset(edge: .bottom) {
					if self.userWantsAds && (self.selection != .home || (self.selection == .home && adManager.shouldShowAds)) {
                        if #available(iOS 26.0, *), UIDevice.current.userInterfaceIdiom == .phone {
                            let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width - (geometry.size.width / 11))
                            BannerViewContainer(adSize)
                                .frame(width: adSize.size.width < 0 ? 0 : adSize.size.width, height: adSize.size.height < 0 ? 0 : adSize.size.height)
                                .padding(.bottom, 54)
                                .id(bannerReloadID)
                        } else if UIDevice.current.userInterfaceIdiom == .pad {
                            let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
                            BannerViewContainer(adSize)
                                .frame(width: adSize.size.width < 0 ? 0 : adSize.size.width, height: adSize.size.height < 0 ? 0 : adSize.size.height)
                                .id(bannerReloadID)
                        } else {
                            let adSize = currentOrientationAnchoredAdaptiveBanner(width: geometry.size.width)
                            BannerViewContainer(adSize)
                                .frame(width: adSize.size.width < 0 ? 0 : adSize.size.width, height: adSize.size.height < 0 ? 0 : adSize.size.height)
                                .padding(.bottom, 49)
                                .id(bannerReloadID)
                        }
                    }
                }
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
					ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
				}
                .tint(.primary)
                .preferredColorScheme(appTheme == .system ? nil : (appTheme == .light ? .light : .dark))
            }
        }
        .modelContainer(for: [StreakEntity.self, NormalStreakEntity.self, GameRecordEntity.self, GameRecord.self])
    }
}

@Observable
final class AdManager {
	var shouldShowAds: Bool = true
}




