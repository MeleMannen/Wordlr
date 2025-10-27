//
//  SelectView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI

struct SelectView: View {
    @Environment(\.modelContext) var modelContext
	@Environment(\.colorScheme) private var colorScheme
	@Environment(AdManager.self) private var adManager: AdManager
    @StateObject var appManager = AppManager()
	@StateObject var reviewManager = ReviewManager()
	@StateObject var appState = AppState.shared
    @AppStorage("hasAddedStreaks") private var hasAddedStreaks: Bool = false
	@AppStorage("hasAddedSpanishStreaks") private var hasAddedSpanishStreaks: Bool = false
    @AppStorage("hasAddedNormalStreaks") private var hasAddedNormalStreaks: Bool = false
	@AppStorage("hasAddedSpanishNormalStreaks") private var hasAddedSpanishNormalStreaks: Bool = false
    @AppStorage("hasFixedLanguage") private var hasFixedLanguage: Bool = false
	@AppStorage("userWantsAds") private var userWantsAds: Bool = false
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	@AppStorage("userWantsThePhraseNameBack") private var userWantsThePhraseNameBack = false
    @State var hasFixedDefualtValues: Bool = false
    @State var hasFixedContextAndFetched: Bool = false
    @State var didTapPlayDailyWordButton: Bool = false
    @State var didTapFakePlayDailyWordButton: Bool = false
    @State var didTapPlayNormalButton: Bool = false
    @State var didTapInfoButton: Bool = false
    @State var isShowingAlreadyPlayedAlert: Bool = false
	@Binding var selection: TabSelection
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer()
                    VStack {
						Text("Number of Letters")
							.font(.title2).bold()
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						if #available(iOS 26.0, *) {
							Picker(selection: $appManager.numberOfLetters) {
								ForEach(1...8, id: \.self) { number in
									if number == 1 {
										Text("\(number) Letter")
											.tag(number)
									} else {
										Text("\(number) Letters")
											.tag(number)
									}
								}
							} label: {
								
							}
							.pickerStyle(.menu)
							.modifier(ConditionalGlassEffect())
							.sensoryFeedback(.selection, trigger: appManager.numberOfLetters)
							.frame(maxWidth: .infinity, alignment: .trailing)
						} else {
							Picker(selection: $appManager.numberOfLetters) {
								ForEach(1...8, id: \.self) { number in
									if number == 1 {
										Text("\(number) Letter")
									} else {
										Text("\(number) Letters")
									}
								}
							} label: {
								
							}
							.pickerStyle(.menu)
							.foregroundStyle(.primary)
							.accentColor(.primary)
							.background {
								RoundedRectangle(cornerRadius: 10)
									.foregroundStyle(Color(uiColor: .tertiarySystemBackground))
									.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							}
							.sensoryFeedback(.selection, trigger: appManager.numberOfLetters)
							.frame(maxWidth: .infinity, alignment: .trailing)
						}
					}
					.padding(.bottom, 30)
					
					Spacer()
					
					VStack {
						Text("Language")
							.font(.title2).bold()
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							.frame(maxWidth: .infinity, alignment: .leading)
						
						if #available(iOS 26.0, *) {
							Picker(selection: $appManager.selectedLanguage) {
								ForEach(LanguageSelection.languages) { language in
									Text(language.localizedName.capitalized)
								}
							} label: {
								
							}
							.pickerStyle(.menu)
							.modifier(ConditionalGlassEffect())
							.sensoryFeedback(.selection, trigger: appManager.selectedLanguage)
							.frame(maxWidth: .infinity, alignment: .trailing)
						} else {
							Picker(selection: $appManager.selectedLanguage) {
								ForEach(LanguageSelection.languages) { language in
									Text(language.localizedName.capitalized)
								}
							} label: {
								
							}
							.pickerStyle(.menu)
							.foregroundStyle(.primary)
							.accentColor(.primary)
							.background {
								RoundedRectangle(cornerRadius: 10)
									.foregroundStyle(Color(uiColor: .tertiarySystemBackground))
									.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							}
							.sensoryFeedback(.selection, trigger: appManager.selectedLanguage)
							.frame(maxWidth: .infinity, alignment: .trailing)
						}
					}
					.padding(.bottom, 30)
					
					Spacer()
					Spacer()
					if #available(iOS 26.0, *) {
						VStack {
							NavigationLink(destination: GameView().environmentObject(appManager)) {
								if let streakEntity = appManager.getNormalStreakEntity(), streakEntity.streak.currentStreak >= 3 {
									Text("Play Unlimited\n\(streakEntity.streak.currentStreak)🔥")
										.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
										.multilineTextAlignment(.center)
										.lineSpacing(5)
										.font(.title2).bold()
										.padding()
										.foregroundStyle(.white)
										.frame(maxWidth: .infinity)
								} else {
									Text("Play Unlimited")
										.font(.title2).bold()
										.padding()
										.foregroundStyle(.white)
										.frame(maxWidth: .infinity)
								}
							}
							.simultaneousGesture(TapGesture().onEnded {
								self.didTapPlayNormalButton.toggle()
								appManager.selectedGameMode = .normal
								Task {
									await HintTip.gamesPlayedEvent.donate()
								}
							})
							.sensoryFeedback(.impact, trigger: self.didTapPlayNormalButton)
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
						}
						
						.glassEffect(.regular.tint(.green).interactive(), in: .rect(cornerRadius: 15.0))
						.padding(.horizontal, 30)
						.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
						.padding(.bottom, 25)
					} else {
						VStack {
							NavigationLink(destination: GameView().environmentObject(appManager)) {
								if let streakEntity = appManager.getNormalStreakEntity(), streakEntity.streak.currentStreak >= 3 {
									Text("Play Unlimited\n\(streakEntity.streak.currentStreak)🔥")
										.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
										.multilineTextAlignment(.center)
										.lineSpacing(5)
//										.conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
										.font(.title2).bold()
										.padding()
										.foregroundStyle(.white)
										.frame(maxWidth: .infinity)
										.background {
											RoundedRectangle(cornerRadius: 15)
												.foregroundStyle(.green)
											
										}
										.padding(.horizontal, 30)
								} else {
									Text("Play Unlimited")
//										.conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
									
										.font(.title2).bold()
										.padding()
										.foregroundStyle(.white)
										.frame(maxWidth: .infinity)
										.background {
											RoundedRectangle(cornerRadius: 15)
												.foregroundStyle(.green)
											
										}
										.padding(.horizontal, 30)
									
									
								}
							}
							.simultaneousGesture(TapGesture().onEnded {
								self.didTapPlayNormalButton.toggle()
								appManager.selectedGameMode = .normal
								Task {
									await HintTip.gamesPlayedEvent.donate()
								}
							})
							.sensoryFeedback(.impact, trigger: self.didTapPlayNormalButton)
							.buttonStyle(GrowingButton())
							
							.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
						}
						.padding(.bottom, 25)
					}
                    
					if #available(iOS 26.0, *) {
						VStack {
							if appManager.checkIfDailyWordIsAlreadyPlayed() {
								if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
									VStack {
										Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
											.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
											.multilineTextAlignment(.center)
											.lineSpacing(5)
										
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
													.opacity(0.3)
											}
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												self.isShowingAlreadyPlayedAlert = true
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
											.alert(isPresented: self.$isShowingAlreadyPlayedAlert) {
												Alert(title: Text("You can't play this"), message: Text("You have already played this exact Word today. Try again tomorrow or play with a different Number of Letters."), dismissButton: .cancel(Text("Got it!")))
											}
										
									}
									.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
								} else {
									VStack {
										Text("Play Daily Word")
											.multilineTextAlignment(.center)
										
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
													.opacity(0.3)
											}
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												self.isShowingAlreadyPlayedAlert = true
												
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
											.alert(isPresented: self.$isShowingAlreadyPlayedAlert) {
												Alert(title: Text("You can't play this"), message: Text("You have already played this exact Word today. Try again tomorrow or play with a different Number of Letters."), dismissButton: .cancel(Text("Got it!")))
											}
									}
									.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15.0))
								}
								
								
							} else {
								NavigationLink(destination: GameView().environmentObject(appManager)) {
									if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
										Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
											.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
											.multilineTextAlignment(.center)
											.lineSpacing(5)
											.font(.title2).bold()
											.padding()
										
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground2()
													.environmentObject(appManager)
											}
									} else {
										Text("Play Daily Word")
											.multilineTextAlignment(.center)
											.font(.title2).bold()
											.padding()
										
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground2()
													.environmentObject(appManager)
											}
									}
								}
								.simultaneousGesture(TapGesture().onEnded {
									self.didTapPlayDailyWordButton.toggle()
									appManager.selectedGameMode = .dailyWord
									Task {
										await HintTip.gamesPlayedEvent.donate()
									}
									
								})
								.sensoryFeedback(.impact, trigger: self.didTapPlayDailyWordButton)
								.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
								.glassEffect((self.userWantsNormalTheme || self.colorScheme == .light) ? .regular.tint(.green).interactive() : .regular.interactive(), in: .rect(cornerRadius: 15.0))
								
							}
						}
						.padding(.horizontal, 30)
						.padding(.bottom, 10)
					} else {
						VStack {
							if appManager.checkIfDailyWordIsAlreadyPlayed() {
								if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
									VStack {
										Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
											.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
											.multilineTextAlignment(.center)
											.lineSpacing(5)
										
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
													.opacity(0.3)
											}
											.padding(.horizontal, 30)
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												self.isShowingAlreadyPlayedAlert = true
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
											.alert(isPresented: self.$isShowingAlreadyPlayedAlert) {
												Alert(title: Text("You can't play this"), message: Text("You have already played this exact Word today. Try again tomorrow or play with a different Number of Letters."), dismissButton: .cancel(Text("Got it!")))
											}
										
									}
								} else {
									VStack {
										Text("Play Daily Word")
											.multilineTextAlignment(.center)
										
											.font(.title2).bold()
											.padding()
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
													.opacity(0.3)
											}
											.padding(.horizontal, 30)
											.onTapGesture {
												self.didTapFakePlayDailyWordButton.toggle()
												self.isShowingAlreadyPlayedAlert = true
												
											}
											.sensoryFeedback(.error, trigger: self.didTapFakePlayDailyWordButton)
											.alert(isPresented: self.$isShowingAlreadyPlayedAlert) {
												Alert(title: Text("You can't play this"), message: Text("You have already played this exact Word today. Try again tomorrow or play with a different Number of Letters."), dismissButton: .cancel(Text("Got it!")))
											}
									}
								}
								
								
							} else {
								NavigationLink(destination: GameView().environmentObject(appManager)) {
									if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
										Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
											.contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
											.multilineTextAlignment(.center)
											.lineSpacing(5)
											.font(.title2).bold()
											.padding()
										
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
											}
											.padding(.horizontal, 30)
									} else {
										Text("Play Daily Word")
											.multilineTextAlignment(.center)
											.font(.title2).bold()
											.padding()
										
											.frame(maxWidth: .infinity)
											.foregroundStyle(.white)
											.background {
												ConditionalButtonBackground()
													.environmentObject(appManager)
											}
											.padding(.horizontal, 30)
									}
								}
								.simultaneousGesture(TapGesture().onEnded {
									self.didTapPlayDailyWordButton.toggle()
									appManager.selectedGameMode = .dailyWord
									Task {
										await HintTip.gamesPlayedEvent.donate()
									}
									
								})
								.sensoryFeedback(.impact, trigger: self.didTapPlayDailyWordButton)
								.buttonStyle(GrowingButton())
								.conditionalShadow(color: .black.opacity(0.4), radius: 4, x: 4, y: 4)
							}
						}
						.padding(.bottom, 10)
					}
                }
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                }
                .padding(.horizontal)
            }
			.safeAreaPadding(.bottom, (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac) && self.userWantsAds ? 80 : (self.userWantsAds ? 54 : 0))
            .toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					NavigationLink(destination: Info().environmentObject(appManager).environmentObject(appState)) {
						Image(systemName: "info")
							.font(.title2)
							.foregroundStyle(.primary)
					}
					.simultaneousGesture(TapGesture().onEnded {
						self.didTapInfoButton.toggle()
					})
					.sensoryFeedback(.selection, trigger: self.didTapInfoButton)
				}
            }
        }
		.navigationTitle(self.userWantsThePhraseNameBack ? "The Phrase" : "Wordly")
		.onChange(of: appState.navigateHomeTrigger) {
			if appState.selectedLanguageName != nil {
				if appState.selectedLanguageName == LanguageSelection.english.rawValue {
					appManager.selectedLanguage = .english
				} else if appState.selectedLanguageName == LanguageSelection.norwegian.rawValue {
					appManager.selectedLanguage = .norwegian
				} else if appState.selectedLanguageName == LanguageSelection.spanish.rawValue {
					appManager.selectedLanguage = .spanish
				}
			}
			appManager.numberOfLetters = appState.numberOfLetters ?? 5
			self.selection = .home
		}
		.onChange(of: self.didTapPlayDailyWordButton) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = false
			}
		}
		.onChange(of: self.didTapPlayNormalButton) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = false
			}
		}
		.onChange(of: self.didTapInfoButton) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = true
			}
		}
        .onAppear {
			appManager.message = ""
			
            if !self.hasFixedContextAndFetched {
                appManager.modelContext = modelContext
                appManager.streakManager = StreakManager(context: modelContext)
                appManager.normalStreakManager = NormalStreakManager(context: modelContext)
                appManager.gameRecordManager = GameRecordManager(context: modelContext)
				
                if !self.hasAddedStreaks {
                    appManager.addStreaks()
                    self.hasAddedStreaks = true
					self.hasAddedSpanishStreaks = true
				} else if !self.hasAddedSpanishStreaks {
					appManager.addSpanishStreaks()
					self.hasAddedSpanishStreaks = true
				}
                
                if !self.hasAddedNormalStreaks {
                    appManager.addNormalStreaks()
                    self.hasAddedNormalStreaks = true
				} else if !self.hasAddedSpanishNormalStreaks {
					appManager.addSpanishNormalStreaks()
					self.hasAddedSpanishNormalStreaks = true
				}
                
                appManager.fetchStreaks()
                appManager.fetchNormalStreaks()
                appManager.fetchGameRecords()
                self.hasFixedContextAndFetched = true
            }
            
            if !self.hasFixedDefualtValues {
                appManager.setDefaultValues()
                self.hasFixedDefualtValues = true
            }
            
            if !self.hasFixedLanguage {
                appManager.fixLanguageBasedOnLocale()
                self.hasFixedLanguage = true
            }
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				adManager.shouldShowAds = true
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				reviewManager.checkForReviewPrompt()
			}
        }
    }
}

