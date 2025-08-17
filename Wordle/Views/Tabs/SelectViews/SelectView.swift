//
//  SelectView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI

struct SelectView: View {
    @Environment(\.modelContext) var modelContext
	@Environment(AdManager.self) private var adManager: AdManager
    @StateObject var appManager = AppManager()
    @AppStorage("hasAddedStreaks") private var hasAddedStreaks: Bool = false
    @AppStorage("hasAddedNormalStreaks") private var hasAddedNormalStreaks: Bool = false
    @AppStorage("hasFixedLanguage") private var hasFixedLanguage: Bool = false
	@AppStorage("userWantsAds") private var userWantsAds: Bool = false
    @State var hasFixedDefualtValues: Bool = false
    @State var hasFixedContextAndFetched: Bool = false
    @State var didTapPlayDailyWordButton: Bool = false
    @State var didTapFakePlayDailyWordButton: Bool = false
    @State var didTapPlayNormalButton: Bool = false
    @State var didTapInfoButton: Bool = false
    @State var isShowingAlreadyPlayedAlert: Bool = false
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            Text("The Phrase Length: ")
                                .font(.title2).bold()
                                .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                            
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            
                            Picker("", selection: $appManager.numberOfLetters) {
                                ForEach(1...8, id: \.self) { number in
									if number == 1 {
										Text("\(number) Letter")
									} else {
										Text("\(number) Letters")
									}
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundStyle(.primary)
                            .accentColor(.primary)
                            .font(.title).bold()
                            .background {
//                                if #unavailable(iOS 26.0, ) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
//                                }
                            }
                            .sensoryFeedback(.selection, trigger: appManager.numberOfLetters)
                            .modifier(ConditionalGlassEffect())
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text("Language:")
                                .font(.title2).bold()
                                .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
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
//                                if #unavailable(iOS 26.0, ) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
//                                }
                            }
                            .sensoryFeedback(.selection, trigger: appManager.selectedLanguage)
                            .modifier(ConditionalGlassEffect())
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                    Spacer()
                    
                    VStack {
                        NavigationLink(destination: GameView().environmentObject(appManager)) {
                            if let streakEntity = appManager.getNormalStreakEntity(), streakEntity.streak.currentStreak >= 3 {
                                Text("Play  -  \(streakEntity.streak.currentStreak)🔥")
                                    .contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
                                    .conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
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
                                Text("Play")
                                    .conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
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
                        })
                        .sensoryFeedback(.impact, trigger: self.didTapPlayNormalButton)
                        .buttonStyle(GrowingButton())
                        .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                    }
                    .padding(.bottom, 25)
                    
                    
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
                                            Alert(title: Text("You can't play this"), message: Text("You have already played this exact Phrase today. Try again tomorrow or play with a different Phrase length."), dismissButton: .cancel(Text("Got it!")))
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
                                            Alert(title: Text("You can't play this"), message: Text("You have already played this exact Phrase today. Try again tomorrow or play with a different Phrase length."), dismissButton: .cancel(Text("Got it!")))
                                        }
                                }
                            }
                            
                            
                        } else {
                            NavigationLink(destination: GameView().environmentObject(appManager)) {
                                if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
                                    Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
                                        .contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
                                        .multilineTextAlignment(.center)
                                        .conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
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
                                        .conditionalShadow(color: .black.opacity(0.05), radius: 1.5, x: 1, y: 1)
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
                                
                            })
                            .sensoryFeedback(.impact, trigger: self.didTapPlayDailyWordButton)
                            .buttonStyle(GrowingButton())
                            .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                }
                .padding(.horizontal)
            }
            
            .navigationTitle("The Phrase")
			.safeAreaPadding(.bottom, self.userWantsAds ? 54 : 0)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: Info().environmentObject(appManager)) {
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
                }
                
                if !self.hasAddedNormalStreaks {
                    appManager.addNormalStreaks()
                    self.hasAddedNormalStreaks = true
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
        }
//        .onDisappear {
//            self.selectViewIsActive = false
//        }
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


struct ConditionalGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
//                .glassEffect(.regular.interactive())
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
    SelectView()
}
