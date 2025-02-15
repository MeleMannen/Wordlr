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
    
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack {
                ForEach(appManager.board.indices, id: \.self) { rowIndex in
                    HStack {
                        ForEach(appManager.board[rowIndex].indices, id: \.self) { colIndex in
                            let letter = appManager.board[rowIndex][colIndex]
                            if appManager.numberOfLetters < 6 {
                                Text(letter.letter)
                                    .font(.largeTitle).bold()
                                    .foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.background) : AnyShapeStyle(Color.white))
                                    .frame(width: 55, height: 55)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : Color(UIColor.label))))
                                    }
                                    .rotationEffect(.degrees(letter.frontDegree), anchor: .center)
                                
                                    .animation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
                                        .speed(1)
                                        .delay(0), value: letter.frontDegree)
                                
                                
                                
                                
                                
                                    .onChange(of: letter.state) {
                                        if letter.state != .notUsed {
                                            appManager.flipCard(rowIndex: rowIndex, colIndex: colIndex)
                                        }
                                    }
                                
                            } else {
                                Text(letter.letter)
                                    .font(.largeTitle).bold()
                                    .foregroundStyle(letter.state == .notUsed ? AnyShapeStyle(.background) : AnyShapeStyle(Color.white))
                                    .frame(width: 40, height: 40)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(letter.state == .correctPosition ? .green : (letter.state == .correctLetter ? .orange : (letter.state == .usedButNotCorrect ? Color(UIColor.darkGray) : Color(UIColor.label))))
                                    }
                                    .rotationEffect(.degrees(letter.frontDegree), anchor: .center)
                                
                                    .animation(.interpolatingSpring(mass: 0.7, stiffness: 100, damping: 8, initialVelocity: 1)
                                        .speed(1)
                                        .delay(0), value: letter.frontDegree)
                                
                            }
                        }
                    }
                }
            }
            .padding(.top, 5)
            
            Spacer()
            Spacer()
            
            ZStack {
                VStack {
                    ForEach(appManager.keyboard.indices, id: \.self) { rowIndex in
                        let keyboardRow = appManager.keyboard[rowIndex]
                        HStack(spacing: 5) {
                            ForEach(appManager.keyboard[rowIndex].indices, id: \.self) { colIndex in
                                let keyBoardKey = keyboardRow[colIndex]
                                if appManager.keyboard.last == keyboardRow && keyboardRow.first?.letter == keyBoardKey.letter {
                                    Text("Z")
                                        .font(.title2).bold()
                                        .foregroundStyle(.background)
                                        .frame(minWidth: 25, maxWidth: 33, minHeight: 32, idealHeight: 35, maxHeight: 38)
                                    
                                    
                                    Text("Z")
                                        .font(.title2).bold()
                                        .foregroundStyle(.background)
                                        .frame(minWidth: 25, maxWidth: 33, minHeight: 32, idealHeight: 35, maxHeight: 38)
                                    
                                }
                                
                                Text(keyBoardKey.letter)
                                    .font(.title2).bold()
                                    .foregroundStyle(keyBoardKey.state == .notUsed ? AnyShapeStyle(.background) : AnyShapeStyle(Color.white))
                                    .frame(minWidth: 25, maxWidth: 33, minHeight: 32, idealHeight: 35, maxHeight: 38)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(keyBoardKey.state == .correctPosition ? .green : (keyBoardKey.state == .correctLetter ? .orange : (keyBoardKey.state == .usedButNotCorrect ? Color(UIColor.darkGray) : Color(UIColor.label))))
                                        
                                    }
                                    .onTapGesture {
                                        if appManager.currentIndex < appManager.numberOfLetters {
                                            appManager.board[appManager.currentRow][appManager.currentIndex].letter = keyBoardKey.letter
                                            appManager.currentIndex += 1
                                        }
                                        appManager.keyboard[rowIndex][colIndex].didTapButton.toggle()
                                        
                                    }
                                    .sensoryFeedback(.impact, trigger: keyBoardKey.didTapButton)
                                
                                
                                
                                if appManager.keyboard.last == keyboardRow && keyboardRow.last?.letter == keyBoardKey.letter {
                                    Text("Z")
                                        .font(.title2).bold()
                                        .foregroundStyle(.background)
                                        .frame(minWidth: 25, maxWidth: 33, minHeight: 32, idealHeight: 35, maxHeight: 38)
                                    
                                    Text("Z")
                                        .font(.title2).bold()
                                        .foregroundStyle(.background)
                                        .frame(minWidth: 25, maxWidth: 33, minHeight: 32, idealHeight: 35, maxHeight: 38)
                                }
                            }
                        }
                        
                    }
                    HStack {
                        Button(action: {
                            appManager.didTapResetButton.toggle()
//                            appManager.isActiveAlert = true
//                            appManager.activeAlert = .first
                            appManager.alertItem = AlertItem(
                                title: Text("Are you sure you want to Restart?"),
                                message: Text("You will lose your word and you cannot undo this action!"),
                                primaryButton: .destructive(Text("Restart")) {
//                                    appManager.alertItem = AlertItem(title: Text("The Phrase Was: \(appManager.word)!"), primaryButton:  {
//                                        print("reseting...")
//                                        appManager.resetBoard()
//                                    })
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
                                .frame(maxWidth: 60, minHeight: 40, idealHeight: 45, maxHeight: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(UIColor.label))
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
//                        .alert(appManager.activeAlert != .none ? (appManager.activeAlert == .first ? "Are you sure you want to Restart?" : "The Phrase Was: \(appManager.word)!") : "Hi", isPresented: $appManager.isActiveAlert, actions: {
//                            if appManager.activeAlert == .first {
//                                Button("Restart", role: .destructive, action: {
//                                    
//                                    DispatchQueue.main.async {
//                                        appManager.isActiveAlert = false
//                                        
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                            appManager.activeAlert = .second
//                                            appManager.isActiveAlert = false
//                                            
//                                        }
//                                    }
//                                })
//                                
//                                Button(role: .cancel)
//                            } else if appManager.activeAlert == .second {
//                                Button("Dismiss", role: .default) {
//                                    print("reseting...")
//                                    appManager.resetBoard()
//                                }
//                                
//                                NavigationLink(destination: WordDescriptionView(word: appManager.word).environmentObject(appManager), label: {
//                                    Text("Show Definition")
//                                })
//                            } else {
//                                Button("Hi", role: .cancel)
//                            }
//                            
//                        }, message: {
//                            Text("")
//                        })
                        .sensoryFeedback(.warning, trigger: appManager.alertItem?.title)
                        
                        
                        
                        
                        
                        
                        Button(action: {
                            appManager.didTapSubmitButton.toggle()
                            appManager.didTapSubmit()
                            
                            
                        }, label: {
                            Text("SUBMIT WORD")
                                .font(.title)
                                .frame(maxWidth: .infinity, minHeight: 40, idealHeight: 45, maxHeight: 50)
                                .foregroundStyle(.white)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.green)
                                }
                        })
                        .padding(.horizontal, 2)
                        .sensoryFeedback(trigger: appManager.didTapSubmitButton) { old, new in
                            if appManager.isAnimating {
                                return .impact
                            } else {
                                return .error
                            }
                        }
                        
                        Button(action: {
                            appManager.didTapBackButton.toggle()
                            if !appManager.isAnimating && appManager.currentIndex > 0 {
                                appManager.currentIndex -= 1
                                appManager.board[appManager.currentRow][appManager.currentIndex].letter = ""
                            }
                            
                        }, label: {
                            Image(systemName: "delete.left.fill")
                                .font(.title2).bold()
                                .foregroundStyle(.black)
                                .frame(maxWidth: 60, minHeight: 40, idealHeight: 45, maxHeight: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color(UIColor.label))
                                }
                                
                                
                                
                        })
                        .buttonRepeatBehavior(.enabled)
                        .sensoryFeedback(.impact, trigger: appManager.didTapBackButton)
                        
                        
                        
                    }
                    .padding(.top, 5)
                }
                .frame(maxWidth: .infinity, minHeight: 250, idealHeight: 250, maxHeight: 300)
                .opacity((appManager.isGameOver && !appManager.isAnimating) ? 0 : 1)
                
                VStack {
                    Text(appManager.message)
                        .font(.title2).bold()
                        .padding(.bottom, 50)
                    
                    if appManager.gameMode == .normal {
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
                        .padding(.bottom, 50)
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
                        .padding(.bottom, 50)
                        .sensoryFeedback(.impact, trigger: appManager.didTapPlaySomethingElseButton)
                    }
                    
                    
                    NavigationLink(destination: WordDescriptionView(word: appManager.word).environmentObject(appManager), label: {
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
                    .padding(.bottom, 50)
                    
                    
                    
                    
                }
                .opacity((appManager.isGameOver && !appManager.isAnimating) ? 1 : 0)
                .sensoryFeedback(.success, trigger: (appManager.isGameOver && !appManager.isAnimating))
                .frame(maxWidth: .infinity, minHeight: 250, idealHeight: 250, maxHeight: 300)
                
            }
            .padding(.horizontal, 15)
        }
        .navigationDestination(isPresented: $appManager.isShowingCurrentDefinition, destination: {
            WordDescriptionView(word: appManager.word)
                .environmentObject(appManager)
        })
        .navigationTitle("Guess The Phrase")
        .navigationBarTitleDisplayMode(.inline)
//        .toolbarBackground(.background, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: SearchView().environmentObject(appManager), label: {
                    Image(systemName: "magnifyingglass")
                        .contentShape(Rectangle())
                })
            }
        }
        .onAppear {
            if appManager.word.isEmpty || appManager.word.count != appManager.numberOfLetters {
                appManager.getWords()
            }
            
            
        }
        
    }
}





#Preview {
    GameView()
        .environmentObject(AppManager())
}
