//
//  GameView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 14/09/2025.
//

import SwiftUI

struct GameView: View {
	@Environment(AppManager.self) private var appManager
	@Environment(AdManager.self) private var adManager

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                GameView26()
                    .environment(appManager)
                    .safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 98 : 72) : 0)
            } else {
                GameView18()
                    .environment(appManager)
                    .safeAreaPadding(.bottom, adManager.isBannerAdLoaded ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 98 : 72) : 0)
            }
        }
		.task {
			appManager.repairGameIfNeeded()
		}
    }
}

#Preview {
    GameView()
		.environment(AppManager())
		.environment(AdManager())
}
