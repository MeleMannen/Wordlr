//
//  Info.swift
//  Wordle
//
//  Created by Kristoffer Melen on 05/07/2025.
//

import SwiftUI

struct Info: View {
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("The Phrase")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 5)
                
                Text("The Phrase is a word game where you guess a secret phrase by entering letters. The game provides feedback on your guesses, indicating correct letters and their positions.")
                    .font(.body)
                    .padding(.bottom, 15)
                
                
                Text("How to Start a Game?")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("To start a game, select a language and the number of letters in the phrase that you are going to guess. After that, you choose the game mode, which can be either a Normal game or a Daily Word game.")
                    .font(.body)
                    .padding(.bottom, 8)
                
                Text("The Game Modes")
                    .font(.headline)
                    .padding(.bottom, 1)
                
                Text("The Normal mode allows you to play as many times as you want, while the Daily Word mode provides a unique phrase each day, that is the same for all players.")
                    .font(.body)
                    .padding(.bottom, 15)
                
                Text("How to Play?")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("To play the game, just enter a valid phrase and submit your guess. The game will highlight correct letters in green, correct letters in the wrong position in orange, and unused letters in gray.")
                    .font(.body)
                    .padding(.bottom, 15)
                
                Text("Hints")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("You can also use hints to help you guess the phrase. A hint will reveal a letter in the phrase, but not the postion of the letter. You can use a hint by tapping the hint button in the top right corner, which will make you watch an ad to get the hint.")
                    .font(.body)
                    .padding(.bottom, 15)
                
                Text("Sharing")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("You can share your Daily Word game results with your friends by tapping the copy button at the bottom of the screen after the game, or by going to the game history and copy it from there. This will generate a shareable text of your game results, which you can then share with your friends and family.")
                    .font(.body)
                    .padding(.bottom, 15)
                
                Text("Streaks🔥")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("You can keep track of your game streaks by looking next to the 🔥 emoji, next to the game mode on the The Phrase tab. This will either show you how many days or games in a row you have played and managed to guess The Phrase, depending on the game mode.")
                    .font(.body)
                    .padding(.bottom, 15)
                    
                Text("Stats")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("You can view your game stats by tapping the Stats tab. This will show you your game stats, including the number of games played, your win rate, and the amount of guesses you needed to guess the phrase. You can also filter your stats by language, game mode, and number of letters in the phrase.")
                    .font(.body)
                    .padding(.bottom, 15)
                
                Text("History")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("You can view your game history by tapping the History tab. This will show you your game history, including the phrases you have guessed, the number of guesses you needed to win the game, the number of hints used, and the date and time of the game. You can also filter your history by language, game mode, and number of letters in the phrase.")
                    .font(.body)
                    .padding(.bottom, 15)
                
                Text("Settings")
                    .font(.title3).bold()
                    .padding(.bottom, 2)
                
                Text("You can change the app settings by tapping the Settings tab. This will allow you to change the default language and the default number of letters in the phrase, and the defualt game mode. You can also change the app theme, which will change the app appearance to either light or dark mode.")
                    .font(.body)
                    .padding(.bottom, 5)
            }
        }
        .navigationTitle("Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    Info()
        .environmentObject(AppManager())
}
