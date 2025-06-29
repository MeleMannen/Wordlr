//
//  GameView.swift
//  Wordle
//
//  Created by Kristoffer Melen on 18/12/2024.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appTheme") private var appTheme: AppTheme = .dark
    private var device : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var colorForUnused: Color {
        switch colorScheme {
            case .light:
                return Color(UIColor.lightGray)
            case .dark:
                return .primary
            @unknown default:
                return .primary
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                GeometryReader { geometry2 in
                    VStack {
                        ForEach(appManager.board.indices, id: \.self) { rowIndex in
                            HStack {
                                ForEach(appManager.board[rowIndex].indices, id: \.self) { colIndex in
                                    let letter = appManager.board[rowIndex][colIndex]
                                    if appManager.numberOfLetters < 5 {
                                        Text(letter.letter)
                                            .font(.largeTitle).bold()
                                            .foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
                                            .frame(width: geometry2.size.height / CGFloat(6), height: geometry2.size.height / CGFloat(6))
                                            .background {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused)))
                                            }
                                            .rotationEffect(.degrees(letter.degreee), anchor: .center)
                                        
                                            .animation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
                                                .speed(1)
                                                .delay(0), value: letter.degreee)
                                            .offset(x: rowIndex == appManager.currentRow ? (appManager.isShaking ? -15 : 0) : 0)
                                            .onChange(of: letter.state) {
                                                if letter.state != .notUsed {
                                                    appManager.flipCard(rowIndex: rowIndex, colIndex: colIndex)
                                                }
                                            }
                                        
                                    } else {
                                        Text(letter.letter)
                                            .font(.largeTitle).bold()
                                            .foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
                                            .frame(width: geometry2.size.height / CGFloat(appManager.numberOfLetters + 1), height: geometry2.size.height / CGFloat(appManager.numberOfLetters + 1))
                                            .background {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused)))
                                            }
                                            .rotationEffect(.degrees(letter.degreee), anchor: .center)
                                            .animation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
                                                .speed(1)
                                                .delay(0), value: letter.degreee)
                                            .scaleEffect(letter.scale, anchor: .center)
                                            .offset(x: rowIndex == appManager.currentRow ? (appManager.isShaking ? -15 : 0) : 0)
                                            .onChange(of: letter.state) {
                                                if letter.state != .notUsed {
                                                    appManager.flipCard(rowIndex: rowIndex, colIndex: colIndex)
                                                }
                                            }
                                            .onChange(of: letter.letter) {
                                                if !letter.letter.isEmpty {
                                                    appManager.animateTappedLetter(rowIndex: rowIndex, colIndex: colIndex)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
                    
                }
                GeometryReader { geometry2 in
                    ZStack {
                        VStack {
                            Spacer()
                            ForEach(appManager.keyboard.indices, id: \.self) { rowIndex in
                                let keyboardRow = appManager.keyboard[rowIndex]
                                HStack(spacing: self.device == .pad ? 8 : 5) {
                                    ForEach(appManager.keyboard[rowIndex].indices, id: \.self) { colIndex in
                                        let keyBoardKey = keyboardRow[colIndex]
                                        if appManager.keyboard.last == keyboardRow && keyboardRow.first?.letter == keyBoardKey.letter {
                                            Text("Z")
                                                .hidden()
                                                .frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
                                            
                                            
                                            Text("Z")
                                                .hidden()
                                                .frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
                                            
                                        }
                                        
                                        Button(action: {
                                            if appManager.currentIndex < appManager.numberOfLetters {
                                                appManager.board[appManager.currentRow][appManager.currentIndex].letter = keyBoardKey.letter
                                                appManager.currentIndex += 1
                                            }
                                            appManager.keyboard[rowIndex][colIndex].didTapButton.toggle()
                                        }, label: {
                                            Text(keyBoardKey.letter)
                                                .font(.title2).bold()
                                                .foregroundStyle(keyBoardKey.state == .notUsed ? AnyShapeStyle(.black) : AnyShapeStyle(Color.white))
                                                .frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
                                                .background {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(keyBoardKey.state == .correctPosition ? .green : (keyBoardKey.state == .correctLetter ? .orange : (keyBoardKey.state == .usedButNotCorrect ? Color(UIColor.darkGray) : self.colorForUnused)))
                                                }
                                        })
                                        .buttonStyle(ScalingButton())
                                        .sensoryFeedback(.impact, trigger: keyBoardKey.didTapButton)
                                        
                                        
                                        
                                        if appManager.keyboard.last == keyboardRow && keyboardRow.last?.letter == keyBoardKey.letter {
                                            Text("Z")
                                                .hidden()
                                                .frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
                                            
                                            Text("Z")
                                                .hidden()
                                                .frame(minWidth: geometry2.size.width / CGFloat(14), maxWidth: geometry2.size.width / CGFloat(12), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
                                        }
                                    }
                                }
                                
                            }
                            HStack {
                                Button(action: {
                                    appManager.didTapResetButton.toggle()
                                    appManager.alertItem = AlertItem(
                                        title: Text("Are you sure you want to Restart?"),
                                        message: Text("You will lose your word and you cannot undo this action!"),
                                        primaryButton: .destructive(Text("Restart")) {
                                            appManager.alertItem = AlertItem(
                                                title: Text("The Phrase Was: \(appManager.word)!"),
                                                message: Text("Do you want to see the definition?"),
                                                primaryButton: .default(Text("Show Definition")) {
                                                    appManager.isShowingCurrentDefinition = true
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                        print("reseting...")
                                                        appManager.resetBoard()
                                                    }
                                                },
                                                secondaryButton: .cancel(Text("Dismiss")) {
                                                    print("reseting...")
                                                    appManager.resetBoard()
                                                })
                                        }, secondaryButton: .cancel())
                                    print("wtf!!")
                                }, label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title2).bold()
                                        .foregroundStyle(.black)
                                        .frame(minWidth: geometry2.size.width / CGFloat(9),
                                               maxWidth: geometry2.size.width / CGFloat(7),
                                               minHeight: geometry2.size.height / CGFloat(10),
                                               idealHeight: geometry2.size.height / CGFloat(8),
                                               maxHeight: geometry2.size.height / CGFloat(6))
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(self.colorForUnused)
                                        }
                                })
                                .sensoryFeedback(.impact, trigger: appManager.didTapResetButton)
                                .alert(item: $appManager.alertItem) { item in
                                    if let dismissButton = item.dismissButton {
                                        Alert(title: item.title, message: item.message, dismissButton: dismissButton)
                                    } else if let primaryButton = item.primaryButton, let secondaryButton = item.secondaryButton {
                                        Alert(title: item.title, message: item.message, primaryButton: primaryButton, secondaryButton: secondaryButton)
                                    } else {
                                        Alert(title: item.title)
                                    }
                                    
                                }
                                .sensoryFeedback(.warning, trigger: appManager.alertItem?.title)
                                .buttonStyle(ScalingButton())
                                
                                Spacer()
                                
                                Button(action: {
                                    appManager.didTapSubmitButton.toggle()
                                    appManager.didTapSubmit()
                                    
                                    
                                }, label: {
                                    Text("SUBMIT WORD")
                                        .font(.title)
                                        .frame(minWidth: (geometry2.size.width*7) / CGFloat(14) + CGFloat(self.device == .pad ? 60 : 30), maxWidth: (geometry2.size.width*7) / CGFloat(12) + CGFloat(self.device == .pad ? 60 : 30), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
                                        .foregroundStyle(.white)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(.green)
                                                .opacity(appManager.submitOpacity)
                                                .animation(.easeInOut(duration: 0.1), value: appManager.submitOpacity)
                                                .sensoryFeedback(.alignment, trigger: appManager.submitOpacity)
                                                .onChange(of: appManager.wordIsValidForSubmitButton()) { oldValue, newValue in
                                                    if newValue {
                                                        appManager.submitOpacity = 1.0
                                                    } else {
                                                        appManager.submitOpacity = 0.5
                                                    }
                                                }
                                            
                                        }
                                })
                                
                                .sensoryFeedback(trigger: appManager.didTapSubmitButton) { old, new in
                                    if appManager.isAnimating {
                                        return .impact
                                    } else {
                                        return .error
                                    }
                                }
                                .buttonStyle(GrowingButton())
                                
                                Spacer()
                                
                                Button(action: {
                                    appManager.didTapBackButton.toggle()
                                    if !appManager.isAnimating && appManager.currentIndex > 0 {
                                        appManager.currentIndex -= 1
                                        appManager.board[appManager.currentRow][appManager.currentIndex].letter = ""
                                    }
                                    
                                }, label: {
                                    Image(systemName: "delete.left")
                                        .font(.title2).bold()
                                        .foregroundStyle(.black)
                                        .frame(minWidth: geometry2.size.width / CGFloat(9), maxWidth: geometry2.size.width / CGFloat(7), minHeight: geometry2.size.height / CGFloat(10), idealHeight: geometry2.size.height / CGFloat(8), maxHeight: geometry2.size.height / CGFloat(6))
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(self.colorForUnused)
                                        }
                                    
                                })
                                .buttonRepeatBehavior(.enabled)
                                .sensoryFeedback(.impact, trigger: appManager.didTapBackButton)
                                .buttonStyle(ScalingButton())
                            }
                            .padding(.top, 5)
                        }
                        .padding(.bottom, 5)
                        .opacity((appManager.isGameOver && !appManager.isAnimating) ? 0 : 1)
                        
                        VStack(alignment: .center) {
                            Spacer()
                            Spacer()
                            
                            Text(appManager.message)
                                .font(.title2).bold()
                            
                            Spacer()
                            
                            if appManager.selectedGameMode == .normal {
                                Button(action: {
                                    appManager.didTapNewGameButton.toggle()
                                    appManager.resetBoard()
                                }, label: {
                                    Text("New Game")
                                        .font(.title)
                                        .frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
                                        .foregroundStyle(.white)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(.green)
                                        }
                                })
                                .padding(.horizontal, 20)
                                .sensoryFeedback(.impact, trigger: appManager.didTapNewGameButton)
                                
                            } else {
                                Button(action: {
                                    appManager.didTapPlaySomethingElseButton.toggle()
                                    dismiss()
                                    
                                    
                                }, label: {
                                    Text("Play Something Else")
                                        .font(.title)
                                        .frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
                                        .foregroundStyle(.white)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(.green)
                                        }
                                })
                                .padding(.horizontal, 20)
                                .sensoryFeedback(.impact, trigger: appManager.didTapPlaySomethingElseButton)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: NorwegianWordDefinitionView(word: appManager.word).environmentObject(appManager), label: {
                                Text("Show Definition")
                                    .font(.title)
                                    .frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
                                    .foregroundStyle(.white)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.orange)
                                    }
                            })
                            .padding(.horizontal, 20)
                            
                            Spacer()
                            
                            if appManager.selectedGameMode == .dailyWord {
                                Button {
                                    withAnimation {
                                        appManager.shareResult()
                                    }
                                } label: {
                                    Label("Tap to Copy Result", systemImage: appManager.hasSharedResult ? "doc.on.doc.fill" : "doc.on.doc")
                                        .font(.title2).bold()
                                        .contentTransition(.symbolEffect(.replace))
                                }
                                Spacer()
                            }
                            
                            
                            
                        }
                        .opacity((appManager.isGameOver && !appManager.isAnimating) ? 1 : 0)
                        .sensoryFeedback(.success, trigger: (appManager.isGameOver && !appManager.isAnimating))
                        
                    }
                    .padding(.horizontal, 5)
                }
                .frame(maxWidth: .infinity, maxHeight: (geometry.size.height*3) / 5)
            }
            .navigationDestination(isPresented: $appManager.isShowingCurrentDefinition, destination: {
                WordDefinitionView(word: appManager.word)
                    .environmentObject(appManager)
            })
            .navigationTitle("Guess The Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if appManager.isHintAvailable() {
                    ToolbarItem(placement: .topBarTrailing) {
                        AdButton()
                            .environmentObject(appManager)
                        
                        
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SearchView().environmentObject(appManager), label: {
                        Image(systemName: "magnifyingglass")
                            .contentShape(Rectangle())
                    })
                    // MARK: - Fikse sensory feedback on the search button
                }
            }
        }
        .onAppear {
            if appManager.word.isEmpty || appManager.selectedLanguage != appManager.language || appManager.gameMode != appManager.selectedGameMode {
                appManager.getWords()
            } else if appManager.word.count != appManager.numberOfLetters {
                appManager.resetBoard()
            }
            
        }
    }
}

