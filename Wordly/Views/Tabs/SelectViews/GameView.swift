//
//  GameView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 14/09/2025.
//

import SwiftUI

struct GameView: View {
	@EnvironmentObject var appManager: AppManager
    var body: some View {
		if #available(iOS 26.0, *) {
			GameView26()
				.environmentObject(appManager)
		} else {
			GameView18()
				.environmentObject(appManager)
		}
    }
}

#Preview {
    GameView()
		.environmentObject(AppManager())
}
