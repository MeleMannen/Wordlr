//
//  Info.swift
//  Wordle
//
//  Created by Kristoffer Melen on 05/07/2025.
//

import SwiftUI

struct Info: View {
	@Environment(\.dismiss) var dismiss
	@Environment(AdManager.self) private var adManager: AdManager
	@EnvironmentObject var appState: AppState
	@AppStorage("userWantsAds") var userWantsAds: Bool = true
	
	
	private let tileSize: CGFloat = 48
	private let cornerRadius: CGFloat = 8
	
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Wordly")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 5)
                
                Text("Wordly is a word game where you guess a secret word by entering letters. The game provides feedback on your guesses, indicating correct letters and their positions.")
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
							GameTile(letter: "G", fill: .green, textColor: .white, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "U", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "E", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "S", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "S", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
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
							GameTile(letter: "T", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "H", fill: .orange, textColor: .white, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "E", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
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
							GameTile(letter: "W", fill: Color(uiColor: .darkGray), textColor: .white, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "O", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "R", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
							GameTile(letter: "D", fill: Color(UIColor.lightGray), textColor: .black, size: tileSize, cornerRadius: cornerRadius)
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
		.safeAreaPadding(.bottom, (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac) && self.userWantsAds ? 80 : (self.userWantsAds ? 54 : 0))
		.onChange(of: appState.navigateHomeTrigger) {
			print("SelectView detected navigateHomeTrigger change")
			dismiss()
		}
		.onAppear {
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
