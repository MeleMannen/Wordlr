import SwiftUI

struct OnboardingView: View {
	@AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
	@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
	@Binding var isShowingOnboarding: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to play?")
                            .font(.largeTitle).bold()
                        Text("Guess the secret word in a limited number of tries. After each guess, the colors of the tiles will show how close you were.")
                            .font(.body)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Correct position")
                            .font(.title3).bold()
						HStack(spacing: 8) {
							GameTile(letter: "G", fill: .green, textColor: .white)
							GameTile(letter: "U", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "E", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "S", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "S", fill: Color(UIColor.lightGray), textColor: .black)
						}
                        Text("Green means the letter is in the word and in the correct spot.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Correct letter, wrong position")
                            .font(.title3).bold()
                        HStack(spacing: 8) {
                            GameTile(letter: "T", fill: Color(UIColor.lightGray), textColor: .black)
                            GameTile(letter: "H", fill: .orange, textColor: .white)
                            GameTile(letter: "E", fill: Color(UIColor.lightGray), textColor: .black)
                        }
                        Text("Orange means the letter is in the word, but in a different spot.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Not in the word")
                            .font(.title3).bold()
                        
						HStack(spacing: 8) {
							GameTile(letter: "W", fill: Color(uiColor: .darkGray), textColor: .white)
							GameTile(letter: "O", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "R", fill: Color(UIColor.lightGray), textColor: .black)
							GameTile(letter: "D", fill: Color(UIColor.lightGray), textColor: .black)
						}
                        Text("Dark gray means the letter is not in the word at all.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 16)
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    if #available(iOS 26.0, *) {
                        Button(action: {
							hasSeenOnboarding = true
							isShowingOnboarding = false
                        }, label: {
                            Text("Got it!")
                                .font(.title2).bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundStyle(.white)
                        })
                        .glassEffect(.regular.tint(.green).interactive(), in: .rect(cornerRadius: 15.0))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
                    } else {
                        Button(action: {
							hasSeenOnboarding = true
							isShowingOnboarding = false
                        }, label: {
                            Text("Got it!")
                                .font(.title2).bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundStyle(.white)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.green)
                                }
                        })
                        .buttonStyle(GrowingButton())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
                    }
                }
            }
			.navigationTitle("Welcome to \(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordlr")")
			.navigationBarTitleDisplayMode(.inline)
			.presentationDragIndicator(.hidden)
			.interactiveDismissDisabled(true)
			.onAppear {
				AnalyticsManager.shared.logScreenViewed(screenName: "OnboardingView")
			}
		}
	}
}
