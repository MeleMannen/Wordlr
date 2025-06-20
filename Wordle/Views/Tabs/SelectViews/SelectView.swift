//
//  SelectView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData

struct SelectView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var appManager: AppManager
    @AppStorage("hasAddedStreaks") private var hasAddedStreaks: Bool = false
    @State var hasFixedDefualtValues: Bool = false
    @Query private var streaks: [StreakEntity] = []
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
                            Text("Play")
                                .font(.title2).bold()
                                .padding()
                                
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.green)
                                    
                                }
                            
//                                .glassEffect(.regular.tint(.green).interactive(), in: .capsule)
                                .padding(.horizontal, 30)
                                
                                
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            appManager.didTapPlayNormalButton.toggle()
                            appManager.gameMode = .normal
                        })
                        .sensoryFeedback(.impact, trigger: appManager.didTapPlayNormalButton)
                        .buttonStyle(GrowingButton())
                        
//                        .buttonStyle(.glass)
                    }
                    .padding(.bottom)
                    
                    VStack {
                        if appManager.checkIfDailyWordIsAlreadyPlayed() {
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
//                                .glassEffect(.regular.tint(.green.opacity(0.4)).interactive(), in: .capsule)
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
//                                .buttonStyle(.glass)
                            
                            
                        } else {
                            NavigationLink(destination: GameView().environmentObject(appManager)) {
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
//                                    .glassEffect(.regular.tint(.green).interactive(), in: .capsule)
                                    .padding(.horizontal, 30)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                appManager.didTapPlayDailyWordButton.toggle()
                                appManager.gameMode = .dailyWord
                                if !appManager.word.isEmpty {
                                    appManager.getWords()
                                }
                            })
                            .sensoryFeedback(.impact, trigger: appManager.didTapPlayDailyWordButton)
                            .buttonStyle(GrowingButton())
//                            .buttonStyle(.glass)
                        }
                    }
                    .padding(.bottom)
                    
                    if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, appManager.shouldAnimateStreak {
                        VStack {
                            Text("\(streakEntity.streak.currentStreak)🔥")
                                .font(.title).bold()
                            
                            
                        }
                        .padding(.top)
                        
                    }
                }
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                }
                
                .onChange(of: appManager.selectedLanguage) { oldValue, newValue in
                    withAnimation {
                        if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3 {
                            appManager.shouldAnimateStreak = true
                        } else {
                            appManager.shouldAnimateStreak = false
                        }
                    }
                }
                .onChange(of: appManager.numberOfLetters) { oldValue, newValue in
                    withAnimation {
                        if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3 {
                            appManager.shouldAnimateStreak = true
                        } else {
                            appManager.shouldAnimateStreak = false
                        }
                    }
                }
                .padding(.horizontal, 22)
            }
            
            .navigationTitle("The Phrase")
            .animation(appManager.shouldAnimateStreak ? .bouncy(duration: 0.2) : nil, value: appManager.getStreakEntity())
            
        }
        .onAppear {
            appManager.modelContext = modelContext
            appManager.streakManager = StreakManager(context: modelContext)
            appManager.gameRecordManager = GameRecordManager(context: modelContext)
            if !self.hasAddedStreaks {
                appManager.addStreaks()
                self.hasAddedStreaks = true
            }
            appManager.fetchStreaks()
            appManager.fetchGameRecords()
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
