//
//  SelectView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency

struct SelectView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var appManager: AppManager
    @AppStorage("hasAddedStreaks") private var hasAddedStreaks: Bool = false
    @AppStorage("hasAddedNormalStreaks") private var hasAddedNormalStreaks: Bool = false
    @AppStorage("hasFixedLanguage") private var hasFixedLanguage: Bool = false
    @AppStorage("userWantsAds") var userWantAds: Bool = false
    @State var hasFixedDefualtValues: Bool = false
    @State var hasFixedContextAndFetched: Bool = false
    @State var didTapPlayDailyWordButton: Bool = false
    @State var didTapFakePlayDailyWordButton: Bool = false
    @State var didTapPlayNormalButton: Bool = false
    @State var didTapInfoButton: Bool = false
    @State var isShowingAlreadyPlayedAlert: Bool = false
    
    
    var body: some View {
        NavigationStack {
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
                                    Text("\(number) letters")
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
                                if #unavailable(iOS 26.0, ) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(uiColor: .tertiarySystemBackground))
                                }
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
                                    .conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)
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
                                    .conditionalShadow(color: .black.opacity(0.1), radius: 0.5, x: 1, y: 1)
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
                        if appManager.checkIfDailyWordIsAlreadyPlayed2() {
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
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(appManager.gradient)
                                                .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
//                                                .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                                .opacity(0.3)
//                                                .buttonStyle(GrowingButton())
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
//                                        .buttonStyle(GrowingButton())
                                    
                                }
//                                .conditionalShadow(color: .black.opacity(0.1), radius: 1.5, x: 1, y: 1)
                            } else {
                                VStack {
                                    
                                    Text("Play Daily Word")
                                        .multilineTextAlignment(.center)
                                        
                                        .font(.title2).bold()
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.white)
                                        .background {
                                            //                                        if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 1 {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(appManager.gradient)
                                                .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
//                                                .conditionalShadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
                                                .opacity(0.3)
//                                                .buttonStyle(GrowingButton())
                                                
                                                
                                            
                                            //                                        } else {
                                            //                                            RoundedRectangle(cornerRadius: 15)
                                            //                                                .foregroundStyle(.green)
                                            //                                                .opacity(0.4)
                                            //                                        }
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
                                    //                                    .buttonStyle(GrowingButton())
                                }
//                                .conditionalShadow(color: .black.opacity(0.1), radius: 1.5, x: 1, y: 1)
                                
                                
                                    
                            }
                            
                            
                        } else {
                            NavigationLink(destination: GameView().environmentObject(appManager)) {
                                if let streakEntity = appManager.getStreakEntity(), streakEntity.streak.currentStreak >= 3, streakEntity.streak.isAlive {
                                    Text("Play Daily Word\n\(streakEntity.streak.currentStreak)🔥")
                                        .contentTransition(.numericText(value: Double(streakEntity.streak.currentStreak)))
                                        .multilineTextAlignment(.center)
                                        .conditionalShadow(color: .black.opacity(0.1), radius: 1.5, x: 1, y: 1)
                                        .lineSpacing(5)
                                        .font(.title2).bold()
                                        .padding()
                                    
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.white)
                                        .background {
                                            RoundedRectangle(cornerRadius: 15)
                                            //                                                .foregroundStyle(.green)
                                                .foregroundStyle(appManager.gradient)
                                                .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
                                        }
                                        .padding(.horizontal, 30)
                                } else {
                                    Text("Play Daily Word")
                                        .multilineTextAlignment(.center)
                                        .conditionalShadow(color: .black.opacity(0.1), radius: 1.5, x: 1, y: 1)
                                        .font(.title2).bold()
                                        .padding()
                                    
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.white)
                                        .background {
                                            RoundedRectangle(cornerRadius: 15)
                                            //                                                .foregroundStyle(.green)
                                                .foregroundStyle(appManager.gradient)
                                                .gradientShadow(gradient: appManager.shadowGradient, radius: 3, x: 0, y: 0)
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if self.userWantAds {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in })
            }
        }
        .onAppear {
            if !self.hasFixedContextAndFetched {
                
                appManager.modelContext = modelContext
                appManager.streakManager = StreakManager(context: modelContext)
                appManager.normalStreakManager = NormalStreakManager(context: modelContext)
                appManager.gameRecordManager = GameRecordManager(context: modelContext)
                print("Fixed model context in SelectView")
                
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
//            appManager.updateStreak(appManager.getStreakEntity()!, with: .alive(startDate: Date(timeIntervalSince1970: TimeInterval(1748818196)), lastWonDate: Date()))
            
            if !self.hasFixedDefualtValues {
                appManager.setDefaultValues()
                self.hasFixedDefualtValues = true
            }
            
            if !self.hasFixedLanguage {
                appManager.fixLanguageBasedOnLocale()
                self.hasFixedLanguage = true
            }
        }
    }
}

// Make an extention to add padding conditionally based on iOS version
struct ConditionalGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive())
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
    /// Applies a standard shadow only when `enabled` is true.
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
        .environmentObject(AppManager())
}
