//
//  GameView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 14/09/2025.
//

import SwiftUI

struct GameView: View {
	@EnvironmentObject var appManager: AppManager
	@Environment(AdManager.self) private var adManager: AdManager
    var body: some View {
		if #available(iOS 26.0, *) {
			GameView26()
				.environmentObject(appManager)
				.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 72) : 0)
		} else {
			GameView18()
				.environmentObject(appManager)
				.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 72) : 0)
		}
    }
}

#Preview {
    GameView()
		.environmentObject(AppManager())
		.environment(AdManager())
}
