//
//  Info.swift
//  Wordle
//
//  Created by Kristoffer Melen on 05/07/2025.
//

import SwiftUI

struct Info: View {
	@Environment(\.dismiss) var dismiss
	@Environment(AdManager.self) private var adManager
	@EnvironmentObject var appState: AppState
	@AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
	
	
	var body: some View {
		List {
			VStack(alignment: .leading) {
				Text(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr")
					.font(.largeTitle).bold()
					.padding(.bottom, 5)
				
				Text("\(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr") is a word game where you guess a secret word. The game provides feedback on your guesses, indicating correct letters and their positions.")
					.font(.body)
					.padding(.bottom, 15)
				
				Text("How to Play?")
					.font(.title3).bold()
					.padding(.bottom, 2)
				
				Text("To play the game, just enter a valid word and submit your guess. After each guess, the colors of the tiles will show how close you were.")
					.font(.body)
					.padding(.bottom, 15)
				
				VStack(alignment: .leading, spacing: 30) {
					VStack(alignment: .leading, spacing: 10) {
						Text("Correct position")
							.font(.headline)
						HStack(spacing: 8) {
							GameTile(letter: "G", fill: .green, textColor: .white)
							GameTile(letter: "U", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "E", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "S", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "S", fill: Color(UIColor.lightGray), textColor: .black)
						}
						Text("Green means the letter is in the word and in the correct spot.")
							.font(.callout)
							.multilineTextAlignment(.leading)
							.fixedSize(horizontal: false, vertical: true)
							.foregroundStyle(.secondary)
					}
					
					VStack(alignment: .leading, spacing: 10) {
						Text("Correct letter, wrong position")
							.font(.headline)
						HStack(spacing: 8) {
							GameTile(letter: "T", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "H", fill: .orange, textColor: .white)
							GameTile(letter: "E", fill: Color(UIColor.lightGray), textColor: .black)
						}
						Text("Orange means the letter is in the word, but in a different spot.")
							.font(.callout)
							.multilineTextAlignment(.leading)
							.fixedSize(horizontal: false, vertical: true)
							.foregroundStyle(.secondary)
					}
					
					VStack(alignment: .leading, spacing: 10) {
						Text("Not in the word")
							.font(.headline)
						
						HStack(spacing: 8) {
							GameTile(letter: "W", fill: Color(uiColor: .darkGray), textColor: .white)
							GameTile(letter: "O", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "R", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "D", fill: Color(UIColor.lightGray), textColor: .black)
						}
						Text("Dark gray means the letter is not in the word at all.")
							.font(.callout)
							.multilineTextAlignment(.leading)
							.fixedSize(horizontal: false, vertical: true)
							.foregroundStyle(.secondary)
					}
				}
			}
		}
		.navigationTitle("Info")
		.navigationBarTitleDisplayMode(.inline)
		.safeAreaPadding(.bottom, adManager.isAdsReady ? (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? 80 : 54) : 0)
		.onChange(of: appState.navigateHomeTrigger) {
			print("SelectView detected navigateHomeTrigger change")
			dismiss()
		}
		.onAppear {
			AnalyticsManager.shared.logScreenViewed(screenName: "Info")
			adManager.currentSelectView = .infoView
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = true
			}
		}
		.onDisappear {
			adManager.currentSelectView = .selectView
		}
	}
}

#Preview {
	Info()
}