struct AdButton: View {
    @EnvironmentObject var appManager: AppManager
    @AppStorage("userWantsAds") var userWantAds: Bool = false
    @State var isPresentingAdOption: Bool = false
    @State var hasLoadedAd: Bool = false
    @State private var didTap: Bool = false
    
    var body: some View {
        Button(action: {
            self.didTap.toggle()
            if !appManager.isGameOver && !appManager.isAnimating {
                if !userWantAds {
                    self.isPresentingAdOption = true
                } else {
                    if hasLoadedAd {
                        appManager.showAd()
                        
                    } else {
                        Task {
                            await appManager.loadAd()
                            appManager.showAd()
                        }
                    }
                }
            }
        }, label: {
            Image(systemName: "lightbulb.max.fill")
                .contentShape(Rectangle())
        })
        .alert("Hint", isPresented: $isPresentingAdOption, actions: {
            Button("No", role: .cancel) {
                self.userWantAds = false
            }
            Button("Sure") {
                self.userWantAds = true
                Task {
                    await appManager.loadAd()
                    appManager.showAd()
                }
            }
        }, message: {
            Text("Do you want to see an ad to get a hint and support the app? It helps us keep the app free and improve it further.")
        })
        .onAppear {
            if userWantAds {
                Task {
                    await appManager.loadAd()
                    self.hasLoadedAd = true
                }
            }
        }
        .sensoryFeedback(.impact, trigger: self.didTap)
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ScalingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}



#Preview {
    GameView()
        .environmentObject(AppManager())
}