final class AppState: ObservableObject {
	static let shared = AppState()
	
	@Published var navigateHomeTrigger = UUID()
	@Published var selectedLanguageName: String?
	@Published var numberOfLetters: Int?
	
	func applyReminder(languageName: String?, numberOfLetters: Int?) {
		self.selectedLanguageName = languageName
		self.numberOfLetters = numberOfLetters
		self.navigateHomeTrigger = UUID()
	}
}


struct ConditionalButtonBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var appManager: AppManager
    @AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
    
    var body: some View {
        if !self.userWantsNormalTheme && self.colorScheme == .dark {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(appManager.gradient)
                .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
            
        } else {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(Color.green)
        }
    }
}

struct ConditionalButtonBackground2: View {
	@Environment(\.colorScheme) private var colorScheme
	@EnvironmentObject var appManager: AppManager
	@AppStorage("userWantsNormalTheme") private var userWantsNormalTheme: Bool = true
	
	var body: some View {
		if !self.userWantsNormalTheme && self.colorScheme == .dark {
			RoundedRectangle(cornerRadius: 15)
				.foregroundStyle(appManager.gradient)
				.gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
			
		} else {
//			RoundedRectangle(cornerRadius: 15)
			
		}
	}
}


struct ConditionalGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive())
				.tint(.primary)
        } else {
            content
				.tint(.primary)
        }
    }
}

struct ConditionalPadding: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			content
				.padding(.vertical, 4)
		} else {
			content
		}
	}
}

struct ConditionalShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        Group {
            if appTheme == .dark || colorScheme == .dark {
                content
                    .shadow(color: color, radius: radius, x: x, y: y)
            } else {
                content
            }
        }
    }
}

extension View {
    func conditionalShadow(
        color: Color = .black.opacity(0.33),
        radius: CGFloat = 4,
        x: CGFloat = 4,
        y: CGFloat = 4
    ) -> some View {
        modifier(
            ConditionalShadow(
                color: color,
                radius: radius,
                x: x,
                y: y
            )
        )
    }
}


#Preview {
	SelectView(selection: .constant(.home))
}
