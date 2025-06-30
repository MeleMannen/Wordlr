//
//  SelectView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

struct SelectView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var appManager: AppManager
    @AppStorage("hasAddedStreaks") private var hasAddedStreaks: Bool = false
    @AppStorage("hasAddedNormalStreaks") private var hasAddedNormalStreaks: Bool = false
    @State var hasFixedDefualtValues: Bool = false
    @Query private var streaks: [StreakEntity] = []
    @Query private var normalStreaks: [NormalStreakEntity] = []
    @Query private var gameRecords: [GameRecordEntity] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            Text("The Phrase Length: ")
                                .font(.title2).bold()
                            
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            
                            Picker("", selection: $appManager.numberOfLetters) {
                                ForEach(1...8, id: \.self) { number in
                                    Text("\(number) letters")
//                                        .font(.title2).bold()
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundStyle(.primary)
                            .accentColor(.primary)
                            .font(.title).bold()
                            .background {
                                if #unavailable(iOS 26.0, ) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                }
                            }
                            .sensoryFeedback(.selection, trigger: appManager.numberOfLetters)
//                            .glassEffect()
                            .modifier(ConditionalGlassEffect())
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text("Language:")
                                .font(.title2).bold()
                            
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
                                if #unavailable(iOS 26.0, ) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                }
                            }
                            .sensoryFeedback(.selection, trigger: appManager.selectedLanguage)
//                            .glassEffect()
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
                            appManager.didTapPlayNormalButton.toggle()
                            appManager.selectedGameMode = .normal
                        })
                        .sensoryFeedback(.impact, trigger: appManager.didTapPlayNormalButton)
                        .buttonStyle(GrowingButton())
                        
//                        .buttonStyle(.glass)
                    }
                    .padding(.bottom, 25)
                    
                    VStack {
                        if appManager.checkIfDailyWordIsAlreadyPlayed() {
                            if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3 {
                                Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
                                    .contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(5)
                                    .font(.title2).bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.white)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(.green)
                                            .opacity(0.4)
                                    }
                                    .padding(.horizontal, 30)
                                    .onTapGesture {
                                        appManager.didTapFakePlayDailyWordButton.toggle()
                                        appManager.isShowingAlreadyPlayedAlert = true
                                        
                                    }
                                    .sensoryFeedback(.error, trigger: appManager.didTapFakePlayDailyWordButton)
                                    .alert(isPresented: $appManager.isShowingAlreadyPlayedAlert) {
                                        Alert(title: Text("You can't play this"), message: Text("You have already played this exact Phrase today. Try again tomorrow or play with a different Phrase length."), dismissButton: .cancel(Text("Got it!")))
                                    }
                                    .buttonStyle(GrowingButton())
                            } else {
                                Text("Play Daily Word")
                                    .multilineTextAlignment(.center)
                                    .font(.title2).bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.white)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(.green)
                                            .opacity(0.4)
                                    }
                                    .padding(.horizontal, 30)
                                    .onTapGesture {
                                        appManager.didTapFakePlayDailyWordButton.toggle()
                                        appManager.isShowingAlreadyPlayedAlert = true
                                        
                                    }
                                    .sensoryFeedback(.error, trigger: appManager.didTapFakePlayDailyWordButton)
                                    .alert(isPresented: $appManager.isShowingAlreadyPlayedAlert) {
                                        Alert(title: Text("You can't play this"), message: Text("You have already played this exact Phrase today. Try again tomorrow or play with a different Phrase length."), dismissButton: .cancel(Text("Got it!")))
                                    }
                                    .buttonStyle(GrowingButton())
                            }
                            
                            
                        } else {
                            NavigationLink(destination: GameView().environmentObject(appManager)) {
                                if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3 {
                                    Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
                                        .contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(5)
                                        .font(.title2).bold()
                                        .padding()
                                    
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.white)
                                        .background {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.green)
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
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.green)
                                        }
                                        .padding(.horizontal, 30)
                                }
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                appManager.didTapPlayDailyWordButton.toggle()
                                appManager.selectedGameMode = .dailyWord
                                if !appManager.word.isEmpty {
                                    appManager.getWords()
                                }
                            })
                            .sensoryFeedback(.impact, trigger: appManager.didTapPlayDailyWordButton)
                            .buttonStyle(GrowingButton())
//                            .buttonStyle(.glass)
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
//            .transition(.blurReplace)
//            .animation(appManager.shouldAnimateStreak ? .bouncy(duration: 0.2) : nil, value: appManager.getStreakEntity())
//            .onChange(of: appManager.selectedLanguage) { oldValue, newValue in
//                withAnimation {
//                    if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3 {
//                        appManager.shouldAnimateStreak = true
//                    } else {
//                        appManager.shouldAnimateStreak = false
//                    }
//                }
//            }
//            .onChange(of: appManager.numberOfLetters) { oldValue, newValue in
//                withAnimation {
//                    if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3 {
//                        appManager.shouldAnimateStreak = true
//                    } else {
//                        appManager.shouldAnimateStreak = false
//                    }
//                }
//            }
//            Spacer()
//            let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
//            BannerViewContainer(adSize)
//                .frame(width: adSize.size.width, height: adSize.size.height)
//                .padding(.bottom, 10)
            
        }
        .onAppear {
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
            appManager.updateStreak(appManager.getStreakEntity()!, with: .alive(startDate: Date(timeIntervalSince1970: TimeInterval(1748818196)), lastWonDate: Date()))
            
            if !self.hasFixedDefualtValues {
                appManager.setDefaultValues()
                self.hasFixedDefualtValues = true
            }
        }
    }
}

// Make an extention to add padding conditionally based on iOS version
struct ConditionalGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect()
        } else {
            content
        }
            
    }
}


#Preview {
    SelectView()
        .environmentObject(AppManager())
}
